import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:budget_managing/app_localizations.dart';
import 'package:budget_managing/language_provider.dart';
import 'package:budget_managing/theme_provider.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Manager',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeProvider.themeMode,
      locale: languageProvider.locale,
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      localizationsDelegates: const [
        AppLocalizations.delegate, // Your custom delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      routes: {'/settings': (context) => const SettingsScreen()},
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade800,
        secondary: Colors.teal.shade600,
        surface: Colors.white,
        error: Colors.red.shade700,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme().copyWith(
        bodyLarge: TextStyle(color: Colors.grey.shade800),
        bodyMedium: TextStyle(color: Colors.grey.shade800),
        displayLarge: TextStyle(color: Colors.black),
        displayMedium: TextStyle(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300,
        secondary: Colors.teal.shade300,
        surface: Colors.grey.shade800,
        error: Colors.red.shade400,
        onPrimary: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.grey.shade800,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme().copyWith(
        bodyLarge: TextStyle(color: Colors.grey.shade300),
        bodyMedium: TextStyle(color: Colors.grey.shade300),
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
