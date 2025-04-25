// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:budget_managing/helpers/extensions.dart';
import 'package:budget_managing/home/presentation/widgets/ai_suggestions_card.dart';
import 'package:budget_managing/services/ai_service.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../services/database_service.dart';
import '../../services/pdf_service.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/transaction_list.dart';
import '../dialogs/all_transactions.dart';
import 'package:provider/provider.dart';
import 'package:budget_managing/currencies.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers for user input
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Services for database operations and global key for pie chart
  final DatabaseService _dbService = DatabaseService();
  final GlobalKey _pieChartKey = GlobalKey();

  // State variables for transactions and categories
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _categories = [];

  // Transaction form state
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  int? _selectedCategoryId;

  // Financial summary variables
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  // AI service for spending analysis
  final _aiService = AIService(DatabaseService());
  String _aiInsights = '';
  bool _isLoadingAI = false;

  @override
  void initState() {
    super.initState();
    // Load initial data and AI insights when screen is created
    _loadData().then((_) => _loadAIData());
  }

  // Main data loading function that coordinates loading of all necessary data
  Future<void> _loadData() async {
    await _loadCategories();
    await _loadTransactions();
    await _loadFinancialTotals();
  }

  // Loads AI-generated spending insights
  Future<void> _loadAIData() async {
    final currencySymbol =
        currencies[Provider.of<ThemeProvider>(
          context,
          listen: false,
        ).currency]!['symbol']!;
    if (mounted) setState(() => _isLoadingAI = true);
    try {
      final insight = await _aiService.analyzeSpending(currencySymbol);
      if (mounted) {
        setState(() {
          _aiInsights = insight;
          _isLoadingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiInsights = 'Could not refresh insights: ${e.toString()}';
          _isLoadingAI = false;
        });
      }
    }
  }

  // Updates financial summary totals from database
  Future<void> _loadFinancialTotals() async {
    final balance = await _dbService.getTotalBalance();
    final income = await _dbService.getTotalIncome();
    final expenses = await _dbService.getTotalExpenses();
    setState(() {
      _totalBalance = balance;
      _totalIncome = income;
      _totalExpenses = expenses.abs();
    });
  }

  // Fetches all transactions from database
  Future<void> _loadTransactions() async {
    final transactions = await _dbService.getTransactions();
    setState(() => _transactions = transactions);
  }

  // Loads categories and creates defaults if none exist
  Future<void> _loadCategories() async {
    final categories = await _dbService.getCategories();
    if (categories.isEmpty) {
      await _initializeDefaultCategories();
      await _loadCategories();
      return;
    }
    setState(() => _categories = categories);
  }

  // Creates default categories for first-time app usage
  Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      {'name': 'Food', 'icon_code_point': Icons.fastfood.codePoint},
      {'name': 'Transport', 'icon_code_point': Icons.directions_car.codePoint},
      {'name': 'Shopping', 'icon_code_point': Icons.shopping_cart.codePoint},
      {'name': 'Salary', 'icon_code_point': Icons.attach_money.codePoint},
    ];
    for (final category in defaultCategories) {
      await _dbService.insertCategory(category);
    }
  }

  // Captures pie chart widget as image for PDF export
  Future<Uint8List> _capturePieChartImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _pieChartKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData!.buffer.asUint8List();
    } catch (e) {
      return Uint8List(0);
    }
  }

  // Generates and shares PDF report of financial data
  Future<void> _generateAndSharePdf() async {
    try {
      final image = await _capturePieChartImage();
      final pdf = await PdfService.generatePdfDocument(
        totalBalance: _totalBalance,
        totalIncome: _totalIncome,
        totalExpenses: _totalExpenses,
        transactions: _transactions,
        categories: _categories,
        pieChartImage: image,
      );
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'budget-report-${DateTime.now().toIso8601String()}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to generate PDF')));
    }
  }

  // Creates new transaction from form data
  Future<void> _addTransaction() async {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) return;

    final transaction = {
      'amount': double.parse(_amountController.text),
      'type': _selectedType,
      'category_id': _selectedCategoryId,
      'date': _selectedDate.toIso8601String(),
      'notes': _notesController.text.trim(),
    };

    await _dbService.insertTransaction(transaction);
    await _loadTransactions();
    await _loadFinancialTotals();
    await _loadAIData();

    _amountController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();
    _selectedCategoryId = null;
  }

  // Removes transaction and updates totals
  Future<void> _deleteTransaction(int id) async {
    await _dbService.deleteTransaction(id);
    await _loadTransactions();
    await _loadFinancialTotals();
    await _loadAIData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Budget Manager',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFinancialTotals,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard(
                    'Total Balance',
                    _totalBalance,
                    Icons.account_balance_wallet,
                  ),
                  _buildSummaryCard(
                    'Total Income',
                    _totalIncome,
                    Icons.arrow_upward,
                  ),
                  _buildSummaryCard(
                    'Total Expenses',
                    _totalExpenses,
                    Icons.arrow_downward,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Add Transaction',
                      Icons.add,
                      () => _showTransactionForm(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Generate Report',
                      Icons.picture_as_pdf,
                      _generateAndSharePdf,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),
              ExpensePieChart(
                repaintKey: _pieChartKey,
                categories: _categories,
                transactions: _transactions,
                chartColors: [],
              ),
              const SizedBox(height: 24),

              AISuggestionsCard(
                insight:
                    _isLoadingAI
                        ? 'Analyzing spending patterns...'
                        : _aiInsights,
                onRefresh: _loadAIData,
                isLoading: _isLoadingAI,
              ),
              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllTransactionsDialog(context),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200, // Fixed height to prevent overflow
                child: TransactionList(
                  transactions: _transactions,
                  categories: _categories,
                  onDelete: _deleteTransaction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Creates a summary card for displaying financial totals
  Widget _buildSummaryCard(String title, double amount, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currencySymbol = currencies[themeProvider.currency]!['symbol']!;

    return Container(
      width: 115,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$currencySymbol ${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // Creates a styled action button
  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      icon: Icon(icon, color: colorScheme.onPrimary),
      label: Text(text, style: TextStyle(color: colorScheme.onPrimary)),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            text.contains('Add') ? colorScheme.primary : colorScheme.secondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  // Shows dialog for adding new transaction
  void _showTransactionForm(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currencySymbol = currencies[themeProvider.currency]!['symbol']!;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.zero,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(
                      'Add ${_selectedType.capitalize()}',
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
                              labelText: 'Amount',
                              prefixText: '$currencySymbol ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged:
                                (value) =>
                                    setState(() => _selectedType = value!),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            items:
                                _categories.map((category) {
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
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(
                                      color: Colors.blue.shade700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
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
                                    _addTransaction();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Shows dialog with all transactions
  void _showAllTransactionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AllTransactionsDialog(
            getTransactions: () => _transactions, // Pass current transactions
            categories: _categories,
            onDelete: (int id) async {
              await _deleteTransaction(id);
            },
          ),
    );
  }
}
