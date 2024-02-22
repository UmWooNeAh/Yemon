import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../Model/receipt_item.dart';

class ReceiptItemDAO {


  ReceiptItemDAO();

  Future<int> save(Database db, String rcpItemId, String rcpId, String name, double price, int count) async {
    return await db!.rawInsert('INSERT INTO ReceiptItem(receiptItemId, receiptId, name, price, count) VALUES(?,?,?,?,?)'
      ,[rcpItemId, rcpId, name, price, count]);
  }

  Future<List<Map>> findById(Database db, String rcpId, String stmId) async {
    return await db!.rawQuery('SELECT * FROM ReceiptItem WHERE receiptId = ?', [rcpId]);
  }

  Future<int> update(Database db, ReceiptItem rcpItem) async {
    return await db!.rawUpdate('UPDATE ReceiptItem SET name = ?, price = ?, count = ? WHERE receiptItemId = ?'
      , [rcpItem.receiptItemName, rcpItem.individualPrice, rcpItem.count, rcpItem.receiptItemId]);
  }

  Future<int> delete(Database db, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM ReceiptItem WHERE receiptItemId = ?', [rcpItemId]);
  }

  Future<int> deleteAllRcpItemsTxn(Transaction txn, String rcpId) async {
    return await txn.rawDelete('DELETE FROM ReceiptItem WHERE receiptId = ?', [rcpId]);
  }

  Future<int> deleteAllRcpItems(Database db, String rcpId) async {
    return await db!.rawDelete('DELETE FROM ReceiptItem WHERE receiptId = ?', [rcpId]);
  }



}