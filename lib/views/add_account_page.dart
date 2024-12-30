import 'package:auth_manager/business.dart';
import 'package:auth_manager/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key});

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  final _usernameController = TextEditingController();
  final _providerController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _providerController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                width: 50,
                height: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "New Account",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _providerController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Provider",
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _secretController,
              decoration: const InputDecoration(
                labelText: "Secret",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    ref.read(routerProvider).pop();
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () {
                    if (_providerController.text.isEmpty ||
                        _usernameController.text.isEmpty ||
                        _secretController.text.isEmpty) {
                      return;
                    }
                    final accountsBox = ref.read(accountsProvider);
                    Navigator.of(context).pop(Account(
                      id: accountsBox.length,
                      url:
                          "otpauth://totp/${_providerController.text}:${_usernameController.text}?"
                          "secret=${_secretController.text}&issuer=${_providerController.text}",
                    ));
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
