import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/View/settlement_matching.dart';
import 'package:sqlite_test/shared_tool.dart';
import '../Model/receipt_item.dart';
import '../Model/settlement_item.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';

class MenuSheet extends ConsumerWidget {
  const MenuSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final mProvider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    return Container(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "메뉴 목록",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: size.width * 0.15),
                Container(
                  width: 120,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {
                      // print("receipt item");
                      // mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems.forEach((element) {
                      //   print(element.receiptItemName);
                      //   element.paperOwner.forEach((key, value) {
                      //     print("${key} : ${value}");
                      //   });
                      // });
                      // print("stmPaper");
                      // mProvider.selectedSettlement.settlementPapers.forEach((paper) {
                      //   print(paper.memberName);
                      //   paper.settlementItems.forEach((element){
                      //     print("${element.name} ${element.splitPrice}");
                      //   });
                      // });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: basic[1],
                    ),
                    child: Center(
                      child: Text(
                        "전체 매칭",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: basic[2],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height:
                    mProvider.selectedSettlement.receipts.isEmpty ? 50 : 10),
            sProvider.presentReceiptIndex == -1
                ? Container(
                    height: 50,
                    width: 50,
                    color: Colors.red,
                    child: Text("전체영수증 만들어줘"),
                  )
                : (mProvider.selectedSettlement.receipts.isEmpty
                    ? const Text("메뉴가 없습니다.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ))
                    : SingleChildScrollView(
                        child: Column(
                            children: List.generate(
                        mProvider
                            .selectedSettlement
                            .receipts[sProvider.presentReceiptIndex]
                            .receiptItems
                            .length,
                        (index) => SingleMenu(index: index),
                      ))))
          ],
        ),
      ),
    );
  }
}

class SingleMenu extends ConsumerStatefulWidget {
  final int index;
  const SingleMenu({super.key, required this.index});

  @override
  ConsumerState<SingleMenu> createState() => _SingleMenuState();
}

class _SingleMenuState extends ConsumerState<SingleMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sProvider = ref.watch(settlementMatchingProvider);
    final mProvider = ref.watch(mainProvider);
    final rcpItem = mProvider.selectedSettlement
        .receipts[sProvider.presentReceiptIndex].receiptItems[widget.index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            mProvider.selectReceiptItem(sProvider.presentReceiptIndex, widget.index);
            if (mProvider.selectedMemberIndexList.contains(true)) {
              mProvider.batchMatching(sProvider.presentReceiptIndex);
            } else {
              sProvider.toggleMatchingDetail(widget.index);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: sProvider.showMatchingDetail == widget.index ? 50 : 50,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 40),
                      width: size.width * 0.25,
                      child: Text(
                        rcpItem.receiptItemName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      //margin: const EdgeInsets.only(right:20,left:10),
                      width: size.width * 0.25,
                      child: Text(
                        "${mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems[widget.index].paperOwner.length} 명",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: basic[2],
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.3,
                      child: Text(
                        "${priceToString.format(rcpItem.price)} 원",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size.width,
          height: sProvider.showMatchingDetail == widget.index ? 120 : 0,
          color: basic[1],
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRect(
            child: Wrap(
              children: List.generate(
                  mProvider
                      .selectedSettlement
                      .receipts[sProvider.presentReceiptIndex]
                      .receiptItems[widget.index]
                      .paperOwner
                      .length,
                  (idx) => SingleSettlementMember(
                      stmPaperId: mProvider
                          .selectedSettlement
                          .receipts[sProvider.presentReceiptIndex]
                          .receiptItems[widget.index]
                          .paperOwner
                          .keys
                          .toList()[idx],
                      receiptItemIndex: widget.index)),
            ),
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}

class SingleSettlementMember extends ConsumerWidget {
  final String stmPaperId;
  final int receiptItemIndex;
  const SingleSettlementMember(
      {Key? key, required this.stmPaperId, required this.receiptItemIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sProvider = ref.watch(settlementMatchingProvider);
    final mProvider = ref.watch(mainProvider);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: basic[0],
            border: Border.all(
              color: basic[2],
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
          child: Column(
            children: [
              const SizedBox(height: 5),
              Text(
                mProvider.selectedSettlement.settlementPapers
                    .firstWhere(
                        (element) => element.settlementPaperId == stmPaperId)
                    .memberName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          child: InkWell(
            onTap: () {
              mProvider.unmatching(
                  sProvider.presentReceiptIndex, receiptItemIndex, stmPaperId);
            },
            child: Container(
              width: 15,
              height: 15,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset('assets/Delete.png'),
              ),
            ),
          ),
        )
      ],
    );
  }
}
