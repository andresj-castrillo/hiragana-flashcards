import 'package:flutter/material.dart';

import '../core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeController,
        builder: (context, currentMode, _) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              RadioGroup<ThemeMode>(
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) {
                    themeController.setThemeMode(mode);
                  }
                },
                child: Column(
                  children: const [
                    RadioListTile<ThemeMode>.adaptive(
                      value: ThemeMode.system,
                      title: Text('Use system setting'),
                      subtitle: Text('Follows your phone\'s light/dark setting'),
                    ),
                    RadioListTile<ThemeMode>.adaptive(
                      value: ThemeMode.light,
                      title: Text('Light'),
                    ),
                    RadioListTile<ThemeMode>.adaptive(
                      value: ThemeMode.dark,
                      title: Text('Dark'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}