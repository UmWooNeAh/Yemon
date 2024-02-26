import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SettlementPaperDAO {

  SettlementPaperDAO();

  Future<int> save(Database db, String stmPaperId, String stmId, String memberName) async {
    return await db!.rawInsert('INSERT INTO SettlementPaper(settlementPaperId, settlementId, memberName) VALUES(?,?,?)'
    ,[stmPaperId, stmId, memberName]);
  }

  Future<int> saveTxn(Transaction txn, String stmPaperId, String stmId, String memberName) async {
    return await txn.rawInsert('INSERT INTO SettlementPaper(settlementPaperId, settlementId, memberName) VALUES(?,?,?)'
        ,[stmPaperId, stmId, memberName]);
  }

  Future<List<Map>> findById(Database db, String stmPaperId) async {
    return await db!.rawQuery('SELECT * FROM SettlementPaper WHERE settlementPaperId = ?', [stmPaperId]);
  }

  Future<int> update(Database db, String memberName, String stmPaperId) async {
    return await db!.rawUpdate('UPDATE SettlementPaper SET memberName = ? WHERE settlementPaperId = ?', [memberName, stmPaperId]);
  }

  Future<int> delete(Database db, String stmPaperId) async {
    return await db!.rawDelete('DELETE FROM SettlementPaper WHERE settlementPaperId = ?', [stmPaperId]);
  }

  Future<int> deleteTxn(Transaction txn, String stmPaperId) async {
    return await txn.rawDelete('DELETE FROM SettlementPaper WHERE settlementPaperId = ?', [stmPaperId]);
  }
}