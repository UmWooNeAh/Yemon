import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DBReceiptItem {


  DBReceiptItem();

  Future<int> createReceiptItem(Database db, String rcpItemId, String rcpId, String name, double price, int count) async {
    return await db!.rawInsert('INSERT INTO ReceiptItem(receiptItemId, receiptId, name, price, count) VALUES(?,?,?,?,?)'
      ,[rcpItemId, rcpId, name, price, count]);
  }

  Future<List<Map>> readReceiptItem(Database db, String rcpId, String stmId) async {
    return await db!.rawQuery('SELECT * FROM ReceiptItem WHERE receiptId = ?', [rcpId]);
  }

  Future<int> updateReceiptItemName(Database db, String name, String rcpItemId) async {
    return await db!.rawUpdate('UPDATE ReceiptItem SET name = ? WHERE receiptItemId = ?'
    , [name, rcpItemId]);
  }

  Future<int> updateReceiptItemPrice(Database db, double price, String rcpItemId) async {
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