import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool receiveNotifications = true;
  bool showTips = true;

  void savePreferences() {
    // Save these to Firestore or SharedPreferences
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferences")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Receive Notifications"),
            value: receiveNotifications,
            onChanged: (val) => setState(() => receiveNotifications = val),
          ),
          SwitchListTile(
            title: const Text("Show Daily Tips"),
            value: showTips,
            onChanged: (val) => setState(() => showTips = val),
          ),
          ElevatedButton(onPressed: savePreferences, child: const Text("Save Preferences")),
        ],
      ),
    );
  }
}
