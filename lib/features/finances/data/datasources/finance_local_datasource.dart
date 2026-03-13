import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/finance_entities.dart';

class FinanceLocalDataSource {
  final DatabaseHelper dbHelper;
  FinanceLocalDataSource(this.dbHelper);

  Future<List<AccountEntity>> getAccounts() async {
    final db = await dbHelper.database;
    final maps = await db.query('Accounts');
    return maps
        .map(
          (m) => AccountEntity(
            id: m['id'] as int?,
            name: m['name'] as String,
            type: m['type'] as String? ?? 'cash',
            balance: (m['balance'] as num?)?.toDouble() ?? 0,
            currency: m['currency'] as String? ?? 'MXN',
          ),
        )
        .toList();
  }

  Future<List<FinanceCategoryEntity>> getCategories({String? type}) async {
    final db = await dbHelper.database;
    final maps = type != null
        ? await db.query(
            'FinanceCategories',
            where: 'type = ?',
            whereArgs: [type],
          )
        : await db.query('FinanceCategories');
    return maps
        .map(
          (m) => FinanceCategoryEntity(
            id: m['id'] as int?,
            name: m['name'] as String,
            type: m['type'] as String? ?? 'expense',
            colorHex: m['color_hex'] as String?,
            iconName: m['icon_name'] as String?,
          ),
        )
        .toList();
  }

  Future<List<TransactionEntity>> getTransactions({int? limit}) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT t.*, a.name as account_name, fc.name as cat_name, fc.color_hex as cat_color
      FROM Transactions t
      LEFT JOIN Accounts a ON t.account_id = a.id
      LEFT JOIN FinanceCategories fc ON t.category_id = fc.id
      ORDER BY t.date DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');
    return maps
        .map(
          (m) => TransactionEntity(
            id: m['id'] as int?,
            accountId: m['account_id'] as int,
            accountName: m['account_name'] as String? ?? '',
            categoryId: m['category_id'] as int?,
            categoryName: m['cat_name'] as String?,
            categoryColor: m['cat_color'] as String?,
            amount: (m['amount'] as num).toDouble(),
            type: m['type'] as String,
            date: DateTime.parse(m['date'] as String),
            note: m['note'] as String?,
          ),
        )
        .toList();
  }

  Future<TransactionEntity> insertTransaction(TransactionEntity tx) async {
    final db = await dbHelper.database;
    final id = await db.insert('Transactions', {
      'account_id': tx.accountId,
      'category_id': tx.categoryId,
      'amount': tx.amount,
      'type': tx.type,
      'date': tx.date.toIso8601String(),
      'note': tx.note,
    });
    // Update account balance
    final delta = tx.type == 'income' ? tx.amount : -tx.amount;
    await db.rawUpdate(
      'UPDATE Accounts SET balance = balance + ? WHERE id = ?',
      [delta, tx.accountId],
    );
    return TransactionEntity(
      id: id,
      accountId: tx.accountId,
      amount: tx.amount,
      type: tx.type,
      date: tx.date,
      note: tx.note,
    );
  }

  Future<double> getTotalBalance() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM Accounts',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getMonthSummary() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final result = await db.rawQuery(
      '''
      SELECT type, SUM(amount) as total FROM Transactions
      WHERE date >= ? GROUP BY type
    ''',
      [startOfMonth],
    );
    double income = 0, expense = 0;
    for (final row in result) {
      if (row['type'] == 'income') {
        income = (row['total'] as num?)?.toDouble() ?? 0;
      }
      if (row['type'] == 'expense') {
        expense = (row['total'] as num?)?.toDouble() ?? 0;
      }
    }
    return {'income': income, 'expense': expense};
  }

  Future<List<BudgetEntity>> getBudgets() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final maps = await db.rawQuery(
      '''
      SELECT b.*, fc.name as cat_name, fc.color_hex as cat_color,
             COALESCE((SELECT SUM(t.amount) FROM Transactions t
                       WHERE t.category_id = b.category_id
                       AND t.type = 'expense' AND t.date >= ?), 0) as spent
      FROM Budgets b
      LEFT JOIN FinanceCategories fc ON b.category_id = fc.id
    ''',
      [startOfMonth],
    );
    return maps
        .map(
          (m) => BudgetEntity(
            id: m['id'] as int?,
            categoryId: m['category_id'] as int,
            categoryName: m['cat_name'] as String?,
            categoryColor: m['cat_color'] as String?,
            amountLimit: (m['amount_limit'] as num).toDouble(),
            amountSpent: (m['spent'] as num?)?.toDouble() ?? 0,
            period: m['period'] as String? ?? 'monthly',
          ),
        )
        .toList();
  }
}
