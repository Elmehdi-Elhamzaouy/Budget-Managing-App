import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _version = 2;
  static const _dbName = 'budget_app.db';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_code_point INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL CHECK(amount > 0),
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        date DATETIME NOT NULL,
        notes TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    ''');

    await _createIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS categories');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_transactions_date 
      ON transactions(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category 
      ON transactions(category_id)
    ''');
  }

  // Transaction Operations
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    _validateTransaction(transaction);

    return await db.transaction((txn) async {
      return await txn.insert(
        'transactions',
        transaction,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    final db = await database;
    return await db.query(
      'transactions',
      limit: limit,
      offset: offset,
      orderBy: orderBy ?? 'date ${descending ? 'DESC' : 'ASC'}',
      columns: ['id', 'amount', 'type', 'date', 'notes', 'category_id'],
    );
  }

  Future<int> updateTransaction(int id, Map<String, dynamic> data) async {
    final db = await database;
    _validateTransaction(data);

    return await db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Category Operations
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    _validateCategory(category);

    return await db.insert(
      'categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query(
      'categories',
      columns: ['id', 'name', 'icon_code_point'],
    );
  }

  Future<int> updateCategory(int id, Map<String, dynamic> data) async {
    final db = await database;
    _validateCategory(data);

    return await db.update(
      'categories',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Helper Methods
  void _validateTransaction(Map<String, dynamic> transaction) {
    if (transaction['amount'] == null ||
        transaction['category_id'] == null ||
        transaction['type'] == null ||
        transaction['date'] == null) {
      throw ArgumentError('Missing required transaction fields');
    }

    if (transaction['type'] != 'income' && transaction['type'] != 'expense') {
      throw ArgumentError('Invalid transaction type');
    }
  }

  void _validateCategory(Map<String, dynamic> category) {
    if (category['name'] == null || category['icon_code_point'] == null) {
      throw ArgumentError('Missing required category fields');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Advanced Queries
  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(
        CASE 
          WHEN type = 'income' THEN amount 
          ELSE -amount 
        END
      ) as balance FROM transactions
    ''');
    return result.first['balance'] as double? ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByCategory(
    int categoryId,
  ) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = "income"',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = "expense"',
    );
    return result.first['total'] as double? ?? 0.0;
  }
}
