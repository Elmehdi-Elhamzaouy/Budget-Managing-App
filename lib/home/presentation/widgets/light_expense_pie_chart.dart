import 'package:budget_managing/home/presentation/widgets/expense_pie_chart.dart';
import 'package:flutter/material.dart';
// Removed incorrect import as it does not exist

class LightExpensePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> transactions;

  const LightExpensePieChart({
    super.key,
    required this.categories,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Theme(
        data: ThemeData.light(),
        child: Builder(
          builder: (context) {
            return ExpensePieChart(
              categories: categories,
              transactions: transactions,
              chartColors: _getLightChartColors(),
            );
          },
        ),
      ),
    );
  }
  List<Color> _getLightChartColors() {
    return [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
      Colors.purple.shade600,
    ];
  }
}