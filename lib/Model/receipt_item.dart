import 'package:uuid/uuid.dart';

class ReceiptItem{
  String receiptItemId = "";
  String receiptItemName = "새 제품";
  double price = 0;
  double individualPrice = 0;
  int count = 1;
  Map<String,int> paperOwner = {};

  ReceiptItem(){
    receiptItemId = const Uuid().v4();
  }
}