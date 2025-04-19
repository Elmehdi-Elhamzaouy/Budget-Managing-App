import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllTransactionsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> categories;
  final Function(int) onDelete;

  const AllTransactionsDialog({
    super.key,
    required this.transactions,
    required this.categories,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text(
              'All Transactions',
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.9,
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

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
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
                      title: Text(category['name']),
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
                                '\$${transaction['amount'].toStringAsFixed(2)}',
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
                                (transaction['type'] as String).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
