import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SettlementItemDAO {

  SettlementItemDAO();

  Future<int> save(Database db, String stmPaperId, String rcpItemId) async {
    return await db!.rawInsert('INSERT INTO SettlementItem(settlementPaperId, receiptItemId) VALUES (?,?)'
    ,[stmPaperId, rcpItemId]);
  }

  Future<int> saveTxn(Transaction txn, String stmPaperId, String rcpItemId) async {
    return await txn.rawInsert('INSERT INTO SettlementItem(settlementPaperId, receiptItemId) VALUES (?,?)'
        ,[stmPaperId, rcpItemId]);
  }

  Future<int> delete(Database db, String stmPaperId, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ? and receiptItemId = ?'
    ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteTxn(Transaction txn, String stmPaperId, String rcpItemId) async {
    return await txn.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ? and receiptItemId = ?'
        ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteAll(Database db, String stmPaperId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ?', [stmPaperId]);
  }

  Future<int> deleteAllByRcpItemId(Database db, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE receiptItemId = ?', [rcpItemId]);
  }

  Future<int> deleteAllStmItemsTxn(Transaction txn, String stmPaperId) async {
    return await txn.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ?', [stmPaperId]);
  }

}

