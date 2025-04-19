import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_managing/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildThemeSwitch(context),
            // Add other settings items here
          ],
        ),
      ),
    );
  }

Widget _buildThemeSwitch(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  
  return StatefulBuilder(
    builder: (context, setState) {
      return SwitchListTile(
        title: Text(
          'Dark Mode',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        value: themeProvider.isDarkMode,
        onChanged: (value) async {
          await themeProvider.toggleTheme(value);
          setState(() {});
        },
        secondary: Icon(
          Icons.dark_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    },
  );
}
}