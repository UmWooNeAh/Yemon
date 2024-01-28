import 'package:sqflite/sqflite.dart';
import '../Model/receipt.dart';
import '../Model/receipt_item.dart';
import '../Model/settlement_item.dart';
import '../Model/settlementpaper.dart';
import '../Model/settlement.dart';

class FetchQuery {
  FetchQuery();

  Future<Settlement> fetchSettlement(Database db, String stmId) async {
    Settlement settlement = Settlement();
    List<Map> dbSettlement = await db
        .rawQuery('SELECT * FROM Settlement WHERE settlementId = ?', [stmId]);

    settlement.settlementId = dbSettlement[0]["settlementId"];
    settlement.settlementName = dbSettlement[0]["settlementName"];
    settlement.date = dbSettlement[0]["recordDate"];
    settlement.receipts = await fetchReceipts(db, stmId);
    settlement.settlementPapers = await fetchSettlementPapers(db, stmId);
    settlement.totalPrice = 0;

    return settlement;
  }

  Future<List<Receipt>> fetchReceipts(Database db, String stmId) async {
    List<Receipt> receipts = [];
    List<Map> dbReceipts = await db
        .rawQuery('SELECT * FROM Receipt WHERE settlementId = ?', [stmId]);

    dbReceipts.forEach((dbReceipt) async {
      Receipt newReceipt = Receipt();
      newReceipt.receiptId = dbReceipt["receiptId"];
      newReceipt.receiptName = dbReceipt["receiptName"];
      newReceipt.totalPrice = 0;
      newReceipt.receiptItems =
          await fetchReceiptItems(db, dbReceipt["receiptId"]);
      receipts.add(newReceipt);
    });

    return receipts;
  }

  Future<List<ReceiptItem>> fetchReceiptItems(Database db, String rcpId) async {
    List<ReceiptItem> receiptItems = [];
    List<Map> dbReceiptItems = await db
        .rawQuery('SELECT * FROM ReceiptItem WHERE receiptId = ?', [rcpId]);

    dbReceiptItems.forEach((dbReceiptItem) async {
      ReceiptItem newItem = ReceiptItem();
      newItem.receiptItemId = dbReceiptItem["receiptItemId"];
      newItem.receiptItemName = dbReceiptItem["name"];
      newItem.price = dbReceiptItem["price"];
      newItem.count = dbReceiptItem["count"];
      newItem.paperOwner = {}; // key: settlementPaperId, value: memberName

      List<Map> res = await db!.rawQuery('SELECT SP.settlementPaperId FROM (SettlementItem as SI INNER JOIN (SELECT settlementPaperId from SettlementPaper) as SP ON SI.settlementPaperId = SP.settlementPaperId) WHERE SI.receiptItemId = ?', [dbReceiptItem["receiptItemId"]]);
      res.forEach((row) async {
        String id = row["settlementPaperId"];
        //newItem.paperOwner[id] = 0;
      });

      receiptItems.add(newItem);
    });

    return receiptItems;
  }

  Future<List<SettlementPaper>> fetchSettlementPapers(
      Database db, String stmId) async {
    List<SettlementPaper> settlementPapers = [];

    List<Map> dbSettlementPapers = await db.rawQuery(
        'SELECT * FROM SettlementPaper WHERE settlmentId = ?', [stmId]);

    dbSettlementPapers.forEach((dbSettlementPaper) async {
      SettlementPaper newPaper = SettlementPaper();
      newPaper.settlementPaperId = dbSettlementPaper["settlementPaperId"];
      newPaper.memberName = dbSettlementPaper["memberName"];
      newPaper.totalPrice = 0;
      newPaper.settlementItems = await fetchSettlementItems(
          db, dbSettlementPaper["settlementPaperId"]);

      settlementPapers.add(newPaper);
    });

    return settlementPapers;
  }

  Future<List<SettlementItem>> fetchSettlementItems(
      Database db, String stmPaperId) async {
    List<SettlementItem> settlementItems = [];
    List<Map> dbReceiptItems = await db.rawQuery(
        'SELECT RI.name, RI.price, RI.count FROM (ReceiptItem as RI INNER JOIN (SELECT receiptId, settlementId from Receipt) as R ON R.receiptId = RI.receiptId INNER JOIN (SELECT settlementId from Settlement) as S ON S.settlementId = R.settlementId INNER JOIN (SELECT settlementId from SettlementPaper WHERE settlementPaperId = ?) as SP ON S.settlementId = SP.settlementId)',
        [stmPaperId]);

    dbReceiptItems.forEach((dbReceiptItem) async {
      SettlementItem newItem = SettlementItem(dbReceiptItem["name"]);
      newItem.splitPrice = dbReceiptItem["price"] / dbReceiptItem["count"];

      settlementItems.add(newItem);
    });
    return settlementItems;
  }

  Future<List<String>> fetchMembers(Database db, String stmId) async {
    List<String> membersInSettlement = [];
    List<Map> res = await db.rawQuery(
        'SELECT memberName from SettlementPaper WHERE settlementId = ?',
        [stmId]);
    res.forEach((row) async {
      membersInSettlement.add(row["memberName"]);
    });

    return membersInSettlement;
  }
}
