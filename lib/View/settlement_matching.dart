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
  int showMatchingDetail = -1;
  bool showMemberDetail = false;

  void toggleMatchingDetail(int index) {
    if (showMatchingDetail == index) {
      showMatchingDetail = -1;
    } else {
      showMatchingDetail = index;
    }
    notifyListeners();
  }

  void toggleMemberDetail() {
    showMemberDetail = !showMemberDetail;
    notifyListeners();
  }

  void selectReceipt(int index) {
    presentReceiptIndex = index;
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
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 1,
                    spreadRadius: 3),
              ],
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        "정산에 참여하는 사람",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: size.width * 0.2),
                      OutlinedButton(
                        onPressed: () {
                          provider.changeAllMember(!provider.selectedMemberIndexList.contains(true));
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: provider.selectedMemberIndexList.contains(true) ? basic[2] : basic[8],
                              width: 1.5,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            provider.selectedMemberIndexList.contains(true)
                                ? "선택 취소"
                                : "전체 선택",
                            style: const TextStyle(
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
                    width: size.width * 0.95,
                    child: sProvider.showMemberDetail
                        ? Wrap(
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: List.generate(
                                provider
                                    .selectedSettlement.settlementPapers.length,
                                (index) => SingleMember(index: index)),
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
                ],
              ),
            )),
        Positioned(
          top: 0,
          left: size.width * 0.5 - 75,
          child: GestureDetector(
              onTap: () {
                sProvider.toggleMemberDetail();
              },
              child: Container(
                height: 30,
                width: 150,
                color: basic[1],
                child: Center(
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
              )),
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
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: provider.selectedMemberIndexList[index] ? basic[8] : basic[0],
          border: Border.all(
            color:
                provider.selectedMemberIndexList[index] ? basic[8] : basic[2],
            width: 2,
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
            color: provider.selectedMemberIndexList[index]
                ? basic[0]
                : basic[5],
          ),
        ),
      ),
    );
  }
}
