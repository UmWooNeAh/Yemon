import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/fetch_query.dart';
import 'package:sqlite_test/DB/db_receipt.dart';
import 'package:sqlite_test/DB/db_receiptitem.dart';
import 'package:sqlite_test/DB/db_settlement.dart';
import 'package:sqlite_test/DB/db_settlementitem.dart';
import 'package:sqlite_test/DB/db_settlementpaper.dart';
import 'DB/savepoint.dart';
import 'Model/receipt.dart';
import 'Model/receipt_item.dart';
import 'Model/settlement_item.dart';
import 'Model/settlementpaper.dart';
import 'Model/settlement.dart';

class Query {
  Database? _db;

  Query(Database db) {
    _db = db;
  }

  Future<List<Settlement>> showAllSettlements() async {
    return await FetchQuery().fetchAllSettlements(_db!);
  }

  Future<Settlement> showRecentSettlement(String stmId) async {
    return await FetchQuery().fetchSettlement(_db!, stmId);
  }

  Future<Map<String, List<String>>> showSettlementMembers(
      List<String> stmIds) async {
    Map<String, List<String>> members = {}; //key: settlementId, value: members
    for (var stmId in stmIds) {
      members[stmId] = await FetchQuery().fetchMembers(_db!, stmId);
    }

    return members;
  }

  Future<int> createSettlement(Settlement stm) async {
    return await DBSettlement()
        .createStm(_db!, stm.settlementId, stm.settlementName);
  }

  Future<int> updateSettlement(Settlement stm) async {
    return await DBSettlement()
        .updateStm(_db!, stm.settlementName, stm.settlementId);
  }

  //하나의 정산 삭제: 관련된 모든 정보들 삭제(영수증,영수증항목,정산서,정산서항목)
  Future<int> deleteSettlement(Settlement stm) async {
      await DBSettlement().deleteStm(_db!, stm.settlementId);
      for (var receipt in stm.receipts) {
        await DBReceipt().deleteRcp(_db!, receipt.receiptId);
        await DBReceiptItem().deleteAllRcpItems(_db!, receipt.receiptId);
      }
      for (var stmPaper in stm.settlementPapers) {
        await DBSettlementPaper()
            .deleteStmPaper(_db!, stmPaper.settlementPaperId);
        await DBSettlementItem()
            .deleteAllStmItems(_db!, stmPaper.settlementPaperId);
      }
    
    return 1;
  }

  Future<int> createMembers(
      String stmId, List<SettlementPaper> stmPapers) async {
        for (var stmPaper in stmPapers) {
          await DBSettlementPaper().createStmPaper(
              _db!, stmPaper.settlementPaperId, stmId, stmPaper.memberName);
        }
      
    return 1;
  }

  Future<int> deleteMembers(
      String stmId, List<String> settlementPaperIds) async {
        for (var stmPaperId in settlementPaperIds) {
          await DBSettlementPaper().deleteStmPaper(_db!, stmPaperId);
          await DBSettlementItem().deleteAllStmItems(_db!, stmPaperId);
        }
    
    return 1;
  }

  Future<int> updateMemberName(String newmemberName, String stmPaperId) async {
    return DBSettlementPaper().updateStmPaper(_db!, newmemberName, stmPaperId);
  }

  Future<int> createReceipt(Receipt rcp, String stmId) async {
    return DBReceipt().createRcp(_db!, rcp.receiptId, rcp.receiptName, stmId);
  }

  Future<int> updateReceiptName(String rcpName, String rcpId) async {
    return DBReceipt().updateRcp(_db!, rcpName, rcpId);
  }

  Future<int> deleteReceipt(String rcpId) async {
    return DBReceipt().deleteRcp(_db!, rcpId);
  }

  Future<int> createReceiptItem(String rcpId, ReceiptItem rcpItem) async {
    return DBReceiptItem().createReceiptItem(_db!, rcpItem.receiptItemId, rcpId,
        rcpItem.receiptItemName, rcpItem.price, rcpItem.count);
  }

  Future<int> updateReceiptItem(ReceiptItem rcpItem) async {
    return DBReceiptItem().updateReceiptItem(_db!, rcpItem);
  }

  Future<int> deleteReceiptItem(String rcpItemId) async {
    return DBReceiptItem().deleteReceiptItem(_db!, rcpItemId);
  }

  //정산 매칭 시의 쿼리들
  Future<int> matchingMemberToAllReceiptItems(
      String stmPaperId, List<String> rcpItemIds) async {
        for (var rcpItemId in rcpItemIds) {
          await DBSettlementItem().createStmItem(_db!, stmPaperId, rcpItemId);
        }

    return 1;
  }

  Future<int> matchingMemberToReceiptItem(
      String stmPaperId, String rcpItemId) async {
    try {
      await DBSettlementItem().createStmItem(_db!, stmPaperId, rcpItemId);
    } catch (e) {
      print(e);
      return 0;
    }
    return 1;
  }

  Future<int> matchingMembersToAllReceiptItem(
      List<String> stmPaperIds, List<String> rcpItemIds) async {
        for (var stmPaperId in stmPaperIds) {
          for (var rcpItemId in rcpItemIds) {
            await DBSettlementItem()
                .createStmItem(_db!, stmPaperId, rcpItemId);
          }
        }
    return 1;
  }

  Future<int> matchingMembersToReceiptItem(
      List<String> stmPaperIds, String rcpItemId) async {
        for (var stmPaperId in stmPaperIds) {
          await DBSettlementItem().createStmItem(_db!, stmPaperId, rcpItemId);
        }
    return 1;
  }

  Future<int> unmatchingMemberFromAllReceiptItems(
      String stmPaperId, List<String> rcpItemIds) async {
        for (var rcpItemId in rcpItemIds) {
          await DBSettlementItem().deleteStmItem(_db!, stmPaperId, rcpItemId);
        }
    return 1;
  }

  Future<int> unmatchingMemberFromReceiptItem(
      String stmPaperId, String rcpItemId) async {
    try {
      await DBSettlementItem().deleteStmItem(_db!, stmPaperId, rcpItemId);
    } catch (e) {
      print(e);
      return 0;
    }
    return 1;
  }

  // Future<void> startTransaction(Database db) async {
  //   await db.execute('BEGIN TRANSACTION');
  // }
  // Future <void> commitTransaction(Database db) async {
  //   await db.execute('COMMIT');
  // }

  // Future<void> savepointTranscation(Database db, SavepointManager spm) async {
  //   String savepoint = spm!.createSavePoint();
  //   //String savepoint = 'my_savepoint_${++_savepointId}';
  //   await db.execute('SAVEPOINT $savepoint');
  //   log("savepoint: ${savepoint}");
  // }

  // Future<void> rollbackTransaction(Database db, SavepointManager spm) async {
  //   String savepoint = spm!.returnSavePoint();
  //   //String savepoint = 'my_savepoint_${_savepointId--}';
  //   log("savepoint: ${savepoint}");
  //   await db.execute('ROLLBACK TO SAVEPOINT $savepoint');
  // }
}
