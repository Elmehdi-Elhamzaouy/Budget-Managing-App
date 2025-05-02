import 'package:budget_managing/app_localizations.dart';
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this)!.translations[key]!;
}
