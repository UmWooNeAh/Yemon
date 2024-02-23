import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import '../Model/receipt.dart';
import '../Model/receipt_item.dart';
import '../Model/settlement_item.dart';
import '../Model/settlementpaper.dart';
import '../Model/settlement.dart';

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
      settlement.settlementPapers =
          await fetchSettlementPapers(db, settlement.settlementId);
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
      newReceipt.receiptItems =
          await fetchReceiptItems(db, dbReceipt["receiptId"]);
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
          'SELECT SP.settlementPaperId FROM (SettlementItem as SI INNER JOIN (SELECT settlementPaperId from SettlementPaper) as SP ON SI.settlementPaperId = SP.settlementPaperId) WHERE SI.receiptItemId = ?',
          [dbReceiptItem["receiptItemId"]]);
      for (var row in res) {
        String id = row["settlementPaperId"];
        newItem.paperOwner[id] = 0;
      }
      receiptItems.add(newItem);
    }

    return receiptItems;
  }

  Future<List<SettlementPaper>> fetchSettlementPapers(
      Database db, String stmId) async {
    List<SettlementPaper> settlementPapers = [];

    List<Map> dbSettlementPapers = await db.rawQuery(
        'SELECT * FROM SettlementPaper WHERE settlementId = ?', [stmId]);

    for (var dbSettlementPaper in dbSettlementPapers) {
      SettlementPaper newPaper = SettlementPaper();
      newPaper.settlementPaperId = dbSettlementPaper["settlementPaperId"];
      newPaper.memberName = dbSettlementPaper["memberName"];
      
      newPaper.settlementItems = await fetchSettlementItems(
          db, dbSettlementPaper["settlementPaperId"]);
      for (var settlementItem in newPaper.settlementItems) {
        newPaper.totalPrice += settlementItem.splitPrice;
      }
      settlementPapers.add(newPaper);
    }

    return settlementPapers;
  }

  Future<List<SettlementItem>> fetchSettlementItems(
      Database db, String stmPaperId) async {
    List<SettlementItem> settlementItems = [];
    List<Map> dbReceiptItemIds = await db.rawQuery(
        "SELECT receiptItemId from SettlementItem WHERE settlementPaperId = ?",
        [stmPaperId]);
    for (var dbReceiptItemId in dbReceiptItemIds) {
      List<Map> settlementItem = await db.rawQuery(
          "SELECT name, price, receiptId, count from ReceiptItem WHERE receiptItemId = ?",
          [dbReceiptItemId["receiptItemId"]]);
      SettlementItem newItem = SettlementItem(settlementItem[0]["name"]);
      List<Map> counts = await db.rawQuery(
          'SELECT count(*) as Incount from SettlementItem where receiptItemId = ?',
          [dbReceiptItemId["receiptItemId"]]);
      newItem.splitPrice = settlementItem[0]["price"] * settlementItem[0]['count'] / counts[0]["Incount"];
      newItem.receiptItemPrice = settlementItem[0]["price"] * settlementItem[0]['count'];
      List<Map> receiptName = await db.rawQuery(
          'SELECT receiptName from Receipt where receiptId = ?',
          [settlementItem[0]["receiptId"]]);
      newItem.receiptName = receiptName[0]["receiptName"];
      settlementItems.add(newItem);
    }
    return settlementItems;
  }

  Future<List<String>> fetchMembers(Database db, String stmId) async {
    List<String> membersInSettlement = [];
    List<Map> res = await db.rawQuery(
        'SELECT memberName from SettlementPaper WHERE settlementId = ?',
        [stmId]);
    for (var row in res) {
      membersInSettlement.add(row["memberName"]);
    }

    return membersInSettlement;
  }
}
