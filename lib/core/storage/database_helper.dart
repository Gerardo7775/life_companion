import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── 1. Categories ──────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT,
        icon_name TEXT,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // ── 2. Events ──────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER,
        start_time DATETIME NOT NULL,
        end_time DATETIME NOT NULL,
        is_all_day INTEGER DEFAULT 0,
        FOREIGN KEY(category_id) REFERENCES Categories(id) ON DELETE SET NULL
      )
    ''');

    // ── 3. Tasks ───────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER,
        due_date DATETIME,
        priority INTEGER DEFAULT 1,
        status TEXT DEFAULT 'pending',
        estimated_duration INTEGER,
        completed_at DATETIME,
        FOREIGN KEY(category_id) REFERENCES Categories(id) ON DELETE SET NULL
      )
    ''');

    // ── 4. Habits ──────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category_id INTEGER,
        frequency_type TEXT,
        frequency_data TEXT,
        time_of_day TEXT,
        reminder_time TEXT,
        target_value REAL,
        unit TEXT,
        FOREIGN KEY(category_id) REFERENCES Categories(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE HabitLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        log_date DATE NOT NULL,
        achieved_value REAL DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY(habit_id) REFERENCES Habits(id) ON DELETE CASCADE
      )
    ''');

    // ── 5. Notes ───────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        category_id INTEGER,
        related_entity_type TEXT,
        related_entity_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(category_id) REFERENCES Categories(id) ON DELETE SET NULL
      )
    ''');

    // ── 6. Alarms ──────────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        trigger_time DATETIME NOT NULL,
        type TEXT DEFAULT 'notification',
        is_recurring INTEGER DEFAULT 0,
        recurrence_rule TEXT,
        related_entity_type TEXT,
        related_entity_id INTEGER,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // ── 7. ScreenTimeLogs ──────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE ScreenTimeLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date DATE NOT NULL,
        total_minutes INTEGER DEFAULT 0,
        social_media_minutes INTEGER DEFAULT 0,
        productive_minutes INTEGER DEFAULT 0
      )
    ''');

    // ── 8. Suggestions & Motivations ──────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Suggestions_And_Motivations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        content TEXT NOT NULL,
        trigger_condition TEXT,
        min_time_available INTEGER
      )
    ''');

    // ── 9. UserStats (Singleton) ───────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE UserStats (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        level INTEGER DEFAULT 1,
        current_xp INTEGER DEFAULT 0,
        coins INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        last_active_date DATE
      )
    ''');

    await db.execute('''
      CREATE TABLE Rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        cost INTEGER NOT NULL,
        icon_name TEXT,
        is_redeemed INTEGER DEFAULT 0,
        redeemed_at DATETIME
      )
    ''');

    await db.execute('''
      CREATE TABLE XpLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_type TEXT,
        source_id INTEGER,
        xp_earned INTEGER,
        coins_earned INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ── 10. Finances ───────────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE Accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT,
        balance REAL DEFAULT 0.0,
        currency TEXT DEFAULT 'MXN'
      )
    ''');

    await db.execute('''
      CREATE TABLE FinanceCategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT,
        color_hex TEXT,
        icon_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        category_id INTEGER,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        note TEXT,
        FOREIGN KEY(account_id) REFERENCES Accounts(id) ON DELETE CASCADE,
        FOREIGN KEY(category_id) REFERENCES FinanceCategories(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount_limit REAL NOT NULL,
        period TEXT DEFAULT 'monthly',
        FOREIGN KEY(category_id) REFERENCES FinanceCategories(id) ON DELETE CASCADE
      )
    ''');

    // ── Seed Data ──────────────────────────────────────────────────────────────
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    // Categorías por defecto
    final cats = [
      {
        'name': 'Escuela',
        'color_hex': '#7C4DFF',
        'icon_name': 'school',
        'is_default': 1,
      },
      {
        'name': 'Trabajo',
        'color_hex': '#00B0FF',
        'icon_name': 'work',
        'is_default': 1,
      },
      {
        'name': 'Salud',
        'color_hex': '#00E676',
        'icon_name': 'favorite',
        'is_default': 1,
      },
      {
        'name': 'Personal',
        'color_hex': '#FF6D00',
        'icon_name': 'person',
        'is_default': 1,
      },
      {
        'name': 'Finanzas',
        'color_hex': '#FFD740',
        'icon_name': 'attach_money',
        'is_default': 1,
      },
    ];
    for (final c in cats) {
      await db.insert('Categories', c);
    }

    // UserStats inicial
    await db.insert('UserStats', {
      'id': 1,
      'level': 1,
      'current_xp': 0,
      'coins': 0,
      'current_streak': 0,
      'last_active_date': DateTime.now().toIso8601String().substring(0, 10),
    });

    // Cuenta por defecto
    await db.insert('Accounts', {
      'name': 'Efectivo',
      'type': 'cash',
      'balance': 0.0,
      'currency': 'MXN',
    });
    await db.insert('Accounts', {
      'name': 'Tarjeta de Débito',
      'type': 'bank',
      'balance': 0.0,
      'currency': 'MXN',
    });

    // Categorías financieras por defecto
    final finCats = [
      {
        'name': 'Comida',
        'type': 'expense',
        'color_hex': '#FF6D00',
        'icon_name': 'restaurant',
      },
      {
        'name': 'Transporte',
        'type': 'expense',
        'color_hex': '#00B0FF',
        'icon_name': 'directions_car',
      },
      {
        'name': 'Entretenimiento',
        'type': 'expense',
        'color_hex': '#7C4DFF',
        'icon_name': 'sports_esports',
      },
      {
        'name': 'Salud',
        'type': 'expense',
        'color_hex': '#00E676',
        'icon_name': 'local_hospital',
      },
      {
        'name': 'Sueldo',
        'type': 'income',
        'color_hex': '#FFD740',
        'icon_name': 'payments',
      },
      {
        'name': 'Freelance',
        'type': 'income',
        'color_hex': '#64FFDA',
        'icon_name': 'laptop',
      },
    ];
    for (final fc in finCats) {
      await db.insert('FinanceCategories', fc);
    }

    // Recompensas de ejemplo
    final rewards = [
      {
        'title': 'Café especial',
        'description': 'Date un café premium que te mereces',
        'cost': 50,
        'icon_name': 'coffee',
      },
      {
        'title': '1 hora de videojuegos',
        'description': 'Tiempo de relax sin culpa',
        'cost': 80,
        'icon_name': 'sports_esports',
      },
      {
        'title': 'Serie/Película',
        'description': '2 horas de tu serie favorita',
        'cost': 120,
        'icon_name': 'movie',
      },
      {
        'title': 'Salida con amigos',
        'description': 'Ya te lo ganaste, ¡sal y disfruta!',
        'cost': 300,
        'icon_name': 'people',
      },
    ];
    for (final r in rewards) {
      await db.insert('Rewards', r);
    }

    // Sugerencias motivacionales
    final suggestions = [
      {
        'type': 'quote',
        'content':
            'La disciplina es hacer lo que necesitas hacer, aunque no quieras.',
        'trigger_condition': 'general',
        'min_time_available': 0,
      },
      {
        'type': 'quote',
        'content':
            'El éxito es la suma de pequeños esfuerzos repetidos día tras día.',
        'trigger_condition': 'general',
        'min_time_available': 0,
      },
      {
        'type': 'action',
        'content':
            '¡Tienes tiempo libre! Avanza 15 minutos en una tarea pendiente.',
        'trigger_condition': 'free_time',
        'min_time_available': 15,
      },
      {
        'type': 'action',
        'content':
            'Perfecto para una caminata rápida o estiramiento de 10 minutos.',
        'trigger_condition': 'free_time',
        'min_time_available': 10,
      },
      {
        'type': 'warning',
        'content':
            'Llevas mucho tiempo en pantalla. ¿Qué tal un descanso de 5 minutos?',
        'trigger_condition': 'high_screen_time',
        'min_time_available': 5,
      },
    ];
    for (final s in suggestions) {
      await db.insert('Suggestions_And_Motivations', s);
    }
  } // fin _seedDefaultData

  // ── Migration v2: Nuevas tablas de Productividad ─────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createProductivityTables(db);
    if (oldVersion < 3) await _createWellnessTables(db);
  }


  Future<void> _createProductivityTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PomodoroSessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        task_title TEXT,
        duration_minutes INTEGER NOT NULL,
        session_type TEXT DEFAULT 'work',
        is_completed INTEGER DEFAULT 0,
        started_at DATETIME NOT NULL,
        completed_at DATETIME
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        icon_name TEXT,
        color_hex TEXT DEFAULT '#7C4DFF',
        target_date DATETIME,
        is_completed INTEGER DEFAULT 0,
        created_at DATETIME NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS GoalItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        linked_id INTEGER,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY(goal_id) REFERENCES Goals(id) ON DELETE CASCADE
      )
    ''');
  } // fin _createProductivityTables

  Future<void> _createWellnessTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS MoodLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood_score INTEGER NOT NULL,
        mood_emoji TEXT NOT NULL,
        tags TEXT,
        note TEXT,
        logged_at DATETIME NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS JournalEntries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood_log_id INTEGER,
        mood_score INTEGER,
        mood_emoji TEXT,
        tags TEXT,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL
      )
    ''');
  }
}
