import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:budget_managing/currencies.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildThemeSwitch(context),
            _buildCurrencyDropdown(context),
            // Add other settings items here
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return ListTile(
      leading: Icon(
        Icons.currency_exchange,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Currency',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return DropdownButton<String>(
            value: provider.currency,
            items:
                currencies.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(
                      '${currencies[key]!['symbol']!} - ${currencies[key]!['name']!}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                themeProvider.setCurrency(newValue);
              }
            },
          );
        },
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
