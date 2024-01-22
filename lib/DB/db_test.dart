import 'dart:developer';
import 'package:sqlite_test/DB/db_receipt.dart';
import 'package:sqlite_test/DB/db_receiptitem.dart';
import 'package:sqlite_test/DB/db_settlement.dart';
import 'package:sqlite_test/DB/db_settlementitem.dart';
import 'package:sqlite_test/DB/db_settlementpaper.dart';
import 'package:sqlite_test/DB/savepoint.dart';
import 'package:sqlite_test/DB/sqlFliteDB.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/Model/SettlementItem.dart';
import 'package:sqlite_test/query.dart';

import '../Model/Receipt.dart';
import '../Model/ReceiptItem.dart';
import '../Model/SettlementPaper.dart';
import '../Model/settlement.dart';

Settlement stm = Settlement();
Receipt rcp1 = Receipt();
Receipt rcp2 = Receipt();
ReceiptItem rcpitem1 = ReceiptItem();
ReceiptItem rcpitem2 = ReceiptItem();
ReceiptItem rcpitem3 = ReceiptItem();
SettlementPaper stmpaper1 = SettlementPaper();
SettlementPaper stmpaper2 = SettlementPaper();
SettlementPaper stmpaper3 = SettlementPaper();
SettlementPaper stmpaper4 = SettlementPaper();
List<SettlementPaper> paperlist = [stmpaper1,stmpaper2,stmpaper3,stmpaper4];

void test_add(Database db) async {


  //Settlement stm = Settlement();
  stm.settlementName = "데모 정산";
  //Receipt rcp1 = Receipt();
  rcp1.receiptName = "영수증 1";
  //Receipt rcp2 = Receipt();
  rcp2.receiptName = "영수증 2";
  //ReceiptItem rcpitem1 = ReceiptItem();
  rcpitem1.receiptItemName = "자장면"; rcpitem1.price = 6000; rcpitem1.count = 4;
  //ReceiptItem rcpitem2 = ReceiptItem();
  rcpitem2.receiptItemName = "탕수육"; rcpitem2.price = 20000; rcpitem2.count = 1;
  //ReceiptItem rcpitem3 = ReceiptItem();
  rcpitem3.receiptItemName = "엄우네아 회식"; rcpitem3.price = 40000; rcpitem3.count = 1;

  //SettlementPaper stmpaper1 = SettlementPaper();
  stmpaper1.memberName = "신성민";
  //SettlementPaper stmpaper2 = SettlementPaper();
  stmpaper2.memberName = "박건우";
  //SettlementPaper stmpaper3 = SettlementPaper();
  stmpaper3.memberName = "류지원";
  //SettlementPaper stmpaper4 = SettlementPaper();
  stmpaper4.memberName = "조우석";
  paperlist = [stmpaper1,stmpaper2,stmpaper3,stmpaper4];

  await Query(db).createSettlement(stm);
  await Query(db).createReceipt(rcp1, stm.settlementId);
  await Query(db).createReceipt(rcp2, stm.settlementId);
  await Query(db).createReceiptItem(rcp1.receiptId, rcpitem1);
  await Query(db).createReceiptItem(rcp1.receiptId, rcpitem2);
  await Query(db).createReceiptItem(rcp2.receiptId, rcpitem3);
  await Query(db).createMembers(stm.settlementId, paperlist);

  //List<Map> res = await db.rawQuery('SELECT * FROM SAVEPOINT');
  //log("${res[0]["savepoint"]}");

}
