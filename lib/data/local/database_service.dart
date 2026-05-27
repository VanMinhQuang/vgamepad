import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const databaseName = 'gamepad_config.db';
  static const databaseVersion = 1;

  static const layoutTable = 'gamepad_layouts';
  static const buttonTable = 'button_layouts';

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null) return current;

    final databaseDir = await getDatabasesPath();
    await Directory(databaseDir).create(recursive: true);
    final dbPath = p.join(databaseDir, databaseName);
    return _database = await openDatabase(
      dbPath,
      version: databaseVersion,
      onCreate: _create,
    );
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $layoutTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $buttonTable (
        layout_id INTEGER NOT NULL,
        id TEXT NOT NULL,
        label TEXT NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        width REAL NOT NULL,
        height REAL NOT NULL,
        PRIMARY KEY (layout_id, id)
      )
    ''');
  }
}
