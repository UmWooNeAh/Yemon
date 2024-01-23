import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../Model/ReceiptItem.dart';

class DBReceiptItem {


  DBReceiptItem();

  Future<int> createReceiptItem(Database db, String rcpItemId, String rcpId, String name, double price, int count) async {
    return await db!.rawInsert('INSERT INTO ReceiptItem(receiptItemId, receiptId, name, price, count) VALUES(?,?,?,?,?)'
      ,[rcpItemId, rcpId, name, price, count]);
  }

  Future<List<Map>> readReceiptItem(Database db, String rcpId, String stmId) async {
    return await db!.rawQuery('SELECT * FROM ReceiptItem WHERE receiptId = ?', [rcpId]);
  }

  Future<int> updateReceiptItem(Database db, ReceiptItem rcpItem) async {
    return await db!.rawUpdate('UPDATE ReceiptItem SET name = ? and price = ? and count = ? WHERE receiptItemId = ?'
      , [rcpItem.receiptItemName, rcpItem.price, rcpItem.count, rcpItem.receiptItemId]);
  }

  Future<int> deleteReceiptItem(Database db, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM ReceiptItem WHERE receiptItemId = ?', [rcpItemId]);
  }

  Future<int> deleteReceiptItemTxn(Transaction txn, String rcpItemId) async {
    return await txn.rawDelete('DELETE FROM ReceiptItem WHERE receiptItemId = ?', [rcpItemId]);
  }

}