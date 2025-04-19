import 'package:budget_managing/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final String selectedType;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> categories;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final Function(DateTime) onDateChanged;
  final Function(String) onTypeChanged;
  final Function(int?) onCategoryChanged;
  final VoidCallback onSubmit;

  const TransactionForm({
    super.key,
    required this.selectedType,
    required this.selectedDate,
    required this.categories,
    required this.amountController,
    required this.notesController,
    required this.onDateChanged,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.selectedType.capitalize()}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.selectedType,
              items:
                  ['expense', 'income']
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.capitalize()),
                        ),
                      )
                      .toList(),
              onChanged: (value) => widget.onTypeChanged(value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value:
                  widget.categories.isNotEmpty
                      ? widget.categories.first['id']
                      : null,
              hint: const Text('Select Category'),
              items:
                  widget.categories
                      .map(
                        (category) => DropdownMenuItem<int>(
                          value: category['id'] as int,
                          child: Row(
                            children: [
                              Icon(
                                IconData(
                                  category['icon_code_point'],
                                  fontFamily: 'MaterialIcons',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(category['name']),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              onChanged: widget.onCategoryChanged,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(DateFormat.yMd().format(widget.selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: widget.selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  widget.onDateChanged(date);
                }
              },
            ),
            TextField(
              controller: widget.notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit();
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
