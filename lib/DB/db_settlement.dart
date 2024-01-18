import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DBSettlement {

  DBSettlement();

  Future<int> createStm(Database db, String stmId, String stmName) async {
    return await db!.rawInsert('INSERT INTO Settlement(settlementId, settlementName, recordDate) VALUES(?, ?, ?)'
        , [stmId, stmName, DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())]);
  }

  Future<List<Map>> readStm(Database db, String stmId) async {
    return await db!.rawQuery('SELECT * FROM Settlement WHERE settlementId = ?', [stmId]);
  }

  Future<int> updateStm(Database db, String newstmName, String stmId) async {
    return await db!.rawUpdate('UPDATE Settlement SET settlementName = ?, recordDate = ? WHERE settlementId = ?'
        , [newstmName, DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), stmId]);
  }

  Future<int> deleteStm(Database db, String stmId) async {
    return await db!.rawDelete('DELETE FROM Settlement WHERE settlementId = ?', [stmId]);
  }

}