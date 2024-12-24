import 'package:auth_manager/business.dart';
import 'package:auth_manager/core.dart';
import 'package:auth_manager/views.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late List<Account> accounts;
  late ScrollController scrollController;
  bool _atTop = true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        final shouldUpdate = scrollController.hasClients &&
            (_atTop && scrollController.offset > 0 ||
                !_atTop && scrollController.offset <= 0);

        if (shouldUpdate) {
          setState(() {
            _atTop = scrollController.offset <= 0;
          });
        }
      });

    final accountsBox = ref.read(accountsProvider);
    accounts = accountsBox.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        physics: _atTop
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : null,
        slivers: [
          SliverAppBar(
            centerTitle: true,
            floating: true,
            title: const Text("Providers"),
            actions: [
              IconButton(
                onPressed: _onAddAccountPressed,
                icon: const Icon(Icons.add),
              )
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              final accountsBox = ref.read(accountsProvider);
              accounts = accountsBox.values.toList();
            },
            refreshTriggerPullDistance: 50,
            refreshIndicatorExtent: 50,
            builder: (
              context,
              mode,
              pulledExtent,
              refreshTriggerPullDistance,
              refreshIndicatorExtent,
            ) {
              return Center(
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
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
                      "Start by adding a provider",
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
                      await accountsBox.delete(accounts[index].id);
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _onAddAccountPressed() async {
    final account = await showMaterialModalBottomSheet<Account>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          controller: ModalScrollController.of(context),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AddAccountPage(),
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
