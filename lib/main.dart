import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart'; 
import 'screens/home_screen.dart';

void main() async {
  // Flutter channel active before calling plugins 
  WidgetsFlutterBinding.ensureInitialized();

  // global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("Error de Flutter: ${details.exception}");
  };

  final themeController = await ThemeController.create();

  runApp(HiraganaFlashcardsApp(themeController: themeController));
}

/// Root widget of the Hiragana Flashcards app.
class HiraganaFlashcardsApp extends StatelessWidget {
  const HiraganaFlashcardsApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Hiragana Flashcards',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: HomeScreen(themeController: themeController),
        );
      },
    );
  }
}