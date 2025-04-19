import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> transactions;
  final Key? repaintKey;
  final List<Color> categoryColors = const [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.brown,
  ];

  const ExpensePieChart({
    super.key,
    required this.categories,
    required this.transactions,
    this.repaintKey, required List<Color> chartColors,
  });

  Map<int, double> _getExpensesByCategory() {
    final Map<int, double> expensesByCategory = {};
    for (final transaction in transactions) {
      if (transaction['type'] == 'expense') {
        final categoryId = transaction['category_id'] as int;
        expensesByCategory[categoryId] =
            (expensesByCategory[categoryId] ?? 0) +
            (transaction['amount'] as double);
      }
    }
    return expensesByCategory;
  }

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = _getExpensesByCategory();
    final totalExpenses = expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final categoryIds = expensesByCategory.keys.toList();

    return RepaintBoundary(
      key: repaintKey,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Spending Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 140,
                width: 340,
                child: _buildChartContent(
                  expensesByCategory,
                  totalExpenses,
                  categoryIds,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent(
    Map<int, double> expensesByCategory,
    double totalExpenses,
    List<int> categoryIds,
  ) {
    if (expensesByCategory.isEmpty) {
      return const Center(child: Text('No expenses to show'));
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections:
                  categoryIds.map((categoryId) {
                    final amount = expensesByCategory[categoryId]!;
                    final colorIndex = (categoryId - 1) % categoryColors.length;
                    final color = categoryColors[colorIndex];
                    return PieChartSectionData(
                      value: amount,
                      title:
                          '${(amount / totalExpenses * 100).toStringAsFixed(1)}%',
                      color: color,
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
              centerSpaceRadius: 30,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    categoryIds.map((categoryId) {
                      final category = categories.firstWhere(
                        (c) => c['id'] == categoryId,
                        orElse: () => {'name': 'Unknown'},
                      );
                      final colorIndex =
                          (categoryId - 1) % categoryColors.length;
                      final color = categoryColors[colorIndex];
                      final percentage = (expensesByCategory[categoryId]! /
                              totalExpenses *
                              100)
                          .toStringAsFixed(1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${category['name']} ($percentage%)',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
