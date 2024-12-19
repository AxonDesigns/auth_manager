import 'package:async_widget_builder/async_widget_builder.dart';
import 'package:auth_manager/business.dart';
import 'package:auth_manager/views/code_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:isar/isar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<List<Provider>> providers;
  late ScrollController scrollController;
  bool _atTop = true;
  String _name = "";
  String _token = "";

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

    final db = ref.read(dbProvider);
    providers = db.providers.where().findAll();
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
                  _token = "";
                  await showMaterialModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Provider",
                                style: Theme.of(context).textTheme.titleMedium,
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
                                  labelText: "Token",
                                  suffixIcon: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.qr_code_scanner),
                                  ),
                                ),
                                obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    _token = value;
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
                      );
                    },
                  );

                  if (_name.isNotEmpty && _token.isNotEmpty) {
                    final db = ref.read(dbProvider);
                    final provider = Provider()
                      ..name = _name
                      ..token = _token;
                    await db.writeTxn(() async {
                      await db.providers.put(provider);
                      providers = db.providers.where().findAll();
                    });
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.add),
              )
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              final db = ref.read(dbProvider);
              await db.writeTxn(() async {
                providers = db.providers.where().findAll();
              });
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
          providers.buildWidget(
            data: (data) {
              if (data.isEmpty) {
                return const SliverFillRemaining(
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
                );
              }

              return SliverList.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(data[index].name),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CodePage(
                            name: data[index].name,
                            token: data[index].token,
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      onPressed: () async {
                        final db = ref.read(dbProvider);
                        await db.writeTxn(() async {
                          await db.providers.delete(data[index].id);
                          providers = db.providers.where().findAll();
                        });
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stackTrace) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    "Error",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
