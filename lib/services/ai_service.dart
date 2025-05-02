import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';

class AIService {
  final DatabaseService _dbService;
  final GenerativeModel _model;

  static final _apiKey = dotenv.env['GEMINI_API_KEY']!;

  AIService(this._dbService)
    : _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

  Future<String> analyzeSpending(
    String currencySymbol,
    String aiLanguage
  ) async {
    try {
      final transactions = await _dbService.getTransactions();
      final categories = await _dbService.getCategories();

      // Calculate totals with proper formatting
      double totalIncome = 0;
      double totalExpenses = 0;
      final List<String> transactionsList = [];

      for (final t in transactions) {
        final category = categories.firstWhere(
          (c) => c['id'] == t['category_id'],
          orElse: () => {'name': 'Unknown'},
        );

        final amount = (t['amount'] as double).toStringAsFixed(2);
        final type = t['type'] as String;

        if (type == 'income') {
          totalIncome += t['amount'];
        } else {
          totalExpenses += t['amount'];
        }

        transactionsList.add(
          '${DateFormat('MMM dd').format(DateTime.parse(t['date']))} - '
          '${category['name']}: '
          '$currencySymbol$amount ($type)',
        );
      }

      final prompt = '''
      Analyze these financial transactions:
      ${transactionsList.join('\n')}

      Total Income: $currencySymbol ${totalIncome.toStringAsFixed(2)}
      Total Expenses: $currencySymbol ${totalExpenses.toStringAsFixed(2)}

      Provide a concise, friendly financial summary focusing on:
      1. Whether income exceeds expenses
      2. One practical saving suggestion
      3. One positive reinforcement

      Keep it under 3 sentences and avoid technical terms.
      Example: "Great news! Your income exceeded expenses this month by $currencySymbol X. 
      Consider saving 20% of the difference. Keep up the good financial habits! Give the answer in $aiLanguage."
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return _cleanResponse(response.text);
    } catch (e) {
      return 'Financial insights unavailable currently. Please try again later.';
    }
  }

  String _cleanResponse(String? text) {
    final response = text?.replaceAll('*', '') ?? '';
    return response.isEmpty
        ? 'Your finances look stable this month. Keep tracking for better insights!'
        : response;
  }
}
