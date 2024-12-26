import 'package:auth_manager/business.dart';
import 'package:auth_manager/components/refreshable_physics.dart';
import 'package:auth_manager/core.dart';
import 'package:auth_manager/views.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AuthenticatorsPage extends ConsumerStatefulWidget {
  const AuthenticatorsPage({super.key});

  @override
  ConsumerState<AuthenticatorsPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<AuthenticatorsPage> {
  late List<Account> accounts;

  @override
  void initState() {
    super.initState();

    final accountsBox = ref.read(accountsProvider);
    accounts = accountsBox.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshPhysics(
        builder: (controller, physics) => CustomScrollView(
          controller: controller,
          physics: physics,
          slivers: [
            const SliverAppBar(
              centerTitle: true,
              floating: true,
              title: Text("Authenticators"),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                final accountsBox = ref.read(accountsProvider);
                accounts = accountsBox.values.toList();
              },
              refreshTriggerPullDistance: 100,
              refreshIndicatorExtent: 100,
              builder: (
                context,
                mode,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshIndicatorExtent,
              ) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      minHeight: 32,
                      maxHeight: 32,
                      maxWidth: 32,
                      minWidth: 32,
                      child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        value: mode == RefreshIndicatorMode.drag
                            ? pulledExtent / refreshTriggerPullDistance
                            : null,
                        color: switch (mode) {
                          RefreshIndicatorMode.armed => Colors.red,
                          RefreshIndicatorMode.refresh => Colors.blue,
                          RefreshIndicatorMode.done => Colors.green,
                          _ => Colors.white.withOpacity(
                              (pulledExtent / refreshTriggerPullDistance)
                                  .clamp(0, 1),
                            ),
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            if (accounts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Start by adding an authenticator",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            if (accounts.isNotEmpty)
              SliverList.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      accounts[index].username,
                    ),
                    subtitle: Text(
                      accounts[index].provider,
                    ),
                    onTap: () {
                      ref.read(routerProvider).push("/totp", extra: {
                        "name": accounts[index].provider,
                        "token": accounts[index].secret,
                      });
                    },
                    trailing: IconButton(
                      onPressed: () async {
                        final accountsBox = ref.read(accountsProvider);
                        await accountsBox.delete(accounts[index].key);
                        accounts = accountsBox.values.toList();
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddAccountPressed,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onAddAccountPressed() async {
    final account = await showMaterialModalBottomSheet<Account>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastEaseInToSlowEaseOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: ModalScrollController.of(context),
            child: const AddAccountPage(),
          ),
        );
      },
    );

    if (account == null) return;
    final accountsBox = ref.read(accountsProvider);
    await accountsBox.add(account);
    setState(() {
      accounts = accountsBox.values.toList();
    });
  }
}
