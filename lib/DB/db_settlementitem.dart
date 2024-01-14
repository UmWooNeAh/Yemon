import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'modeluuid.dart';

class DBSettlementItem {

  ModelUuid _uuid = ModelUuid();

  DBSettlementItem();

  Future<int> createStmItem(Database db, String stmPaperId, String rcpItemId) async {
    return await db!.rawInsert('INSERT INTO SettlementItem(settlementPaperId, receiptItemId) VALUES (?,?)'
    ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteStmItem(Database db, String stmPaperId, String rcpItemId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ? and receiptItemId = ?'
    ,[stmPaperId, rcpItemId]);
  }

  Future<int> deleteAllStmItems(Database db, String stmPaperId) async {
    return await db!.rawDelete('DELETE FROM SettlementItem WHERE settlementPaperId = ?', [stmPaperId]);
  }

}

