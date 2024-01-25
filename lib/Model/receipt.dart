import 'package:uuid/uuid.dart';
import 'receipt_item.dart';

class Receipt{
  String receiptId = "";
  String receiptName = "New Receipt";
  double totalPrice = 0;
  List<ReceiptItem> receiptItems = [];

  Receipt(){
    receiptId = const Uuid().v4();
  }
}
