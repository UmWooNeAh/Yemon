import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/Receipt.dart';
import '../Model/ReceiptItem.dart';
import '../Model/Settlement.dart';
import '../Model/SettlementItem.dart';
import '../Model/SettlementPaper.dart';

final mainProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainViewModel extends ChangeNotifier {
  List<Settlement> settlementList = [];
  Settlement selectedSettlement = Settlement();

  void editSettlementName(String newName){
    selectedSettlement.settlementName = newName;
    notifyListeners();
  }

  void deleteReceiptItemList(List<List<bool>> receiptItems){
    for (int i = receiptItems.length - 1; i >= 0; i--){
      for (int j = receiptItems[i].length - 1; j >= 0; j--){
        if (receiptItems[i][j]){
          selectedSettlement.receipts[i].receiptItems.removeAt(j);
        }
      }
    }
    notifyListeners();
  }

  void deleteReceiptList(List<bool> receipts){
    for (int i = receipts.length - 1; i >= 0; i--){
      if (receipts[i]){
        selectedSettlement.receipts.removeAt(i);
      }
    }
    notifyListeners();
  }

  void addReceipt(){
    Receipt newReceipt = Receipt();
    newReceipt.receiptId = DateTime.now().toString();
    selectedSettlement.receipts.add(newReceipt);
    notifyListeners();
  }

  void addReceiptItem(int index){
    ReceiptItem newReceiptItem = ReceiptItem();
    newReceiptItem.receiptItemId = DateTime.now().toString();
    selectedSettlement.receipts[index].receiptItems.add(newReceiptItem);
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

  void deleteMemberFromReceiptItem(ReceiptItem receiptItem, String haveToRemovedId) {
    receiptItem.paperOwner.remove(haveToRemovedId);
    List<String> updateUserIdList = receiptItem.paperOwner.keys.toList();
    for (SettlementPaper settlementPaper in selectedSettlement.settlementPapers){
      if (updateUserIdList.contains(settlementPaper.settlementPaperId)){
        for(SettlementItem settlementItem in settlementPaper.settlementItems){
          // if (settlementItem.receiptItemId == receiptItem.receiptItemId){
          //   settlementItem.splitPrice = receiptItem.price / updateUserIdList.length;
          // }
        }
      }
    }
  }
}
