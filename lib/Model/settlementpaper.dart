import 'package:uuid/uuid.dart';

import 'SettlementItem.dart';

class SettlementPaper{
  String settlementPaperId = "";
  String memberName = "";
  double totalPrice = 0;
  List<SettlementItem> settlementItems = [];

  SettlementPaper(){
    settlementPaperId = const Uuid().v4();
  }
}