import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'modeluuid.dart';

class DBSettlementPaper {

  ModelUuid _uuid = ModelUuid();

  DBSettlementPaper();

  Future<int> createStmPaper(Database db, String stmId, String memberName) async {
    return await db!.rawInsert('INSERT INTO SettlementPaper(settlementPaperId, settlementId, memberName) VALUES(?,?,?)'
    ,[_uuid.randomId, stmId, memberName]);
  }

  Future<int> createStmPaperTxn(Transaction txn, String stmId, String memberName) async {
    return await txn.rawInsert('INSERT INTO SettlementPaper(settlementPaperId, settlementId, memberName) VALUES(?,?,?)'
        ,[_uuid.randomId, stmId, memberName]);
  }

  Future<List<Map>> readStmPaper(Database db, String stmPaperId) async {
    return await db!.rawQuery('SELECT * FROM SettlementPaper WHERE settlementPaperId = ?', [stmPaperId]);
  }

  Future<int> updateStmPaper(Database db, String memberName, String stmPaperId) async {
    return await db!.rawUpdate('UPDATE SettlementPaper SET memberName = ? WHERE settlementPaperId = ?', [memberName, stmPaperId]);
  }

  Future<int> deleteStmPaper(Database db, String stmPaperId) async {
    return await db!.rawDelete('DELETE FROM SettlementPaper WHERE settlementPaperId = ?', [stmPaperId]);
  }

  Future<int> deleteStmPaperTxn(Transaction txn, String stmPaperId) async {
    return await txn.rawDelete('DELETE FROM SettlementPaper WHERE settlementPaperId = ?', [stmPaperId]);
  }
}