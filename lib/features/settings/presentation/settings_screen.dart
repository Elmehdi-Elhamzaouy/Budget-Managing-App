// ignore_for_file: deprecated_member_use

import 'package:budget_managing/app_localizations.dart';
import 'package:budget_managing/language_provider.dart';
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
          AppLocalizations.of(context)!.translations['Settings']!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ), // Added closing parentheses here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translations['Settings']!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeSwitch(context),
            const SizedBox(height: 16),
            _buildLanguageDropdown(context),
            const SizedBox(height: 16),
            _buildCurrencyDropdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.currency_exchange,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.translations['Currency']!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            return DropdownButton<String>(
              value: provider.currency,
              underline: Container(),
              borderRadius: BorderRadius.circular(12),
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
                if (newValue != null) themeProvider.setCurrency(newValue);
              },
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return SwitchListTile(
            title: Text(
              AppLocalizations.of(context)!.translations['Dark Mode']!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) async {
              await themeProvider.toggleTheme(value);
              setState(() {});
            },
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dark_mode,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            activeTrackColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
            activeColor: Theme.of(context).colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          );
        },
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.language,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          'Language',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Consumer<LanguageProvider>(
          builder: (context, provider, child) {
            return DropdownButton<Locale>(
              value: provider.locale,
              isDense: true,
              elevation: 4,
              alignment: Alignment.center,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 28,
              ),
              underline: Container(),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: [
                DropdownMenuItem<Locale>(
                  value: const Locale('en', 'US'),
                  alignment: Alignment.center,
                  child: Text(
                    'English',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),    
                  ),
                ),
                DropdownMenuItem<Locale>(
                  value: const Locale('fr', 'FR'),
                  alignment: Alignment.center,
                  child: Text(
                    'Français',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              selectedItemBuilder:
                  (BuildContext context) => [
                    Center(
                      child: Text(
                        'English',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Français',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
              onChanged: (Locale? newValue) {
                if (newValue != null) languageProvider.setLocale(newValue);
              },
            );
          },
        ),
      ),
    );
  }
}
