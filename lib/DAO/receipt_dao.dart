import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class ReceiptDAO {

  ReceiptDAO();

  Future<int> save(Database db, String rcpId, String rcpName, String stmId) async {
    return await db!.rawInsert('INSERT INTO Receipt(receiptId, settlementId, receiptName) VALUES(?, ?, ?)'
        , [rcpId, stmId, rcpName]);
  }
  
  Future<List<Map>> findById(Database db, String stmId) async {
    return await db!.rawQuery('SELECT * FROM Receipt WHERE settlementId = ?', [stmId]);
  }

  Future<int> update(Database db, String rcpName, String rcpId) async {
    return await db!.rawUpdate('UPDATE Receipt SET receiptName = ? WHERE receiptId = ?', [rcpName, rcpId]);
  }
  
  Future<int> delete(Database db, String rcpId) async {
    return await db!.rawDelete('DELETE FROM Receipt WHERE receiptId = ?', [rcpId]);
  }

  Future<int> deleteTxn(Transaction txn, String rcpId) async {
    return await txn.rawDelete('DELETE FROM Receipt WHERE receiptId = ?', [rcpId]);
  }


}