import 'package:google_generative_ai/google_generative_ai.dart';
import 'database_service.dart';

class AIService {
  final DatabaseService _dbService;
  final GenerativeModel _model;

  static const String _apiKey = 'AIzaSyCi3hL4gvxSdXjvd8xq4lxYRVX7_gWkd4g';

  AIService(this._dbService)
    : _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

  Future<String> analyzeSpending() async {
    try {
      final transactions = await _dbService.getTransactions();

      // Calculate totals
      double totalIncome = 0;
      double totalExpenses = 0;
      final List<String> transactionsList = [];

      for (final t in transactions) {
        if (t['type'] == 'income') {
          totalIncome += t['amount'];
        } else {
          totalExpenses += t['amount'];
        }
        transactionsList.add(
          '${t['date']} - ${t['category']}: \$${t['amount']} (${t['type']})',
        );
      }

      final prompt = '''
      Analyze these financial transactions:
      ${transactionsList.join('\n')}

      Total Income: \$$totalIncome
      Total Expenses: \$$totalExpenses

      Provide a concise, friendly financial summary focusing on:
      1. Whether income exceeds expenses
      2. One practical saving suggestion
      3. One positive reinforcement

      Keep it under 3 sentences and avoid technical terms.
      Example: "Great news! Your income exceeded expenses this month by \$X. 
      Consider saving 20% of the difference. Keep up the good financial habits!"
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
