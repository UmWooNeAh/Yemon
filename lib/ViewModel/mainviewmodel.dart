import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/shared_tool.dart';
import '../Model/Receipt.dart';
import '../Model/ReceiptItem.dart';
import '../Model/Settlement.dart';
import '../Model/SettlementItem.dart';
import '../Model/SettlementPaper.dart';

final mainProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainViewModel extends ChangeNotifier {
  List<Settlement> settlementList = [];
  Settlement selectedSettlement = Settlement();
  List<List<List<TextEditingController>>> receiptItemControllerList = [];

  void editMemberName(String newName, int index) {
    selectedSettlement.settlementPapers[index].memberName = newName;
    notifyListeners();
  }

  void matching(int userIndex,int itemIndex,int receiptIndex){
    SettlementItem newSettlementItem = SettlementItem();
    ReceiptItem receiptItem = selectedSettlement.receipts[receiptIndex].receiptItems[itemIndex];
    double splitPrice = receiptItem.price / (receiptItem.paperOwner.length + 1);

    selectedSettlement.receipts[receiptIndex].receiptItems[itemIndex].paperOwner.forEach((key, value) {
      selectedSettlement.settlementPapers.firstWhere((element){return element.settlementPaperId == key;})
          .settlementItems.firstWhere((element){return element.name == receiptItem.receiptItemName;}).splitPrice = splitPrice;
    });

    selectedSettlement.receipts[receiptIndex].receiptItems[itemIndex].paperOwner[selectedSettlement.settlementPapers[userIndex].settlementPaperId] = selectedSettlement.settlementPapers[userIndex].memberName;
    newSettlementItem.name = selectedSettlement.receipts[receiptIndex].receiptItems[itemIndex].receiptItemName;
    newSettlementItem.splitPrice = splitPrice;
    selectedSettlement.settlementPapers[userIndex].settlementItems.add(newSettlementItem);

    selectedSettlement.receipts[receiptIndex].receiptItems[itemIndex].paperOwner.forEach((key, value) {
      print(selectedSettlement.settlementPapers.firstWhere((element) => element.settlementPaperId == key).memberName);
      print(selectedSettlement.settlementPapers.firstWhere((element) => element.settlementPaperId == key).settlementItems.firstWhere((element) => element.name == receiptItem.receiptItemName).splitPrice);
    });
    notifyListeners();
  }


  void updateTotalPrice(receiptIndex) {
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

  void addReceiptItemTextEditingController(int index) {
    receiptItemControllerList[index]
        .add(List.generate(4, (index) => TextEditingController()));
    notifyListeners();
  }

  void deleteReceiptItemTextEditingController(int i, int j) {
    receiptItemControllerList[i].removeAt(j);
    notifyListeners();
  }

  void editReceiptItemName(
      String newName, int receiptIndex, int receiptItemIndex) {
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .receiptItemName = newName;
    notifyListeners();
  }

  void editReceiptItemIndividualPrice(
      double newIndividualPrice, int receiptIndex, int receiptItemIndex) {
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
        .individualPrice = newIndividualPrice;
    selectedSettlement
            .receipts[receiptIndex].receiptItems[receiptItemIndex].price =
        newIndividualPrice *
            selectedSettlement
                .receipts[receiptIndex].receiptItems[receiptItemIndex].count;
    receiptItemControllerList[receiptIndex][receiptItemIndex][1].text =
        priceToString.format(selectedSettlement.receipts[receiptIndex]
            .receiptItems[receiptItemIndex].individualPrice
            .truncate());
    receiptItemControllerList[receiptIndex][receiptItemIndex][3].text =
        priceToString.format(selectedSettlement
            .receipts[receiptIndex].receiptItems[receiptItemIndex].price
            .truncate());
    updateTotalPrice(receiptIndex);
    notifyListeners();
  }

  void editReceiptItemCount(
      int newCount, int receiptIndex, int receiptItemIndex) {
    selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].count = newCount;
    selectedSettlement
            .receipts[receiptIndex].receiptItems[receiptItemIndex].price =
        newCount *
            selectedSettlement.receipts[receiptIndex]
                .receiptItems[receiptItemIndex].individualPrice;
    receiptItemControllerList[receiptIndex][receiptItemIndex][3].text =
        priceToString.format(selectedSettlement
            .receipts[receiptIndex].receiptItems[receiptItemIndex].price
            .truncate());

    updateTotalPrice(receiptIndex);
    notifyListeners();
  }

  void editReceiptItemPrice(
      double newPrice, int receiptIndex, int receiptItemIndex) {
    selectedSettlement
        .receipts[receiptIndex].receiptItems[receiptItemIndex].price = newPrice;
    selectedSettlement.receipts[receiptIndex].receiptItems[receiptItemIndex]
            .individualPrice =
        newPrice /
            selectedSettlement
                .receipts[receiptIndex].receiptItems[receiptItemIndex].count;
    receiptItemControllerList[receiptIndex][receiptItemIndex][1].text =
        priceToString.format(selectedSettlement.receipts[receiptIndex]
            .receiptItems[receiptItemIndex].individualPrice
            .truncate());

    receiptItemControllerList[receiptIndex][receiptItemIndex][3].text =
        priceToString.format(selectedSettlement
            .receipts[receiptIndex].receiptItems[receiptItemIndex].price
            .truncate());

    updateTotalPrice(receiptIndex);
    notifyListeners();
  }

  void editReceiptName(String newName, int receiptIndex) {
    selectedSettlement.receipts[receiptIndex].receiptName = newName;
    notifyListeners();
  }

  void loadMemberList(int index) {
    for (SettlementPaper settlementPaper
        in settlementList[index].settlementPapers) {
      SettlementPaper newSettlementPaper = SettlementPaper();
      newSettlementPaper.memberName = settlementPaper.memberName;
      selectedSettlement.settlementPapers.add(newSettlementPaper);
    }
    notifyListeners();
  }

  void deleteSettlement(int index) {
    settlementList.removeAt(index);
    notifyListeners();
  }

  void editSettlementName(String newName) {
    selectedSettlement.settlementName = newName;
    notifyListeners();
  }

  void deleteReceiptItemList(List<List<bool>> receiptItems) {
    for (int i = receiptItems.length - 1; i >= 0; i--) {
      for (int j = receiptItems[i].length - 1; j >= 0; j--) {
        if (receiptItems[i][j]) {
          selectedSettlement.receipts[i].receiptItems.removeAt(j);
          deleteReceiptItemTextEditingController(i, j);
        }
      }
    }
    notifyListeners();
  }

  void deleteReceiptList(List<bool> receipts) {
    for (int i = receipts.length - 1; i >= 0; i--) {
      if (receipts[i]) {
        selectedSettlement.receipts.removeAt(i);
        receiptItemControllerList.removeAt(i);
      }
    }
    print(selectedSettlement.receipts.length);
    notifyListeners();
  }

  void addReceipt() {
    Receipt newReceipt = Receipt();
    newReceipt.receiptId = DateTime.now().toString();
    selectedSettlement.receipts.add(newReceipt);
    receiptItemControllerList.add([]);
    notifyListeners();
  }

  void addReceiptItem(int index) {
    ReceiptItem newReceiptItem = ReceiptItem();
    selectedSettlement.receipts[index].receiptItems.add(newReceiptItem);
    addReceiptItemTextEditingController(index);
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
    notifyListeners();
  }

  void addMember(String memberName) {
    SettlementPaper newSettlementPaper = SettlementPaper();
    newSettlementPaper.memberName = memberName;
    selectedSettlement.settlementPapers.add(newSettlementPaper);
    notifyListeners();
  }

  void deleteMember(int index) {
    String id = selectedSettlement.settlementPapers[index].settlementPaperId;
    for (Receipt receipt in selectedSettlement.receipts) {
      for (ReceiptItem receiptItem in receipt.receiptItems) {
        if (receiptItem.paperOwner.containsKey(id)) {
          receiptItem.paperOwner.remove(id);
        }
      }
    }
    selectedSettlement.settlementPapers.removeAt(index);
    notifyListeners();
  }

  void deleteMemberFromReceiptItem(
      ReceiptItem receiptItem, String haveToRemovedId) {
    receiptItem.paperOwner.remove(haveToRemovedId);
    List<String> updateUserIdList = receiptItem.paperOwner.keys.toList();
    for (SettlementPaper settlementPaper
        in selectedSettlement.settlementPapers) {
      if (updateUserIdList.contains(settlementPaper.settlementPaperId)) {
        for (SettlementItem settlementItem in settlementPaper.settlementItems) {
          // if (settlementItem.receiptItemId == receiptItem.receiptItemId){
          //   settlementItem.splitPrice = receiptItem.price / updateUserIdList.length;
          // }
        }
      }
    }
  }
}
