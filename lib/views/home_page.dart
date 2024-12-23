import 'package:auth_manager/business.dart';
import 'package:auth_manager/core.dart';
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
  String _name = "";
  String _uri = "";

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
                onPressed: () async {
                  _name = "";
                  _uri = "";
                  await showMaterialModalBottomSheet(
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
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Provider",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Name",
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _name = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: "Uri",
                                    suffixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.qr_code_scanner),
                                    ),
                                  ),
                                  obscureText: true,
                                  onChanged: (value) {
                                    setState(() {
                                      _uri = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    const SizedBox(width: 10),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Save"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );

                  if (_name.isNotEmpty && _uri.isNotEmpty) {
                    final accountsBox = ref.read(accountsProvider);
                    final provider = Account(
                      id: accountsBox.length,
                      url: _uri,
                    );

                    await accountsBox.add(provider);
                    setState(() {});
                  }
                },
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
}
