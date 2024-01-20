import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';

class SettlementMatchingViewmodel extends ChangeNotifier{
  int presentReceiptIndex = 0;
  List<bool> selectedReceiptItemIndexList = [];
  List<bool> selectedMemberIndexList = [];

  void settingMemberIndexList(int length){
    selectedMemberIndexList = List.generate(length, (index) => false);
    notifyListeners();
  }

  void selectReceipt(int index,int receiptItemLength){
    presentReceiptIndex = index;
    selectedMemberIndexList = List.generate(selectedMemberIndexList.length, (index) => false);
    selectedReceiptItemIndexList = List.generate(receiptItemLength, (index) => false);
    notifyListeners();
  }

  void selectReceiptItem(int index){
    selectedReceiptItemIndexList[index] = !selectedReceiptItemIndexList[index];
    notifyListeners();
  }

  void selectMember(int index){
    selectedMemberIndexList[index] = !selectedMemberIndexList[index];
    notifyListeners();
  }
}

class SettlementMatching extends ConsumerStatefulWidget {
  const SettlementMatching({super.key});

  @override
  ConsumerState<SettlementMatching> createState() => _SettlementMatchingState();
}

class _SettlementMatchingState extends ConsumerState<SettlementMatching> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: basic[6],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        ReceiptCirculator(),
        MenuSheet(),
        GroupMembers(),
      ],
    );
  }
}


class MenuSheet extends ConsumerWidget {
  const MenuSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return const Placeholder();
  }
}

class GroupMembers extends ConsumerWidget {
  const GroupMembers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return const Placeholder();
  }
}

class ReceiptCirculator extends ConsumerWidget {
  const ReceiptCirculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return const Placeholder();
  }
}





