import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Add all your translations here
  Map<String, String> get translations {
    switch (locale.languageCode) {
      case 'fr':
        return frTranslations;
      default: // English as default
        return enTranslations;
    }
  }

  static final Map<String, String> enTranslations = {
    'Settings': 'Settings',
    'Currency': 'Currency',
    'Language': 'Language',
    'Dark Mode': 'Dark Mode',
    'Budget Manager': 'Budget Manager',
    'Total Balance': 'Total Balance',
    'Total Income': 'Total Income',
    'Total Expenses': 'Total Expenses',
    'Income': 'Income',
    'Expenses': 'Expenses',
    'Add Transaction': 'Add Transaction',
    'Generate Report': 'Generate Report',
    'Spending Breakdown': 'Spending Breakdown',
    'Smart Financial Tip': 'Smart Financial Tip',
    'Powered by AI Gemini': 'Powered by AI Gemini',
    'Food': 'Food',
    'Transport': 'Transport',
    'Shopping': 'Shopping',
    'Salary': 'Salary',
    'Amount': 'Amount',
    'type': 'Type',
    'Category': 'Category',
    'date': 'Date',
    'Notes': 'Notes',
    'Add': 'Add',
    'Cancel': 'Cancel',
    'Recent Transactions': 'Recent Transactions',
    'View All': 'View All',
    'All Transactions': 'All Transactions',
    'Analyzing spending patterns...': 'Analyzing spending patterns...',
    'aiLanguage': 'english',
    'Budget Manager Report': 'Budget Manager Report',
    'Edit Transaction': 'Edit Transaction',
    'update_failed': 'Update failed',
    'Financial Summary': 'Financial Summary',
    // Add more English translations
  };

  static final Map<String, String> frTranslations = {
    'Settings': 'Paramètres',
    'Currency': 'Devise',
    'Language': 'Langue',
    'Dark Mode': 'Mode sombre',
    'Budget Manager': 'Gestionnaire de budget',
    'Total Balance': 'Solde total',
    'Total Income': 'Revenu total',
    'Total Expenses': 'Dépenses totales',
    'Income': 'Revenu',
    'Expenses': 'Dépenses',
    'Add Transaction': 'Ajouter transaction',
    'Generate Report': 'Générer un rapport',
    'Spending Breakdown': 'Répartition des dépenses',
    'Smart Financial Tip': 'Astuce financière intelligente',
    'Powered by AI Gemini': 'Propulsé par AI Gemini',
    'Food': 'Nourriture',
    'Transport': 'Transport',
    'Shopping': 'Shopping',
    'Salary': 'Salaire',
    'Amount': 'Montant',
    'type': 'Type',
    'Category': 'Catégorie',
    'date': 'Date',
    'Notes': 'Remarques',
    'Add': 'Ajouter',
    'Cancel': 'Annuler',
    'Recent Transactions': 'Transactions récentes',
    'View All': 'Voir tout',
    'All Transactions': 'Toutes les transactions',
    'Analyzing spending patterns...': 'Analyse des habitudes de dépenses...',
    'aiLanguage': 'french',
    'Budget Manager Report': 'Rapport du gestionnaire de budget',
    'Edit Transaction': 'Modifier la transaction',
    'update_failed': 'Échec de la mise à jour',
    'Financial Summary': 'Résumé financier',
    // Add more French translations
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
