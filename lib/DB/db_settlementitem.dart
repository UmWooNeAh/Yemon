import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DBSettlementItem {

  DBSettlementItem();

  Future<int> createStmItem(Database db, String stmPaperId, String rcpItemId) async {
    return await db!.rawInsert('INSERT INTO SettlementItem(settlementPaperId, receiptItemId) VALUES (?,?)'
    ,[stmPaperId, rcpItemId]);
  }

  Future<int> createStmItemTxn(Transaction txn, String stmPaperId, String rcpItemId) async {
    return await txn.rawInsert('INSERT INTO SettlementItem(settlementPaperId, receiptItemId) VALUES (?,?)'
        ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteStmItem(Database db, String stmPaperId, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ? and receiptItemId = ?'
    ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteStmItemTxn(Transaction txn, String stmPaperId, String rcpItemId) async {
    return await txn.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ? and receiptItemId = ?'
        ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteAllStmItems(Database db, String stmPaperId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ?', [stmPaperId]);
  }

  Future<int> deleteAllStmItemsByRcpItemId(Database db, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE receiptItemId = ?', [rcpItemId]);
  }

  Future<int> deleteAllStmItemsTxn(Transaction txn, String stmPaperId) async {
    return await txn.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ?', [stmPaperId]);
  }

}

