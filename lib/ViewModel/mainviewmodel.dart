import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/db_receiptitem.dart';
import 'package:sqlite_test/DB/db_settlementitem.dart';
import 'package:sqlite_test/DB/sqlflite_db.dart';
import 'package:sqlite_test/shared_tool.dart';
import '../Model/receipt.dart';
import '../Model/receipt_item.dart';
import '../Model/settlement.dart';
import '../Model/settlement_item.dart';
import '../Model/settlementpaper.dart';
import '../query.dart';

final mainProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainViewModel extends ChangeNotifier {
  late Database db;
  List<Settlement> settlementList = [];
  Settlement selectedSettlement = Settlement();

  List<List<List<TextEditingController>>> receiptItemControllerList = [];
  List<List<bool>> selectedReceiptItemIndexList = [];
  List<bool> selectedMemberIndexList = [];

  void setDB(Database db) {
    this.db = db;
    notifyListeners();
  }

  Future<void> fetchAllSettlements() async {
    settlementList = await Query(db).showAllSettlements();
    notifyListeners();
    return;
  }

  void settingSelectedSettlement() {
    selectedReceiptItemIndexList = List.generate(
        selectedSettlement.receipts.length,
        (index) => List.generate(
            selectedSettlement.receipts[index].receiptItems.length,
            (index) => false));

    selectedMemberIndexList = List.generate(
        selectedSettlement.settlementPapers.length, (index) => false);

    receiptItemControllerList = [];
    print(selectedSettlement.receipts.length);

    for (int i = 0; i < selectedSettlement.receipts.length; i++) {
      addReceiptItemControllerList();
      print(selectedSettlement.receipts[i].receiptItems.length);
      for (ReceiptItem receiptItem
          in selectedSettlement.receipts[i].receiptItems) {
        addReceiptItemTextEditingController(i, receiptItem);
      }
    }
  }

  List<dynamic> getReceiptInformationBySettlementPaper(int paperHashcode) {
    for (var receipt in selectedSettlement.receipts) {
      for (var receiptItem in receipt.receiptItems) {
        for (var code in receiptItem.paperOwner.values) {
          if (code == paperHashcode) {
            return [receipt.receiptName, receiptItem.price];
          }
        }
      }
    }
    return ["null", "null"];
  }

  void changeAllMember(bool changeBool) {
    selectedMemberIndexList =
        List.generate(selectedMemberIndexList.length, (index) => changeBool);
    notifyListeners();
  }

  void selectReceiptItem(int receiptIndex, int receiptItemIndex) {
    selectedReceiptItemIndexList[receiptIndex][receiptItemIndex] = true;
    notifyListeners();
  }

  void selectMember(int index) {
    selectedMemberIndexList[index] = !selectedMemberIndexList[index];
    notifyListeners();
  }

  Future<void> selectSettlement(int index) async {
    selectedSettlement = await Query(db).showRecentSettlement(settlementList[index].settlementId);
    print("sssssssss");
    for(int i = 0; i < selectedSettlement.receipts.length; i++)
      {
        print(selectedSettlement.receipts[i].receiptItems.length);
      }print("awefawefawef");
    settingSelectedSettlement();
    notifyListeners();
    return;
  }

  void unmatching(int receiptIndex, int receiptItemIndex, String paperId) async {
    String menuName = selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].receiptItemName;

    //change splitPrice
    double splitPrice = selectedSettlement
            .receipts[receiptIndex].receiptItems[receiptItemIndex].price /
        (selectedSettlement.receipts[receiptIndex]
                .receiptItems[receiptItemIndex].paperOwner.length -
            1);

    selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].paperOwner
        .forEach((key, value) {
      selectedSettlement.settlementPapers
          .firstWhere((element) => element.settlementPaperId == key)
          .settlementItems
          .firstWhere((element) => element.name == menuName)
          .splitPrice = splitPrice == double.infinity ? 0 : splitPrice;
    });

    //remove settlementItem from settlementPaper
    selectedSettlement.settlementPapers
        .firstWhere((element) => element.settlementPaperId == paperId)
        .settlementItems
        .removeWhere((element) =>
            element.hashCode ==
            selectedSettlement.receipts[receiptIndex]
                .receiptItems[receiptItemIndex].paperOwner[paperId]);
    await Query(db).unmatchingMemberFromReceiptItem(paperId, selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].receiptItemId);
    //remove paperOwner from receiptItem
    selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].paperOwner
        .removeWhere((key, value) => key == paperId);
    updateMemberTotalPrice();
    notifyListeners();
  }

  //여러 명 -> 한 아이템 매칭
  void batchMatching(int presentReceiptIndex) {
    for (int i = 0;
        i < selectedReceiptItemIndexList[presentReceiptIndex].length;
        i++) {
      if (selectedReceiptItemIndexList[presentReceiptIndex][i]) {
        for (int j = 0; j < selectedMemberIndexList.length; j++) {
          print(selectedMemberIndexList.length);
          if (selectedMemberIndexList[j]) {
            matching(j, i, presentReceiptIndex);
          }
        }
        selectedReceiptItemIndexList[presentReceiptIndex][i] = false;
        updateSettlementItemSplitPrice(presentReceiptIndex, i);
      }
    }
    updateMemberTotalPrice();
    notifyListeners();
  }

  //한 명 -> 한 아이템 매칭
  void matching(int userIndex, int itemIndex, int receiptIndex) async {
    //if already matched
    if (selectedSettlement
        .receipts[receiptIndex].receiptItems[itemIndex].paperOwner
        .containsKey(
            selectedSettlement.settlementPapers[userIndex].settlementPaperId)) {
      return;
    }

    //add settlementItem to settlementPaper
    SettlementItem newSettlementItem = SettlementItem(selectedSettlement
        .receipts[receiptIndex].receiptItems[itemIndex].receiptItemName);
    selectedSettlement.settlementPapers[userIndex].settlementItems
        .add(newSettlementItem);
    await Query(db).matchingMemberToReceiptItem(selectedSettlement.settlementPapers[userIndex].settlementPaperId, selectedSettlement
        .receipts[receiptIndex].receiptItems[itemIndex].receiptItemId);

    //add paperOwner to receiptItem
    selectedSettlement
                .receipts[receiptIndex].receiptItems[itemIndex].paperOwner[
            selectedSettlement.settlementPapers[userIndex].settlementPaperId] =
        selectedSettlement
            .settlementPapers[userIndex].settlementItems.last.hashCode;
  }

//영수증 이름 수정
  void editReceiptName(String newName, int receiptIndex) async {
    selectedSettlement.receipts[receiptIndex].receiptName = newName;
    await Query(db).updateReceiptName(
        newName, selectedSettlement.receipts[receiptIndex].receiptId);
    notifyListeners();
  }

//특정 인덱스의 정산 이름 수정
  void editSettlementName(String newName, int index) async {
    settlementList[index].settlementName = newName;
    await Query(db).updateSettlement(settlementList[index]);
    notifyListeners();
  }

//정산 이름 수정
  void editSelectedSettlementName(String newName) async {
    selectedSettlement.settlementName = newName;
    await Query(db).updateSettlement(selectedSettlement);
    notifyListeners();
  }

//멤버 이름 수정
  void editMemberName(String newName, int index) async {
    selectedSettlement.settlementPapers[index].memberName = newName;
    await Query(db).updateMemberName(newName, selectedSettlement.settlementPapers[index].settlementPaperId);
    notifyListeners();
  }

//ReceiptItem 이름 수정
  void editReceiptItemName(
      String newName, int receiptIndex, int receiptItemIndex) async {
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .receiptItemName = newName;
    editAllSettlementItemName(receiptIndex, receiptItemIndex, newName);
    await Query(db).updateReceiptItem(selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex]);
    notifyListeners();
  }

//ReceiptItem을 포함하는 모든 SettlementItem의 이름 수정
  void editAllSettlementItemName(
      int receiptIndex, int receiptItemIndex, String newName) {
    List<int> hashcodes = selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].paperOwner.values
        .toList();

    for (var papers in selectedSettlement.settlementPapers) {
      for (var stmItem in papers.settlementItems) {
        if (hashcodes.contains(stmItem.hashCode)) {
          stmItem.name = newName;
        }
      }
    }
    notifyListeners();
  }

//ReceiptItem 값 수정
  void editReceiptItemIndividualPrice(
      double newIndividualPrice, int receiptIndex, int receiptItemIndex) async {
    int count = selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].count;

    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .individualPrice = newIndividualPrice;
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .price = newIndividualPrice * count;

    receiptItemControllerList[receiptIndex][receiptItemIndex][1].text =
        priceToString.format(newIndividualPrice.truncate());
    receiptItemControllerList[receiptIndex][receiptItemIndex][3].text =
        priceToString.format(newIndividualPrice * count.truncate());

    updateReceiptTotalPrice(receiptIndex);

    updateMemberTotalPrice();
    updateSettlementItemSplitPrice(receiptIndex, receiptItemIndex);
    await Query(db).updateReceiptItem(selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex]);
    notifyListeners();
  }

  void editReceiptItemCount(
      int newCount, int receiptIndex, int receiptItemIndex) async {
    double individualPrice = selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].individualPrice;

    selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].count = newCount;
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .price = newCount * individualPrice;

    receiptItemControllerList[receiptIndex][receiptItemIndex][2].text =
        newCount.toString();
    receiptItemControllerList[receiptIndex][receiptItemIndex][3].text =
        priceToString.format(newCount * individualPrice.truncate());

    updateReceiptTotalPrice(receiptIndex);
    updateSettlementItemSplitPrice(receiptIndex, receiptItemIndex);
    updateMemberTotalPrice();
    await Query(db).updateReceiptItem(selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex]);
    notifyListeners();
  }

  void editReceiptItemPrice(
      double newPrice, int receiptIndex, int receiptItemIndex) async {
    selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].price = newPrice;
    int count = selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].count;
    double individulPrice = newPrice / count;
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .individualPrice = individulPrice;

    receiptItemControllerList[receiptIndex][receiptItemIndex][1].text =
        priceToString.format(individulPrice.truncate());
    receiptItemControllerList[receiptIndex][receiptItemIndex][3].text =
        priceToString.format(newPrice.truncate());

    updateReceiptTotalPrice(receiptIndex);

    updateMemberTotalPrice();
    updateSettlementItemSplitPrice(receiptIndex, receiptItemIndex);
    await Query(db).updateReceiptItem(selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex]);
    notifyListeners();
  }

  // ReceipitItemController에 접근할 때 가장 오른쪽 으로 Cursor 이동
  void moveReceiptItemControllerCursor(
      int receiptIndex, int receiptItemIndex, int index) {
    receiptItemControllerList[receiptIndex][receiptItemIndex][index].selection =
        TextSelection.fromPosition(TextPosition(
            offset: receiptItemControllerList[receiptIndex][receiptItemIndex]
                    [index]
                .text
                .length));
    notifyListeners();
  }

//수정된 ReceiptItem에 해당하는 SettlementItem의 splitPrice 수정
  void updateSettlementItemSplitPrice(int receiptIndex, int itemIndex) {
    double splitPrice = selectedSettlement
            .receipts[receiptIndex].receiptItems[itemIndex].price /
        selectedSettlement
            .receipts[receiptIndex].receiptItems[itemIndex].paperOwner.length;
    selectedSettlement.receipts[receiptIndex].receiptItems[itemIndex].paperOwner
        .forEach((key, value) {
      selectedSettlement.settlementPapers
          .firstWhere((element) {
            return element.settlementPaperId == key;
          })
          .settlementItems
          .firstWhere((element) {
            return element.hashCode == value;
          })
          .splitPrice = splitPrice;
    });
    notifyListeners();
  }

//값이 변경된 ReceiptItem의 Receipt와 Settlement의 totalPrice를 수정
  void updateReceiptTotalPrice(receiptIndex) {
    double total = 0;
    for (ReceiptItem receiptItem
        in selectedSettlement.receipts[receiptIndex].receiptItems) {
      total += receiptItem.price;
    }
    selectedSettlement.receipts[receiptIndex].totalPrice = total;
    total = 0;
    for (Receipt receipt in selectedSettlement.receipts) {
      total += receipt.totalPrice;
    }
    selectedSettlement.totalPrice = total;
    notifyListeners();
  }

//모든 사용자의 totalPrice를 수정
  void updateMemberTotalPrice() {
    for (var element in selectedSettlement.settlementPapers) {
      element.totalPrice = 0;
      for (var item in element.settlementItems) {
        element.totalPrice += item.splitPrice;
      }
    }
    notifyListeners();
  }

//정산 삭제
  void deleteSettlement(List<bool> indices) async {
    for (int i = indices.length - 1; i >= 0; i--) {
      if (indices[i]) {
        await Query(db).deleteSettlement(settlementList[i]);
        settlementList.removeAt(i);
      }
    }
    notifyListeners();
  }

//정산멤버 삭제
  void deleteMember(int index) async {
    String id = selectedSettlement.settlementPapers[index].settlementPaperId;
    deleteMemberDataFromSettlement(id);
    selectedSettlement.settlementPapers.removeAt(index);
    selectedMemberIndexList.removeAt(index);
    //매칭된거 지우기
    await Query(db).deleteMembers(selectedSettlement.settlementId, [id]);
    notifyListeners();
  }

//Receipt List로 삭제
  void deleteReceiptList(List<bool> isSelectedReceiptList) async {
    for (int i = isSelectedReceiptList.length - 1; i >= 0; i--) {
      if (isSelectedReceiptList[i]) {
        await Query(db).deleteReceipt(selectedSettlement.receipts[i].receiptId);
        await DBReceiptItem().deleteAllRcpItems(db, selectedSettlement.receipts[i].receiptId);
        selectedSettlement.receipts.removeAt(i);
        receiptItemControllerList.removeAt(i);
        selectedReceiptItemIndexList.removeAt(i);
      }
    }
    notifyListeners();
  }

  //ReceiptItem과 연관되어 있는 모든 SettlementItem 삭제
  void deleteSettlementItem(ReceiptItem rcpItem) async {
    rcpItem.paperOwner.forEach((key, value) {
      selectedSettlement.settlementPapers
          .firstWhere((element) => element.settlementPaperId == key)
          .settlementItems
          .removeWhere((element) => element.hashCode == value);
    });
    notifyListeners();
  }

//ReceiptList에 대해 ReceiptItemList로 삭제
  void deleteReceiptItemList(List<List<bool>> receiptItems) async {
    for (int i = receiptItems.length - 1; i >= 0; i--) {
      for (int j = receiptItems[i].length - 1; j >= 0; j--) {
        if (receiptItems[i][j]) {
          await DBReceiptItem().deleteReceiptItem(db, selectedSettlement.receipts[i].receiptItems[j].receiptItemId);
          await DBSettlementItem().deleteAllStmItemsByRcpItemId(db, selectedSettlement.receipts[i].receiptItems[j].receiptItemId);
          deleteSettlementItem(selectedSettlement.receipts[i].receiptItems[j]);
          selectedSettlement.receipts[i].receiptItems.removeAt(j);
          receiptItemControllerList[i].removeAt(j);
          selectedReceiptItemIndexList[i].removeAt(j);
        }
      }
      updateReceiptTotalPrice(i);
    }
    notifyListeners();
  }

//Member매칭정보 삭제
  void deleteMemberDataFromSettlement(String id) {
    for (int i = 0; i < selectedSettlement.receipts.length; i ++) {
      for (int j = 0; j < selectedSettlement.receipts[i].receiptItems.length; j++) {
        if (selectedSettlement.receipts[i].receiptItems[j].paperOwner.containsKey(id)) {
          selectedSettlement.receipts[i].receiptItems[j].paperOwner.remove(id);
          updateSettlementItemSplitPrice(i, j);
        }
      }
    }
    notifyListeners();
  }

//정산추가
  void addNewSettlement() async {
    settlementList.insert(0, Settlement());
    selectedSettlement = settlementList[0];
    await Query(db).createSettlement(selectedSettlement);
    addMember(["나"]);
    notifyListeners();
  }

//정산멤버 추가
  void addMember(List<String> memberName) async {
    List<SettlementPaper> newSettlementPapers = [];
    for (String name in memberName) {
      SettlementPaper newSettlementPaper = SettlementPaper();
      newSettlementPaper.memberName = name;
      selectedSettlement.settlementPapers.add(newSettlementPaper);
      newSettlementPapers.add(newSettlementPaper);
      addSelectedMemberIndexList();
    }
    await Query(db)
        .createMembers(selectedSettlement.settlementId, newSettlementPapers);
    notifyListeners();
  }

//정산멤버 관리 리스트 (Matching시 isSelected로 사용)
  void addSelectedMemberIndexList() {
    selectedMemberIndexList.add(false);
  }

//Receipt 추가
  void addReceipt() async {
    Receipt newReceipt = Receipt();
    newReceipt.receiptId = DateTime.now().toString();
    selectedSettlement.receipts.add(newReceipt);

    addReceiptItemControllerList();
    addSelectedReceiptItemIndexList();
    await Query(db).createReceipt(newReceipt, selectedSettlement.settlementId);
    notifyListeners();
  }

//ReceiptItem 입력 Controller list, 빈List를 추가 (정산정보입력시 사용)
  void addReceiptItemControllerList() {
    receiptItemControllerList.add([]);
  }

//ReceiptItem 선택 리스트, 빈list 추가 (Matching시 isSelected로 사용)
  void addSelectedReceiptItemIndexList() {
    selectedReceiptItemIndexList.add([]);
  }

//ReceiptItem 추가
  void addReceiptItem(int index) async {
    ReceiptItem newReceiptItem = ReceiptItem();
    selectedSettlement.receipts[index].receiptItems.add(newReceiptItem);

    addReceiptItemTextEditingController(index, newReceiptItem);
    addSelectedReceiptItemIndexListItem(index);
    await Query(db).createReceiptItem(
        selectedSettlement.receipts[index].receiptId, newReceiptItem);
    notifyListeners();
  }

//ReceiptItem 입력 Controller, TextEditing Controller 4개 추가
  void addReceiptItemTextEditingController(
      int index, ReceiptItem newReceiptItem) {
    receiptItemControllerList[index]
        .add(List.generate(4, (index) => TextEditingController()));

    initializeReceiptItemController(index, newReceiptItem);
  }

//ReceiptItem 선택 리스트, index번째에 false인 ReceiptItem isSelected 추가
  void addSelectedReceiptItemIndexListItem(int index) {
    selectedReceiptItemIndexList[index].add(false);
  }

//ReceiptItem TextEditingController 초기화
  void initializeReceiptItemController(int index, ReceiptItem newReceiptItem) {
    receiptItemControllerList[index]
            [receiptItemControllerList[index].length - 1][0]
        .text = newReceiptItem.receiptItemName;
    receiptItemControllerList[index]
            [receiptItemControllerList[index].length - 1][1]
        .text = newReceiptItem.individualPrice.toInt().toString();
    receiptItemControllerList[index]
            [receiptItemControllerList[index].length - 1][2]
        .text = newReceiptItem.count.toString();
    receiptItemControllerList[index]
            [receiptItemControllerList[index].length - 1][3]
        .text = newReceiptItem.price.toInt().toString();
  }

  void loadMemberList(int index) async {
    List<String> memberNameList = List.generate(
        selectedSettlement.settlementPapers.length,
        (index) => selectedSettlement.settlementPapers[index].memberName);
        List<String> newMemberList = [];
    for (int i = 1; i < settlementList[index].settlementPapers.length; i++) {
      if (memberNameList
          .contains(settlementList[index].settlementPapers[i].memberName)) {
        continue;
      }
      newMemberList.add(settlementList[index].settlementPapers[i].memberName);
    }
    addMember(newMemberList);
    notifyListeners();
  }
}
