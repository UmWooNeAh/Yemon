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
    return Column(
      children: [
        Container(
          width: size.width * 0.15,
          height: 3,
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              color: basic[2], borderRadius: BorderRadius.circular(10)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width - 120 - 30 - 30,
              margin: const EdgeInsets.only(left: 30),
              child: Text(
                sProvider.presentReceiptIndex == -1
                    ? "영수증 모아보기 "
                    : mProvider.selectedSettlement
                        .receipts[sProvider.presentReceiptIndex].receiptName,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color:
                      sProvider.presentReceiptIndex == -1 ? basic[9] : basic[5],
                ),
              ),
            ),
            Container(
              width: 105,
              height: 35,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                onPressed: () {
                  if (sProvider.presentReceiptIndex == -1) {
                    mProvider.matchAllSettlementItem();
                  } else {
                    for (int i = 0;
                        i <
                            mProvider
                                .selectedReceiptItemIndexList[
                                    sProvider.presentReceiptIndex]
                                .length;
                        i++) {
                      mProvider.selectReceiptItem(
                          sProvider.presentReceiptIndex, i);
                    }
                    mProvider.batchMatching(sProvider.presentReceiptIndex);
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor:
                      mProvider.selectedMemberIndexList.contains(true)
                          ? basic[8]
                          : basic[2],
                ),
                child: Center(
                  child: Text(
                    "전체 매칭",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: mProvider.selectedMemberIndexList.contains(true)
                          ? basic[0]
                          : basic[3],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
            height: mProvider.selectedSettlement.receipts.isEmpty ? 50 : 10),
        sProvider.presentReceiptIndex == -1
            ? Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: mProvider.selectedSettlement.receipts.length + 1,
                    itemBuilder: (context, receiptIndex) {
                      if (receiptIndex ==
                          mProvider.selectedSettlement.receipts.length) {
                        return const SizedBox(
                          height: 70,
                        );
                      }
                      return Column(
                        children: [
                          Container(
                            height: 30,
                            width: size.width,
                            padding: const EdgeInsets.only(left: 30, top: 5),
                            child: Text(
                              mProvider.selectedSettlement
                                  .receipts[receiptIndex].receiptName,
                              style: TextStyle(
                                color: basic[3],
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          mProvider.selectedSettlement.receipts[receiptIndex]
                                  .receiptItems.isEmpty
                              ? SizedBox(
                                  width: size.width,
                                  height: 50,
                                  child: Center(
                                    child: Text("영수증에 메뉴가 없습니다.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: basic[4],
                                        )),
                                  ),
                                )
                              : Column(
                                  children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .receipts[receiptIndex]
                                      .receiptItems
                                      .length,
                                  (index) => SingleMenu(
                                    index: index,
                                    receiptIndex: receiptIndex,
                                  ),
                                )),
                          const SizedBox(height: 40),
                        ],
                      );
                    }),
              )
            : mProvider
                    .selectedSettlement
                    .receipts[sProvider.presentReceiptIndex]
                    .receiptItems
                    .isEmpty
                ? SizedBox(
                    width: size.width,
                    height: 50,
                    child: Center(
                      child: Text("영수증에 메뉴가 없습니다.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: basic[4],
                          )),
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                            children: List.generate(
                      mProvider
                              .selectedSettlement
                              .receipts[sProvider.presentReceiptIndex]
                              .receiptItems
                              .length +
                          1,
                      (index) {
                        if (index ==
                            mProvider
                                .selectedSettlement
                                .receipts[sProvider.presentReceiptIndex]
                                .receiptItems
                                .length) {
                          return const SizedBox(
                            height: 100,
                          );
                        }
                        return SingleMenu(
                          index: index,
                          receiptIndex: sProvider.presentReceiptIndex,
                        );
                      },
                    ))),
                  )
      ],
    );
  }
}

class SingleMenu extends ConsumerStatefulWidget {
  final int receiptIndex;
  final int index;
  const SingleMenu(
      {super.key, required this.index, required this.receiptIndex});

  @override
  ConsumerState<SingleMenu> createState() => _SingleMenuState();
}

class _SingleMenuState extends ConsumerState<SingleMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sProvider = ref.watch(settlementMatchingProvider);
    final mProvider = ref.watch(mainProvider);
    final rcpItem = mProvider.selectedSettlement.receipts[widget.receiptIndex]
        .receiptItems[widget.index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (mProvider.selectedMemberIndexList.contains(true)) {
              mProvider.selectReceiptItem(widget.receiptIndex, widget.index);
              mProvider.batchMatching(widget.receiptIndex);
              sProvider.showMatchingDetail(widget.receiptIndex, widget.index);
              return;
            }
            sProvider.toggleMatchingDetail(widget.receiptIndex, widget.index);
          },
          child: Container(
            height: 55,
            width: size.width - 40,
            child: Row(
              children: [
                Container(
                  width: (size.width - 80) * 0.6,
                  margin: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: (size.width - 80) * 0.6 - 50,
                        ),
                        child: Text(
                          rcpItem.receiptItemName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        "    ${mProvider.selectedSettlement.receipts[widget.receiptIndex].receiptItems[widget.index].paperOwner.length} 명",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: basic[4],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: (size.width - 80) * 0.4,
                  margin: const EdgeInsets.only(right: 20),
                  child: Text(
                    "${priceToString.format(rcpItem.price)} 원",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          width: size.width,
          height: sProvider.showMatchingDetailItemIndex == widget.index &&
                  sProvider.showMatchingDetailReceiptIndex ==
                      widget.receiptIndex
              ? 170
              : 0,
          color: basic[1],
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.decelerate,
                  width: size.width,
                  height: sProvider.showMatchingDetailItemIndex == widget.index
                      ? 140
                      : 0,
                  child: SingleChildScrollView(
                    child: ClipRect(
                      child: Wrap(
                        children: List.generate(
                            mProvider
                                .selectedSettlement
                                .receipts[widget.receiptIndex]
                                .receiptItems[widget.index]
                                .paperOwner
                                .length,
                            (idx) => SingleSettlementItemMember(
                                  stmPaperId: mProvider
                                      .selectedSettlement
                                      .receipts[widget.receiptIndex]
                                      .receiptItems[widget.index]
                                      .paperOwner
                                      .keys
                                      .toList()[idx],
                                  receiptItemIndex: widget.index,
                                  receiptIndex: widget.receiptIndex,
                                )),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    sProvider.toggleMatchingDetail(
                        widget.receiptIndex, widget.index);
                  },
                  child: Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 1,
                          width: size.width * 0.2,
                          color: basic[2],
                        ),
                        Text("  접기 ∧  "),
                        Container(
                          width: size.width * 0.2,
                          height: 1,
                          color: basic[2],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          width: size.width - 40,
          color: basic[2],
        ),
      ],
    );
  }
}

class SingleSettlementItemMember extends ConsumerStatefulWidget {
  final String stmPaperId;
  final int receiptIndex;
  final int receiptItemIndex;
  const SingleSettlementItemMember(
      {Key? key,
      required this.stmPaperId,
      required this.receiptItemIndex,
      required this.receiptIndex})
      : super(key: key);

  @override
  ConsumerState<SingleSettlementItemMember> createState() =>
      _SingleSettlementItemMemberState();
}

class _SingleSettlementItemMemberState
    extends ConsumerState<SingleSettlementItemMember> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final sProvider = ref.watch(settlementMatchingProvider);
    final mProvider = ref.watch(mainProvider);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutExpo,
      opacity: opacity,
      child: Stack(
        children: [
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6.5),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: basic[0],
              border: Border.all(
                color: basic[2],
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
              mProvider.selectedSettlement.settlementPapers
                  .firstWhere((element) =>
                      element.settlementPaperId == widget.stmPaperId)
                  .memberName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: InkWell(
              onTap: () {
                mProvider.unmatching(sProvider.showMatchingDetailReceiptIndex,
                    widget.receiptItemIndex, widget.stmPaperId);
              },
              child: Container(
                width: 28,
                height: 28,
                color: Colors.transparent,
                child: Align(
                    alignment: const Alignment(0.5, -0.2),
                    child: Image.asset(
                      'assets/Delete.png',
                      width: 15,
                      height: 15,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
