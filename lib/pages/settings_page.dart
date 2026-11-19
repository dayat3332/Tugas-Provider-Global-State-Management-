import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_latihan_global/providers/user_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController userNameController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text("Username: "),
                Text(
                  context.watch<UserModel>().userName.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<UserModel>().changeUserName(
                      newUserName: userNameController.text,
                    );
                FocusManager.instance.primaryFocus?.unfocus();
                userNameController.clear();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
