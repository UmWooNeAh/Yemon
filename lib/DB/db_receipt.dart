import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DBReceipt {

  DBReceipt();

  Future<int> createRcp(Database db, String rcpId, String rcpName, String stmId) async {
    return await db!.rawInsert('INSERT INTO Receipt(receiptId, settlementId, receiptName) VALUES(?, ?, ?)'
        , [rcpId, stmId, rcpName]);
  }
  
  Future<List<Map>> readRcp(Database db, String stmId) async {
    return await db!.rawQuery('SELECT * FROM Receipt WHERE settlementId = ?', [stmId]);
  }

  Future<int> updateRcp(Database db, String rcpName, String rcpId) async {
    return await db!.rawUpdate('UPDATE Receipt SET receiptName = ? WHERE receiptId = ?', [rcpName, rcpId]);
  }
  
  Future<int> deleteRcp(Database db, String rcpId) async {
    return await db!.rawDelete('DELETE FROM Receipt WHERE receiptId = ?', [rcpId]);
  }


}