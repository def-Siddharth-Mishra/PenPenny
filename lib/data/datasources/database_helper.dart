import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'penpenny.db';
  static const int _databaseVersion = 2;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      return await databaseFactory.openDatabase(
        _databaseName,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      String databasesPath = await getDatabasesPath();
      String dbPath = join(databasesPath, _databaseName);
      return await openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        holderName TEXT,
        accountNumber TEXT,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        isDefault INTEGER DEFAULT 0,
        balance REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        budget REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        account INTEGER NOT NULL,
        category INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        datetime TEXT NOT NULL,
        FOREIGN KEY (account) REFERENCES accounts (id),
        FOREIGN KEY (category) REFERENCES categories (id)
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add balance column to accounts table
      await db.execute('ALTER TABLE accounts ADD COLUMN balance REAL DEFAULT 0.0');
    }
  }

  static Future<void> _insertDefaultData(Database db) async {
    // Insert default account
    await db.insert('accounts', {
      'name': 'Cash',
      'holderName': '',
      'accountNumber': '',
      'icon': Icons.wallet.codePoint,
      'color': Colors.teal.value,
      'isDefault': 1,
      'balance': 0.0,
    });

    // Insert default categories
    final categories = [
      {'name': 'Housing', 'icon': Icons.house.codePoint, 'color': Colors.blue.value},
      {'name': 'Transportation', 'icon': Icons.emoji_transportation.codePoint, 'color': Colors.green.value},
      {'name': 'Food', 'icon': Icons.restaurant.codePoint, 'color': Colors.orange.value},
      {'name': 'Utilities', 'icon': Icons.category.codePoint, 'color': Colors.purple.value},
      {'name': 'Insurance', 'icon': Icons.health_and_safety.codePoint, 'color': Colors.red.value},
      {'name': 'Medical & Healthcare', 'icon': Icons.medical_information.codePoint, 'color': Colors.pink.value},
      {'name': 'Saving & Investing', 'icon': Icons.attach_money.codePoint, 'color': Colors.indigo.value},
      {'name': 'Personal Spending', 'icon': Icons.shopping_bag.codePoint, 'color': Colors.cyan.value},
      {'name': 'Recreation & Entertainment', 'icon': Icons.tv.codePoint, 'color': Colors.amber.value},
      {'name': 'Miscellaneous', 'icon': Icons.library_books_sharp.codePoint, 'color': Colors.brown.value},
    ];

    for (final category in categories) {
      await db.insert('categories', category);
    }
  }

  static Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('payments');
    await db.delete('accounts');
    await db.delete('categories');
    await _insertDefaultData(db);
  }
}