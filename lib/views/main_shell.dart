import 'package:auth_manager/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  final items = [
    Routes.authenticators,
    Routes.passwords,
    Routes.payments,
    Routes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: widget.child,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                width: 1,
              ),
            ),
          ),
          child: SalomonBottomBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.onSurface,
            unselectedItemColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
            margin: const EdgeInsets.all(20),
            itemPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              ref.read(routerProvider).goNamed(items[index].name);
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
      ],
    );
  }
}