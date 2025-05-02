import 'package:budget_managing/app_localizations.dart';
import 'package:budget_managing/currencies.dart';
import 'package:budget_managing/home/presentation/update_transaction.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllTransactionsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> Function() getTransactions;
  final List<Map<String, dynamic>> categories;
  final Function(int) onDelete;
  final VoidCallback onTransactionUpdated;

  const AllTransactionsDialog({
    super.key,
    required this.getTransactions,
    required this.categories,
    required this.onDelete,
    required this.onTransactionUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currencySymbol = currencies[themeProvider.currency]!['symbol']!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20), // Add padding around dialog
      child: ConstrainedBox(
        // Add constraints for minimum width
        constraints: const BoxConstraints(
          minWidth: 400, // Set minimum width
          maxWidth: 600, // Set maximum width
          maxHeight: 700, // Adjust max height as needed
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            final transactions = getTransactions();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(
                    AppLocalizations.of(
                      context,
                    )!.translations['All Transactions']!,
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.blue.shade700,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  // Use Expanded instead of fixed height
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              onTap:
                                  () => _navigateToUpdateScreen(
                                    context,
                                    transaction,
                                  ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
                              title: Text(
                                category['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'MMM dd',
                                ).format(DateTime.parse(transaction['date'])),
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
                                      Text(
                                        (transaction['type'] as String)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red.shade300,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      await onDelete(transaction['id'] as int);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToUpdateScreen(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UpdateTransactionScreen(
              transaction: transaction,
              categories: categories,
            ),
      ),
    ).then((_) => onTransactionUpdated()); // Update this line
  }
}
