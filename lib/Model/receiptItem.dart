import 'package:uuid/uuid.dart';

class ReceiptItem{
  String receiptItemId = "";
  String receiptItemName = "";
  double price = 0;
  int count = 0;
  Map<String,String> paperOwner = {};

  ReceiptItem(){
    receiptItemId = const Uuid().v4();
  }
}