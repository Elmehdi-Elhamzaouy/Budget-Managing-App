// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:budget_managing/app_localizations.dart';
import 'package:budget_managing/home/presentation/widgets/ai_suggestions_card.dart';
import 'package:budget_managing/home/presentation/widgets/summary_card.dart';
import 'package:budget_managing/home/presentation/widgets/transaction_form_dialog.dart';
import 'package:budget_managing/services/ai_service.dart';
import 'package:budget_managing/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      final insight = await _aiService.analyzeSpending(
        currencySymbol,
        AppLocalizations.of(context)!.translations['aiLanguage']!,
      );
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
      {
        'name': AppLocalizations.of(context)!.translations['Food']!,
        'icon_code_point': Icons.fastfood.codePoint,
      },
      {
        'name': AppLocalizations.of(context)!.translations['Transport']!,
        'icon_code_point': Icons.directions_car.codePoint,
      },
      {
        'name': AppLocalizations.of(context)!.translations['Shopping']!,
        'icon_code_point': Icons.shopping_cart.codePoint,
      },
      {
        'name': AppLocalizations.of(context)!.translations['Salary']!,
        'icon_code_point': Icons.attach_money.codePoint,
      },
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
        title: Text(
          AppLocalizations.of(context)!.translations['Budget Manager']!,
          style: const TextStyle(color: Colors.white),
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
                  SummaryCard(
                    title:
                        AppLocalizations.of(
                          context,
                        )!.translations['Total Balance']!,
                    amount: _totalBalance,
                    icon: Icons.account_balance_wallet,
                  ),
                  SummaryCard(
                    title:
                        AppLocalizations.of(
                          context,
                        )!.translations['Total Income']!,
                    amount: _totalIncome,
                    icon: Icons.arrow_upward,
                  ),
                  SummaryCard(
                    title:
                        AppLocalizations.of(
                          context,
                        )!.translations['Total Expenses']!,
                    amount: _totalExpenses,
                    icon: Icons.arrow_downward,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      AppLocalizations.of(
                        context,
                      )!.translations['Add Transaction']!,
                      Icons.add,
                      () => _showTransactionForm(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      AppLocalizations.of(
                        context,
                      )!.translations['Generate Report']!,
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
                        ? AppLocalizations.of(
                          context,
                        )!.translations['Analyzing spending patterns...']!
                        : _aiInsights,
                onRefresh: _loadAIData,
                isLoading: _isLoadingAI,
              ),
              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translations['Recent Transactions']!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllTransactionsDialog(context),
                    child: Text(
                      AppLocalizations.of(context)!.translations['View All']!,
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
                  onTransactionUpdated: () async {
                    await _loadTransactions();
                    await _loadFinancialTotals();
                  },
                ),
              ),
            ],
          ),
        ),
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
            text.contains(RegExp(r'Add|Ajouter'))
                ? colorScheme.primary
                : colorScheme.secondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  // Shows dialog for adding new transaction
  void _showTransactionForm(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => TransactionFormDialog(
            categories: _categories,
            onSave: (transactionData) async {
              await _dbService.insertTransaction(transactionData);
              await _loadTransactions();
              await _loadFinancialTotals();
              await _loadAIData();
            },
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
            onTransactionUpdated: () async {
              await _loadTransactions();
              await _loadFinancialTotals();
            },
          ),
    );
  }
}
