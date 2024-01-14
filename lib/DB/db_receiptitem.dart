import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'modeluuid.dart';

class DBReceiptItem {

  ModelUuid _uuid = ModelUuid();

  DBReceiptItem();

  Future<int> createReceiptItem(Database db, String rcpId, String name, int price, int count) async {
    return await db!.rawInsert('INSERT INTO ReceiptItem(receiptItemId, receiptId, receiptItemName, price, count) VALUES(?,?,?,?) '
      ,[_uuid.randomId, rcpId, name, price, count]);
  }

  Future<List<Map>> readReceiptItem(Database db, String rcpId, String stmId) async {
    return await db!.rawQuery('SELECT * FROM ReceiptItem WHERE receiptId = ?', [rcpId]);
  }

  Future<int> updateReceiptItemName(Database db, String name, String rcpItemId) async {
    return await db!.rawUpdate('UPDATE ReceiptItem SET receiptItemName = ? WHERE receiptItemId = ?'
    , [name, rcpItemId]);
  }

  Future<int> updateReceiptItemPrice(Database db, int price, String rcpItemId) async {
    return await db!.rawUpdate('UPDATE ReceiptItem SET price = ? WHERE receiptItemId = ?'
        , [price, rcpItemId]);
  }

  Future<int> updateReceiptItemCount(Database db, int count, String rcpItemId) async {
    return await db!.rawUpdate('UPDATE ReceiptItem SET count = ? WHERE receiptItemId = ?'
        , [count, rcpItemId]);
  }

  Future<int> deleteReceiptItem(Database db, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM ReceiptItem WHERE receiptItemId = ?', [rcpItemId]);
  }


}