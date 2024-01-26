import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlFliteDB {
  Database? _db;

  Future<Database> get database async {
      if(_db != null) return _db!;
      return await _initDB();
  }

  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, 'test.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Settlement (
        settlementId TEXT PRIMARY KEY,
        settlementName TEXT NOT NULL,
        recordDate DATETIME
      )'''
    );

    await db.execute('''
     CREATE TABLE IF NOT EXISTS Receipt (
        receiptId TEXT PRIMARY KEY,
        settlementId TEXT,
        receiptName TEXT NOT NULL,
        FOREIGN KEY(settlementId) REFERENCES Settlement(settlementId)
      )'''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ReceiptItem (
        receiptItemId TEXT PRIMARY KEY,
        receiptId TEXT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        count INTEGER NOT NULL,
        FOREIGN KEY(receiptId) REFERENCES Receipt(receiptId)
      )'''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS SettlementPaper (
          settlementPaperId TEXT PRIMARY KEY,
          settlementId TEXT,
          memberName TEXT NOT NULL,
          FOREIGN KEY(settlementId) REFERENCES Settlement(settlementId)
      )'''
    );

    await db.execute('''
    CREATE TABLE IF NOT EXISTS SettlementItem (
        settlementPaperId TEXT,
        receiptItemId TEXT,
        FOREIGN KEY(settlementPaperId) REFERENCES SettlementPaper(stmPaperId),
        FOREIGN KEY(receiptItemId) REFERENCES ReceiptItem(rcpItemId)
      )'''
    );

  }


  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
  }



}