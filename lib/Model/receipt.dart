import 'package:uuid/uuid.dart';
import 'receipt_item.dart';

class Receipt{
  String receiptId = "";
  String receiptName = "새 영수증";
  double totalPrice = 0;
  List<ReceiptItem> receiptItems = [];

  Receipt(){
    receiptId = const Uuid().v4();
  }
}
