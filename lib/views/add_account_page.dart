import 'package:auth_manager/business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key});

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  final _userNameController = TextEditingController();
  final _providerController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
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
            Text(
              "Add Provider",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: "Provider",
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: "User Name",
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _secretController,
              decoration: InputDecoration(
                labelText: "Secret",
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ),
              obscureText: true,
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
                    final accountsBox = ref.read(accountsProvider);
                    Navigator.of(context).pop(Account(
                      id: accountsBox.length,
                      url:
                          "otpauth://totp/${_providerController.text}:${_userNameController.text}?"
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
