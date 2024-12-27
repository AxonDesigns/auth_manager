import 'package:auth_manager/core.dart';
import 'package:auth_manager/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    this.pagePath,
  });

  final String? pagePath;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  late PageController controller;

  final items = [
    Routes.authenticators,
    Routes.passwords,
    Routes.payments,
    Routes.settings,
  ];

  @override
  void initState() {
    super.initState();

    int index = 0;
    if (widget.pagePath != null) {
      if (items.any((element) => element.path == widget.pagePath)) {
        index = items.indexOf(Routes.values.firstWhere((element) {
          return element.path == widget.pagePath;
        }));
      }
    }

    controller = PageController(
      initialPage: index,
    );
    _selectedIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: items.length,
        controller: controller,
        onPageChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        itemBuilder: (context, index) {
          return [
            const AuthenticatorsPage(),
            const PasswordsPage(),
            const PaymentsPage(),
            const SettingsPage(),
          ][index];
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
              width: 1,
            ),
          ),
        ),
        child: SalomonBottomBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.onSurface,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
          margin: const EdgeInsets.all(20),
          itemPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            if ((_selectedIndex - index).abs() > 1) {
              controller.jumpToPage(index);
            } else {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
              );
            }

            final router = ref.read(routerProvider);
            router.go(items[index].path);
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_outlined),
              title: Text(Routes.authenticators.label),
              activeIcon: const Icon(Icons.home),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.key_outlined),
              title: Text(Routes.passwords.label),
              activeIcon: const Icon(Icons.key),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.credit_card_outlined),
              title: Text(Routes.payments.label),
              activeIcon: const Icon(Icons.credit_card),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.settings_outlined),
              title: Text(Routes.settings.label),
              activeIcon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
