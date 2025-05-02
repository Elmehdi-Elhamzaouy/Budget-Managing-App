import 'package:budget_managing/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_managing/services/database_service.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:budget_managing/currencies.dart';
import 'package:intl/intl.dart';

class UpdateTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final List<Map<String, dynamic>> categories;

  const UpdateTransactionScreen({
    super.key,
    required this.transaction,
    required this.categories,
  });

  @override
  State<UpdateTransactionScreen> createState() =>
      _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _selectedType;
  late int? _selectedCategoryId;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction['amount'].toString(),
    );
    _notesController = TextEditingController(
      text: widget.transaction['notes'] ?? '',
    );
    _selectedDate = DateTime.parse(widget.transaction['date']);
    _selectedType = widget.transaction['type'];
    _selectedCategoryId = widget.transaction['category_id'];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateTransaction() async {
    try {
      final updatedTransaction = {
        'amount': double.parse(_amountController.text),
        'type': _selectedType,
        'category_id': _selectedCategoryId,
        'date': _selectedDate.toIso8601String(),
        'notes': _notesController.text.trim(),
      };

      await _dbService.updateTransaction(
        widget.transaction['id'] as int,
        updatedTransaction,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // Return success flag
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update transaction')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencySymbol = currencies[themeProvider.currency]!['symbol']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translations['Edit Transaction']!,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateTransaction,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translations['Amount']!,
                  prefixText: '$currencySymbol ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translations['type']!,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'income',
                    child: Text(
                      'Income',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text(
                      'Expense',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translations['Category']!,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    widget.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'] as int,
                        child: Row(
                          children: [
                            Icon(
                              IconData(
                                category['icon_code_point'],
                                fontFamily: 'MaterialIcons',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category['name'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _selectedCategoryId = value),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _selectDate(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(DateFormat.yMd().format(_selectedDate)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translations['Notes']!,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
