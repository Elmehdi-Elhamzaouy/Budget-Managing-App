import 'package:budget_managing/currencies.dart';
import 'package:budget_managing/home/presentation/update_transaction.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> categories;
  final Function(int) onDelete;
  final VoidCallback onTransactionUpdated;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.onDelete,
    required this.onTransactionUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currencySymbol = currencies[themeProvider.currency]!['symbol']!;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final category = categories.firstWhere(
          (c) => c['id'] == transaction['category_id'],
          orElse:
              () => {
                'name': 'Unknown',
                'icon_code_point': Icons.error.codePoint,
              },
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            onTap: () => _navigateToUpdateScreen(context, transaction),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            tileColor: Theme.of(context).colorScheme.surface,
            textColor: Theme.of(context).colorScheme.onSurface,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconData(
                  category['icon_code_point'],
                  fontFamily: 'MaterialIcons',
                ),
                size: 20,
                color: Colors.blue.shade700,
              ),
            ),
            title: Text(category['name']),
            subtitle: Text(
              DateFormat('MMM dd').format(DateTime.parse(transaction['date'])),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currencySymbol ${transaction['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            transaction['type'] == 'income'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                  onPressed: () => onDelete(transaction['id'] as int),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // In TransactionList widget
  void _navigateToUpdateScreen(
    BuildContext context, 
    Map<String, dynamic> transaction
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTransactionScreen(
          transaction: transaction,
          categories: categories,
        ),
      ),
    ).then((_) => onTransactionUpdated()); // Update this line
  }
}
