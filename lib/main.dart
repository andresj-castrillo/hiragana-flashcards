import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  // Flutter channel active before calling plugins 
  WidgetsFlutterBinding.ensureInitialized();

  // global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("Error de Flutter: ${details.exception}");
  };

  runApp(const HiraganaFlashcardsApp());
}

/// Root widget of the Hiragana Flashcards app.
class HiraganaFlashcardsApp extends StatelessWidget {
  const HiraganaFlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiragana Flashcards',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}