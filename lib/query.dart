import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DAO/receipt_dao.dart';
import 'package:sqlite_test/DAO/receiptitem_dao.dart';
import 'package:sqlite_test/DAO/settlement_dao.dart';
import 'package:sqlite_test/DAO/settlementitem_dao.dart';
import 'package:sqlite_test/DAO/settlementpaper_dao.dart';
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
    return await SettlementDAO().save(_db!, stm.settlementId, stm.settlementName);
  }

  Future<int> updateSettlement(Settlement stm) async {
    return await SettlementDAO().update(_db!, stm.settlementName, stm.settlementId);
  }

  //하나의 정산 삭제: 관련된 모든 정보들 삭제(영수증,영수증항목,정산서,정산서항목)
  Future<int> deleteSettlement(Settlement stm) async {
      await SettlementDAO().delete(_db!, stm.settlementId);
      for (var receipt in stm.receipts) {
        await ReceiptDAO().delete(_db!, receipt.receiptId);
        await ReceiptItemDAO().deleteAllRcpItems(_db!, receipt.receiptId);
      }
      for (var stmPaper in stm.settlementPapers) {
        await SettlementPaperDAO()
            .delete(_db!, stmPaper.settlementPaperId);
        await SettlementItemDAO()
            .deleteAll(_db!, stmPaper.settlementPaperId);
      }

    return 1;
  }

  Future<int> createMembers(
      String stmId, List<SettlementPaper> stmPapers) async {
        for (var stmPaper in stmPapers) {
          await SettlementPaperDAO().save(_db!, stmPaper.settlementPaperId, stmId, stmPaper.memberName);
        }

    return 1;
  }

  Future<int> deleteMembers(
      String stmId, List<String> settlementPaperIds) async {
        for (var stmPaperId in settlementPaperIds) {
          await SettlementPaperDAO().delete(_db!, stmPaperId);
          await SettlementItemDAO().deleteAll(_db!, stmPaperId);
        }

    return 1;
  }

  Future<int> updateMemberName(String newmemberName, String stmPaperId) async {
    return SettlementPaperDAO().update(_db!, newmemberName, stmPaperId);
  }

  Future<int> createReceipt(Receipt rcp, String stmId) async {
    return ReceiptDAO().save(_db!, rcp.receiptId, rcp.receiptName, stmId);
  }

  Future<int> updateReceiptName(String rcpName, String rcpId) async {
    return ReceiptDAO().update(_db!, rcpName, rcpId);
  }

  Future<int> deleteReceipt(String rcpId) async {
    return ReceiptDAO().delete(_db!, rcpId);
  }

  Future<int> createReceiptItem(String rcpId, ReceiptItem rcpItem) async {
    return ReceiptItemDAO().save(_db!, rcpItem.receiptItemId, rcpId,
        rcpItem.receiptItemName, rcpItem.individualPrice, rcpItem.count);
  }

  Future<int> updateReceiptItem(ReceiptItem rcpItem) async {
    return ReceiptItemDAO().update(_db!, rcpItem);
  }

  Future<int> deleteReceiptItem(String rcpItemId) async {
    return ReceiptItemDAO().delete(_db!, rcpItemId);
  }

  //정산 매칭 시의 쿼리들
  Future<int> matchingMemberToAllReceiptItems(
      String stmPaperId, List<String> rcpItemIds) async {
        for (var rcpItemId in rcpItemIds) {
          await SettlementItemDAO().save(_db!, stmPaperId, rcpItemId);
        }

    return 1;
  }

  Future<int> matchingMemberToReceiptItem(String stmPaperId, String rcpItemId) async {
    try {
      await SettlementItemDAO().save(_db!, stmPaperId, rcpItemId);
    } catch (e) {
      // print(e);
      return 0;
    }
    return 1;
  }

  Future<int> matchingMembersToAllReceiptItem(List<String> stmPaperIds, List<String> rcpItemIds) async {
        for (var stmPaperId in stmPaperIds) {
          for (var rcpItemId in rcpItemIds) {
            await SettlementItemDAO().save(_db!, stmPaperId, rcpItemId);
          }
        }
    return 1;
  }

  Future<int> matchingMembersToReceiptItem(List<String> stmPaperIds, String rcpItemId) async {
        for (var stmPaperId in stmPaperIds) {
          await SettlementItemDAO().save(_db!, stmPaperId, rcpItemId);
        }
    return 1;
  }

  Future<int> unmatchingMemberFromAllReceiptItems(String stmPaperId, List<String> rcpItemIds) async {
        for (var rcpItemId in rcpItemIds) {
          await SettlementItemDAO().delete(_db!, stmPaperId, rcpItemId);
        }
    return 1;
  }

  Future<int> unmatchingMemberFromReceiptItem(String stmPaperId, String rcpItemId) async {
    try {
      await SettlementItemDAO().delete(_db!, stmPaperId, rcpItemId);
    } catch (e) {
      // print(e);
      return 0;
    }
    return 1;
  }

}

// <------------------------------------프론트에서는 여기까지만 참조하면 됩니다.---------------------------------------->




class FetchQuery {
  FetchQuery();

  Future<List<Settlement>> fetchAllSettlements(Database db) async {
    List<Settlement> stms = [];
    List<Map> dbSettlement =
    await db!.rawQuery('SELECT * FROM Settlement ORDER BY recordDate DESC');

    for (var stm in dbSettlement) {
      Settlement settlement = Settlement();
      settlement.settlementId = stm["settlementId"];
      settlement.settlementName = stm["settlementName"];
      settlement.date = DateTime.parse(stm["recordDate"]);
      settlement.settlementPapers = await fetchSettlementPapers(db, settlement.settlementId);
      stms.add(settlement);
    }

    return stms;
  }

  Future<Settlement> fetchSettlement(Database db, String stmId) async {
    Settlement settlement = Settlement();
    List<Map> dbSettlement = await db
        .rawQuery('SELECT * FROM Settlement WHERE settlementId = ?', [stmId]);

    settlement.settlementId = dbSettlement[0]["settlementId"];
    settlement.settlementName = dbSettlement[0]["settlementName"];
    settlement.date = DateTime.parse(dbSettlement[0]["recordDate"]);
    settlement.receipts = await fetchReceipts(db, stmId);
    settlement.settlementPapers = await fetchSettlementPapers(db, stmId);
    settlement.totalPrice = 0;
    for (var receipt in settlement.receipts) {
      settlement.totalPrice += receipt.totalPrice;
    }

    return settlement;
  }

  Future<List<Receipt>> fetchReceipts(Database db, String stmId) async {
    List<Receipt> receipts = [];
    List<Map> dbReceipts = await db
        .rawQuery('SELECT * FROM Receipt WHERE settlementId = ?', [stmId]);

    for (var dbReceipt in dbReceipts) {
      Receipt newReceipt = Receipt();
      newReceipt.receiptId = dbReceipt["receiptId"];
      newReceipt.receiptName = dbReceipt["receiptName"];
      newReceipt.receiptItems = await fetchReceiptItems(db, dbReceipt["receiptId"]);
      newReceipt.totalPrice = 0;
      for (var receiptItem in newReceipt.receiptItems) {
        newReceipt.totalPrice += receiptItem.price;
      }
      receipts.add(newReceipt);
    }

    return receipts;
  }

  Future<List<ReceiptItem>> fetchReceiptItems(Database db, String rcpId) async {
    List<ReceiptItem> receiptItems = [];
    List<Map> dbReceiptItems = await db
        .rawQuery('SELECT * FROM ReceiptItem WHERE receiptId = ?', [rcpId]);

    for (var dbReceiptItem in dbReceiptItems) {
      ReceiptItem newItem = ReceiptItem();
      newItem.receiptItemId = dbReceiptItem["receiptItemId"];
      newItem.receiptItemName = dbReceiptItem["name"];
      newItem.individualPrice = dbReceiptItem["price"];
      newItem.count = dbReceiptItem["count"];
      newItem.price = newItem.individualPrice * newItem.count;
      newItem.paperOwner = {}; // key: settlementPaperId, value: memberName

      List<Map> res = await db!.rawQuery(
          'SELECT SP.settlementPaperId FROM (SettlementItem as SI INNER JOIN (SELECT settlementPaperId from SettlementPaper) '
              + 'as SP ON SI.settlementPaperId = SP.settlementPaperId) WHERE SI.receiptItemId = ?', [dbReceiptItem["receiptItemId"]]);
      for (var row in res) {
        String id = row["settlementPaperId"];
        newItem.paperOwner[id] = 0;
      }
      receiptItems.add(newItem);
    }

    return receiptItems;
  }

  Future<List<SettlementPaper>> fetchSettlementPapers(Database db, String stmId) async {
    List<SettlementPaper> settlementPapers = [];

    List<Map> dbSettlementPapers = await db.rawQuery(
        'SELECT * FROM SettlementPaper WHERE settlementId = ?', [stmId]);

    for (var dbSettlementPaper in dbSettlementPapers) {
      SettlementPaper newPaper = SettlementPaper();
      newPaper.settlementPaperId = dbSettlementPaper["settlementPaperId"];
      newPaper.memberName = dbSettlementPaper["memberName"];

      newPaper.settlementItems = await fetchSettlementItems(db, dbSettlementPaper["settlementPaperId"]);
      for (var settlementItem in newPaper.settlementItems) {
        newPaper.totalPrice += settlementItem.splitPrice;
      }
      settlementPapers.add(newPaper);
    }

    return settlementPapers;
  }

  Future<List<SettlementItem>> fetchSettlementItems(Database db, String stmPaperId) async {
    List<SettlementItem> settlementItems = [];
    List<Map> dbReceiptItemIds = await db.rawQuery(
        "SELECT receiptItemId from SettlementItem WHERE settlementPaperId = ?", [stmPaperId]);
    for (var dbReceiptItemId in dbReceiptItemIds) {
      List<Map> settlementItem = await db.rawQuery(
          "SELECT name, price, receiptId, count from ReceiptItem WHERE receiptItemId = ?", [dbReceiptItemId["receiptItemId"]]);
      SettlementItem newItem = SettlementItem(settlementItem[0]["name"]);
      List<Map> counts = await db.rawQuery(
          'SELECT count(*) as Incount from SettlementItem where receiptItemId = ?', [dbReceiptItemId["receiptItemId"]]);
      newItem.splitPrice = settlementItem[0]["price"] * settlementItem[0]['count'] / counts[0]["Incount"];
      newItem.receiptItemPrice = settlementItem[0]["price"] * settlementItem[0]['count'];
      List<Map> receiptName = await db.rawQuery('SELECT receiptName from Receipt where receiptId = ?', [settlementItem[0]["receiptId"]]);
      newItem.receiptName = receiptName[0]["receiptName"];
      settlementItems.add(newItem);
    }
    return settlementItems;
  }

  Future<List<String>> fetchMembers(Database db, String stmId) async {
    List<String> membersInSettlement = [];
    List<Map> res = await db.rawQuery(
        'SELECT memberName from SettlementPaper WHERE settlementId = ?', [stmId]);
    for (var row in res) {
      membersInSettlement.add(row["memberName"]);
    }

    return membersInSettlement;
  }


//트랜잭션 관련 코드
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
