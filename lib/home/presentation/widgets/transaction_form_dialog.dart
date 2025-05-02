import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budget_managing/app_localizations.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:budget_managing/currencies.dart';

class TransactionFormDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic>) onSave;

  const TransactionFormDialog({
    super.key,
    required this.categories,
    required this.onSave,
  });

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  int? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currencySymbol = currencies[themeProvider.currency]!['symbol']!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.zero,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(
                AppLocalizations.of(context)!.translations['Add Transaction']!,
                style: const TextStyle(color: Colors.white),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translations['Amount']!,
                        prefixText: '$currencySymbol ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items:
                          ['expense', 'income'].map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type.capitalize(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => _selectedType = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translations['Category']!,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => _selectedCategoryId = value),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.blue.shade700),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.yMd().format(_selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(
                              context,
                            )!.translations['Notes']!,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.blue.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.translations['Cancel']!,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_amountController.text.isEmpty ||
                                  _selectedCategoryId == null) {
                                return;
                              }

                              widget.onSave({
                                'amount': double.parse(_amountController.text),
                                'type': _selectedType,
                                'category_id': _selectedCategoryId,
                                'date': _selectedDate.toIso8601String(),
                                'notes': _notesController.text.trim(),
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.translations['Add']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
