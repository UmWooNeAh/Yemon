import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SettlementDAO {

  SettlementDAO();

  Future<int> save(Database db, String stmId, String stmName) async {
    return await db!.rawInsert('INSERT INTO Settlement(settlementId, settlementName, recordDate) VALUES(?, ?, ?)'
        , [stmId, stmName, DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())]);
  }

  Future<List<Map>> findById(Database db, String stmId) async {
    return await db!.rawQuery('SELECT * FROM Settlement WHERE settlementId = ?', [stmId]);
  }

  Future<int> update(Database db, String newstmName, String stmId) async {
    return await db!.rawUpdate('UPDATE Settlement SET settlementName = ?, recordDate = ? WHERE settlementId = ?'
        , [newstmName, DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), stmId]);
  }

  Future<int> delete(Database db, String stmId) async {
    return await db!.rawDelete('DELETE FROM Settlement WHERE settlementId = ?', [stmId]);
  }

  Future<int> deleteTxn(Transaction txn, String stmId) async {
    return await txn.rawDelete('DELETE FROM Settlement WHERE settlementId = ?', [stmId]);
  }

}