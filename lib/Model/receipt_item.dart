import 'package:uuid/uuid.dart';

class ReceiptItem{
  String receiptItemId = "";
  String receiptItemName = "newItem";
  double price = 0;
  double individualPrice = 0;
  int count = 1;
  Map<String,int> paperOwner = {};

  ReceiptItem(){
    receiptItemId = const Uuid().v4();
  }
}