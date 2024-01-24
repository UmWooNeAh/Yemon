import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/View/menu_sheet.dart';
import 'package:sqlite_test/View/receipt_circulator.dart';

import '../Model/ReceiptItem.dart';
import '../Model/SettlementPaper.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';
import 'bottom_sheet.dart';

final settlementMatchingProvider = ChangeNotifierProvider((ref) => SettlementMatchingViewmodel());

class SettlementMatchingViewmodel extends ChangeNotifier{
  ScrollController receiptScrollController = ScrollController();
  int presentReceiptIndex = 0;
  List<bool> selectedReceiptItemIndexList = [];
  List<bool> selectedMemberIndexList = [false,];
  bool showMemberDetail = false;
  int showMatchingDetail = -1;

  void toggleMatchingDetail(int index){
    showMatchingDetail = index;
    notifyListeners();
  }

  void settingMemberIndexList(int length){
    selectedMemberIndexList = List.generate(length, (index) => false);
    notifyListeners();
  }

  void settingReceiptItemIndexList(int length){
    selectedReceiptItemIndexList = List.generate(length, (index) => false);
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

  void changeAllMember(bool value){
    selectedMemberIndexList = List.generate(selectedMemberIndexList.length, (index) => value);
    notifyListeners();
  }


  void toggleMemberDetail(){
    showMemberDetail = !showMemberDetail;
    notifyListeners();
  }

  List<int> matching(){
     return selectedMemberIndexList.asMap().keys.where((index) => selectedMemberIndexList[index] == true).toList();
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
    final size =  MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: basic[8],
          ),
        ),
        const ReceiptCirculator(),
        const CustomBottomSheet(childWidget: MenuSheet(),),
        Positioned(
          bottom: 0,
          child: GroupMembers()
        ),
      ],
    );
  }
}

class GroupMembers extends ConsumerWidget {
  const GroupMembers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final provider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size.width,
          height: sProvider.showMemberDetail ? 250 : 100,
          decoration: BoxDecoration(
            color: basic[1],
            borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight:Radius.circular(20)),

            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 1,
                  spreadRadius: 3
              ),
            ],
          ),
          child:
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("정산에 참여하는 사람",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: size.width*0.2),
                    OutlinedButton(
                      onPressed: () {
                        sProvider.changeAllMember(!sProvider.selectedMemberIndexList.contains(true));
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Center(
                        child: Text(sProvider.selectedMemberIndexList.contains(true) ? "선택 취소" : "전체 선택",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF848484),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: size.width*0.95,
                  child: sProvider.showMemberDetail ? Wrap(
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: List.generate(provider.selectedSettlement.settlementPapers.length,
                            (index) => SingleMember(index: index)),
                  ) : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(provider.selectedSettlement.settlementPapers.length,
                              (index) => SingleMember(index: index)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
        Positioned(
          left: size.width*0.5-20,
          child: GestureDetector(
            onTap:(){
              sProvider.toggleMemberDetail();
            },
            child:Transform.scale(
              scale: 1.5,
              child: sProvider.showMemberDetail ? Icon(Icons.keyboard_arrow_down) : Icon(Icons.keyboard_arrow_up),
            )
          ),
        )
      ],
    );
  }
}

class SingleMember extends ConsumerWidget {
  final int index;
  const SingleMember({Key? key,required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    return InkWell(
      onTap:(){
        sProvider.selectMember(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: sProvider.selectedMemberIndexList[index] ? basic[8] : basic[0],
          border: Border.all(
            color: sProvider.selectedMemberIndexList[index] ? basic[8] : basic[2],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 1,
                offset: const Offset(1.5,1.5),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(height:5),
            Text(provider.selectedSettlement.settlementPapers[index].memberName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: sProvider.selectedMemberIndexList[index] ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







