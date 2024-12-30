import 'package:auth_manager/business.dart';
import 'package:auth_manager/core.dart';
import 'package:auth_manager/views.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
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
      body: EasyRefresh(
        header: BuilderHeader(
          position: IndicatorPosition.locator,
          hapticFeedback: true,
          processedDuration: Duration.zero,
          builder: (context, state) {
            final offset =
                (state.offset / state.actualTriggerOffset).clamp(0.0, 1.0);
            return Container(
              color: Colors.black.withOpacity(0.25),
              height: state.offset,
              child: Center(
                child: CircularProgressIndicator(
                  value: [IndicatorMode.processing, IndicatorMode.ready]
                          .contains(state.mode)
                      ? null
                      : offset,
                ),
              ),
            );
          },
          clamping: false,
          triggerOffset: 50,
        ),
        notLoadFooter: const NotLoadFooter(clamping: true),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          final accountsBox = ref.read(accountsProvider);
          accounts = accountsBox.values.toList();
        },
        onLoad: null,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              centerTitle: true,
              floating: true,
              title: Text("Authenticators"),
            ),
            const HeaderLocator.sliver(),
            if (accounts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add a new authenticator\nor\npull down to refresh",
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        openButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          foregroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          foregroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        type: ExpandableFabType.up,
        childrenOffset: const Offset(0, -16),
        distance: 70,
        pos: ExpandableFabPos.right,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        ),
        childrenAnimation: ExpandableFabAnimation.none,
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () async {
              final url = await ref
                  .read(routerProvider)
                  .pushNamed<String>(Routes.scanner.name);
              print(url);
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Scanner"),
          ),
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: _onAddAccountPressed,
            icon: const Icon(Icons.edit),
            label: const Text("Manually"),
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
        return Padding(
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
