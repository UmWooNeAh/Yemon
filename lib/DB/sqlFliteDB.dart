import 'dart:async';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'modeluuid.dart';

class SqlFliteDB {
  Database? _db;
  ModelUuid _uuid = ModelUuid();

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
        RecordDate DATETIME
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
        rcpItemId TEXT PRIMARY KEY,
        receiptId TEXT,
        rcpItemName TEXT NOT NULL,
        price INTEGER NOT NULL,
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
        rcpItemId TEXT,
        FOREIGN KEY(settlementPaperId) REFERENCES SettlementPaper(settlementPaperId),
        FOREIGN KEY(rcpItemId) REFERENCES ReceiptItem(rcpItemId)
      )'''
    );
  }

  Future<void> insertStm(String stmName) async {
    var db = await database;
    await db.rawInsert('INSERT INTO Settlement(settlementId, settlementName, RecordDate) VALUES(?, ?, ?)'
        , [_uuid.randomId, stmName, DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())]);
    log("settlement insert successfully");
  }
  
  Future<void> updateStm(String newstmName, String id) async {
    var db = await database;
    await db.rawUpdate('UPDATE Settlement SET settlementName = ?, RecordDate = ? WHERE settlementId = ?'
        , [newstmName, DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), id]);
    log("update successfully");
  }
  
  Future<void> deleteStm(String id) async {
    var db = await database;
    await db.rawDelete('DELETE FROM Settlement WHERE settlementId = ?', [id]);
    log("delete successfully");
  }

  Future<void> insertRcp(String rcpName, String stmId) async {
    var db = await database;
    await db.rawInsert('INSERT INTO Receipt(receiptId, settlementId, receiptName) VALUES(?, ?, ?)'
        , [_uuid.randomId, stmId, rcpName]);
    log("receipt insert successfully");
  }
  
  Future<void> joinTest(String stmId) async {
    var db = await database;
    List<Map> result = await db.rawQuery('SELECT receiptName, settlementName FROM Settlement INNER JOIN Receipt ON ? = ?', [stmId, stmId]);
    result.forEach((row) => print(row));
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
  }



}