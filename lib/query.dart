import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/fetch_query.dart';
import 'package:sqlite_test/DB/db_receipt.dart';
import 'package:sqlite_test/DB/db_receiptitem.dart';
import 'package:sqlite_test/DB/db_settlement.dart';
import 'package:sqlite_test/DB/db_settlementitem.dart';
import 'package:sqlite_test/DB/db_settlementpaper.dart';

import 'Model/Receipt.dart';
import 'Model/ReceiptItem.dart';
import 'Model/SettlementItem.dart';
import 'Model/SettlementPaper.dart';
import 'Model/settlement.dart';

class Query {

  Database? _db;

  Query(Database db) {
    _db = db;
  }

  Future<void> showRecentSettlement(String stmId) async {
    Settlement settlement = await FetchQuery().fetchSettlement(_db!, stmId);
    List<Receipt> receipts = await FetchQuery().fetchReceipts(_db!, stmId);
    Map<String, List<ReceiptItem>> allReceiptItems = {}; //key: receiptId, value: List<ReceiptItem>
    receipts.forEach((receipt) async {
      String rcpId = receipt.receiptId;
      allReceiptItems[rcpId] = await FetchQuery().fetchReceiptItems(_db!, rcpId);
    });
    List<SettlementPaper> settlementPapers = await FetchQuery().fetchSettlementPapers(_db!, stmId);
    Map<String, List<SettlementItem>> allSettlementItems = {}; //key: settlementPaperId, value: List<SettlementItem>
    settlementPapers.forEach((stmPaper) async {
      String stmPaperId = stmPaper.settlementPaperId;
      allSettlementItems[stmPaperId] = await FetchQuery().fetchSettlementItems(_db!, stmPaperId);
    });
  }

  Future<Map<String,List<String>>> showSettlementMembers(List<String> stmIds) async {
    Map<String,List<String>> members = {}; //key: settlementId, value: members
    stmIds.forEach((stmId) async {
      members[stmId] = await FetchQuery().fetchMembers(_db!, stmId);
    });

    return members;
  }

  Future<int> createMembers(String stmId, List<String> memberNames) async {
    var res;
    try {
      res = await _db!.transaction((txn) async {
        memberNames.forEach((memberName) async {
          await DBSettlementPaper().createStmPaper(_db!, stmId, memberName);
        });
      });
    }
    catch (e) {
      print(e);
    }
    return res;
  }

  Future<int> deleteMembers(String stmId, List<String> settlementPaperIds) async {
    var res;
    try {
      await _db!.transaction((txn) async {
        settlementPaperIds.forEach((stmPaperId) async {
          await DBSettlementPaper().deleteStmPaper(_db!, stmPaperId);
          await DBSettlementItem().deleteAllStmItems(_db!, stmPaperId);
        });
      });
    }
    catch (e) {
      print(e);
    }
    return res;
  }

  Future<int> updateMemberName(String newmemberName, String stmPaperId) async {
    return DBSettlementPaper().updateStmPaper(_db!, newmemberName, stmPaperId);
  }

  Future<int> createReceipt(String rcpName, String stmId) async {
    return DBReceipt().createRcp(_db!, rcpName, stmId);
  }

  Future<int> updateReceiptName(String rcpName, String rcpId) async {
    return DBReceipt().updateRcp(_db!, rcpName, rcpId);
  }

  Future<int> deleteReceipt(String rcpId) async {
    return DBReceipt().deleteRcp(_db!, rcpId);
  }

  Future<int> createRcpItem(String rcpId, String name, int price, int count) async {
    return DBReceiptItem().createReceiptItem(_db!, rcpId, name, price, count);
  }

  Future<int> updateRcpItemName(String rcpItemId, String name) async {
    return DBReceiptItem().updateReceiptItemName(_db!, name, rcpItemId);
  }

  Future<int> updateRcpItemPrice(String rcpItemId, int price) async {
    return DBReceiptItem().updateReceiptItemPrice(_db!, price, rcpItemId);
  }

  Future<int> updateRcpItemCount(String rcpItemId, int count) async {
    return DBReceiptItem().updateReceiptItemCount(_db!, count, rcpItemId);
  }

  Future<int> deleteRcpItem(String rcpItemId) async {
   return DBReceiptItem().deleteReceiptItem(_db!, rcpItemId);
  }

  //정산 매칭 시의 쿼리들(롤백 적용 필요)
  Future<int> matchingMemberToAllReceiptItems(String stmPaperId, List<String> rcpItemIds) async {
    var res;
    try {
        res = await _db!.transaction((txn) async {
          rcpItemIds.forEach((rcpItemId) async {
            await DBSettlementItem().createStmItem(_db!, stmPaperId, rcpItemId);
          });
      });
    }
    catch (e) {
      print(e);
    }
    return res;
  }

  Future<int> matchingMemberToReceiptItem(String stmPaperId, String rcpItemId) async {
    return DBSettlementItem().createStmItem(_db!, stmPaperId, rcpItemId);
  }

  Future<int> unmatchingMemberFromAllReceiptItems(String stmPaperId, List<String> rcpItemIds) async {
    var res;
    try {
      res = await _db!.transaction((txn) async {
        rcpItemIds.forEach((rcpItemId) async {
          await DBSettlementItem().deleteStmItem(_db!, stmPaperId, rcpItemId);
        });
      });
    }
    catch (e) {
      print(e);
    }
    return res;
  }

  Future<int> unmatchingMemberFromReceiptItem(String stmPaperId, String rcpItemId) async {
    return DBSettlementItem().deleteStmItem(_db!, stmPaperId, rcpItemId);
  }


}