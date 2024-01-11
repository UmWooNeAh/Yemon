import 'package:uuid/uuid.dart';

import 'Receipt.dart';
import 'SettlementPaper.dart';

class Settlement{
  String settlementId = "";
  String settlementName = "";
  double totalPrice = 0;
  DateTime date = DateTime.now();
  List<Receipt> receipts = [];
  List<SettlementPaper> settlementPapers = [];

  Settlement(){
    settlementId = const Uuid().v4();
    settlementName = "새 정산";
    date = DateTime.now();
  }
}
