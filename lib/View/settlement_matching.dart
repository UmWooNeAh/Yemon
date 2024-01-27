import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/View/menu_sheet.dart';
import 'package:sqlite_test/View/receipt_circulator.dart';
import '../Model/receipt_item.dart';
import '../Model/settlementpaper.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';
import 'bottom_sheet.dart';

final settlementMatchingProvider =
    ChangeNotifierProvider((ref) => SettlementMatchingViewmodel());

class SettlementMatchingViewmodel extends ChangeNotifier {
  int presentReceiptIndex = -1;
  int showMatchingDetailReceiptIndex = -1;
  int showMatchingDetailItemIndex = -1;
  bool showMemberDetail = false;


  void showMatchingDetail(int receiptIndex,int index) {
    showMatchingDetailReceiptIndex = receiptIndex;
    showMatchingDetailItemIndex = index;
    notifyListeners();
  }

  void toggleMatchingDetail(int receiptIndex,int index) {
    if (showMatchingDetailItemIndex == index && showMatchingDetailReceiptIndex == receiptIndex){
      showMatchingDetailItemIndex = -1;
    } else {
      showMatchingDetailItemIndex = index;
    }
    showMatchingDetailReceiptIndex = receiptIndex;
    notifyListeners();
  }

  void toggleMemberDetail() {
    showMemberDetail = !showMemberDetail;
    notifyListeners();
  }

  void selectReceipt(int index) {
    presentReceiptIndex = index;
    showMatchingDetailItemIndex = -1;
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
          decoration: BoxDecoration(
            color: basic[8],
          ),
        ),
        const ReceiptCirculator(),
        const CustomBottomSheet(
          childWidget: MenuSheet(),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 101,
            color: basic[0],
          ),
        ),
        const Positioned(bottom: 0, child: GroupMembers()),
      ],
    );
  }
}

class GroupMembers extends ConsumerWidget {
  const GroupMembers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final provider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    return Stack(
      children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size.width,
            height: sProvider.showMemberDetail ? 250 : 100,
            decoration: BoxDecoration(
              color: basic[1],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: basic[6],
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => sProvider.toggleMemberDetail(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: basic[1],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const Text(
                            "정산에 참여하는 사람",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10, right: 15),
                          height: 37,
                          width: 100,
                          child: OutlinedButton(
                            onPressed: () {
                              provider.changeAllMember(!provider
                                  .selectedMemberIndexList
                                  .contains(true));
                            },
                            style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: provider.selectedMemberIndexList
                                            .contains(true)
                                        ? basic[2]
                                        : basic[8],
                                    width: 1.5)),
                            child: Center(
                              child: Text(
                                provider.selectedMemberIndexList
                                        .contains(true)
                                    ? "선택 취소"
                                    : "전체 선택",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: basic[5],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: size.width * 0.95,
                    child: sProvider.showMemberDetail
                        ? SingleChildScrollView(
                          child: Wrap(
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: List.generate(
                                  provider
                                      .selectedSettlement.settlementPapers.length,
                                  (index) => SingleMember(index: index)),
                            ),
                        )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  provider.selectedSettlement.settlementPapers
                                      .length,
                                  (index) => SingleMember(index: index)),
                            ),
                          ),
                  ),
                ),
              ],
            )),
        Positioned(
          top: 0,
          left: size.width * 0.5 - 15,
          child: GestureDetector(
            onTap: () => sProvider.toggleMemberDetail(),
            child: SizedBox(
              height: 30,
              width: 30,
              child: FittedBox(
                fit: BoxFit.fill,
                child: sProvider.showMemberDetail
                    ? const Icon(Icons.keyboard_arrow_down)
                    : const Icon(Icons.keyboard_arrow_up),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class SingleMember extends ConsumerWidget {
  final int index;
  const SingleMember({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    return InkWell(
      onTap: () {
        provider.selectMember(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: provider.selectedMemberIndexList[index] ? basic[8] : basic[0],
          border: Border.all(
            color:
                provider.selectedMemberIndexList[index] ? basic[8] : basic[2],
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 1,
              offset: const Offset(1.5, 1.5),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          provider.selectedSettlement.settlementPapers[index].memberName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                provider.selectedMemberIndexList[index] ? basic[0] : basic[5],
          ),
        ),
      ),
    );
  }
}
