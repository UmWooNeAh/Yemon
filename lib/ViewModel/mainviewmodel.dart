import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/Settlement.dart';

final mainProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainViewModel extends ChangeNotifier{
  List<Settlement> settlementList = [];
  Settlement selectedSettlement = Settlement();
}