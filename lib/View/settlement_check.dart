import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/View/settlement_matching.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sqlite_test/theme.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart' hide BoxShadow, BoxDecoration;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../shared_tool.dart';
import '../theme.dart';

class SettlementCheck extends ConsumerStatefulWidget {
  const SettlementCheck({super.key});

  @override
  ConsumerState<SettlementCheck> createState() => _SettlementCheckState();
}

class _SettlementCheckState extends ConsumerState<SettlementCheck> {
  final GlobalKey _globalKey1 = GlobalKey();
  final GlobalKey _globalKey2 = GlobalKey();
  final GlobalKey _globalKey3 = GlobalKey();
  bool showOverall = true;
  bool showAll = false;
  int index = -1;
  @override
  Widget build(BuildContext context) {
    final mProvider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: basic[0],
      child: Column(
        children: [
          Container(
            height: 80,
            width: size.width,
            decoration: BoxDecoration(
              color: basic[1],
              boxShadow: [
                BoxShadow(
                  color: basic[3],
                  inset: true,
                  blurRadius: 8,
                  spreadRadius: -5,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: basic[3],
                  inset: true,
                  blurRadius: 8,
                  spreadRadius: -5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showOverall = true;
                        index = -1;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 40,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: showOverall ? basic[8] : basic[0],
                        border: Border.all(
                          color: showOverall ? basic[8] : basic[2],
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 1,
                            offset: const Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "전체 정산서",
                          style: TextStyle(
                            color: showOverall ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                        mProvider.selectedSettlement.settlementPapers.length,
                        (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  showOverall = false;
                                  this.index = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                height: 40,
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color:
                                      this.index == index ? basic[8] : basic[0],
                                  border: Border.all(
                                    color: this.index == index
                                        ? basic[8]
                                        : basic[2],
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 1,
                                      offset: const Offset(1.5, 1.5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    index == 0
                                        ? "나"
                                        : mProvider.selectedSettlement
                                            .settlementPapers[index].memberName,
                                    style: TextStyle(
                                      color: this.index == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                  )
                ],
              ),
            ),
          ),
          showOverall
              ? showAll
                  ? Expanded(
                      child: RepaintBoundary(
                        key: _globalKey1,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            const OverallStmPaper(),
                            Column(
                              children: List.generate(
                                  mProvider.selectedSettlement.settlementPapers
                                      .length,
                                  (index) => OneStmPaper(index: index)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: RepaintBoundary(
                        key: _globalKey2,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            const OverallStmPaper(),
                            Column(
                              children: List.generate(
                                  mProvider.selectedSettlement.settlementPapers
                                      .length,
                                  (index) => OneStmPaper(index: index)),
                            ),
                          ],
                        ),
                      ),
                    )
              : Expanded(
                  child: RepaintBoundary(
                    key: _globalKey3,
                    child: OneStmPaper(index: index),
                  ),
                ),
          // showOverall
          //     ? Container(
          //         height: 40,
          //         decoration: BoxDecoration(
          //           color: basic[1],
          //           boxShadow: [
          //             BoxShadow(
          //               color: basic[3],
          //               inset: true,
          //               blurRadius: 5,
          //               spreadRadius: -8,
          //               offset: const Offset(0, 5),
          //             ),
          //             BoxShadow(
          //               color: basic[3],
          //               inset: true,
          //               blurRadius: 5,
          //               spreadRadius: -8,
          //               offset: const Offset(0, 5),
          //             ),
          //           ],
          //         ),
          //         child: CheckboxListTile(
          //           activeColor: basic[8],
          //           checkColor: basic[0],
          //           checkboxShape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           side: BorderSide(color: basic[3], width: 1.5),
          //           title: const Text(
          //             "모든 사람들의 정산서도 모아서 보기",
          //             style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //           value: showAll,
          //           onChanged: (value) {
          //             setState(() {
          //               showAll = value!;
          //             });
          //           },
          //           controlAffinity: ListTileControlAffinity.leading,
          //         ))
          //     : const SizedBox.shrink(),
          // Container(
          //   height: 80,
          //   decoration: BoxDecoration(
          //     color: basic[1],
          //     boxShadow: showOverall
          //         ? []
          //         : [
          //             BoxShadow(
          //               color: basic[3],
          //               inset: true,
          //               blurRadius: 5,
          //               spreadRadius: -8,
          //               offset: const Offset(0, 5),
          //             ),
          //             BoxShadow(
          //               color: basic[3],
          //               inset: true,
          //               blurRadius: 5,
          //               spreadRadius: -8,
          //               offset: const Offset(0, 5),
          //             ),
          //           ],
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       InkWell(
          //         onTap: () {},
          //         child: Container(
          //           width: size.width * 0.5 - 15,
          //           margin:
          //               const EdgeInsets.only(top: 10, bottom: 10, left: 10),
          //           padding: const EdgeInsets.symmetric(horizontal: 30),
          //           decoration: BoxDecoration(
          //             color: Color(0xFFF7E600),
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: Center(
          //             child: Text(
          //               "카카오톡으로 공유",
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       InkWell(
          //         onTap: () {
          //           captureWidget().then((value) {
          //             ImageGallerySaver.saveImage(value, quality: 100);
          //           });
          //         },
          //         child: Container(
          //           width: size.width * 0.5 - 15,
          //           margin:
          //               const EdgeInsets.only(top: 10, bottom: 10, right: 10),
          //           padding: const EdgeInsets.symmetric(horizontal: 30),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             border: Border.all(
          //               color: basic[2],
          //               width: 1.5,
          //             ),
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: Center(
          //             child: Text(
          //               "사진으로 저장",
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Future<Uint8List> captureWidget() async {
    RenderRepaintBoundary boundary = RenderRepaintBoundary();

    if (showOverall) {
      if (showAll) {
        boundary = _globalKey1.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
      } else {
        boundary = _globalKey2.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
      }
    } else {
      boundary = _globalKey3.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
    }
    final ui.Image image = await boundary.toImage(pixelRatio: 3);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }
}

class OverallStmPaper extends ConsumerWidget {
  const OverallStmPaper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mProvider = ref.watch(mainProvider);
    final Size size = MediaQuery.of(context).size;
    int sum = 0;
    for (var settlementPaper in mProvider.selectedSettlement.settlementPapers) {
      sum += settlementPaper.settlementItems.isEmpty ? 0 : 1;
    }
    return sum == 0
        ? const Center(
            child: Text(
            "정산할 항목이 없습니다.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ))
        : Container(
            color: basic[0],
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      left: 20, top: 20, bottom: 20, right: 20),
                  child: const Text("전체 정산서",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: (size.width - 60) * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("이름",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: basic[3],
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  mProvider.selectedSettlement.settlementPapers
                                      .length,
                                  (index) => mProvider
                                          .selectedSettlement
                                          .settlementPapers[index]
                                          .settlementItems
                                          .isEmpty
                                      ? const SizedBox.shrink()
                                      : Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Text(
                                            mProvider
                                                .selectedSettlement
                                                .settlementPapers[index]
                                                .memberName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 60) * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("메뉴",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: basic[3],
                                )),
                            Column(
                              children: List.generate(
                                  mProvider.selectedSettlement.settlementPapers
                                      .length,
                                  (index) => mProvider
                                          .selectedSettlement
                                          .settlementPapers[index]
                                          .settlementItems
                                          .isEmpty
                                      ? const SizedBox.shrink()
                                      : Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Row(children: [
                                            SizedBox(
                                              width: (size.width - 60) * 0.18,
                                              child: Text(
                                                mProvider
                                                        .selectedSettlement
                                                        .settlementPapers[index]
                                                        .settlementItems
                                                        .isEmpty
                                                    ? "메뉴 없음"
                                                    : mProvider
                                                        .selectedSettlement
                                                        .settlementPapers[index]
                                                        .settlementItems
                                                        .first
                                                        .name,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: (size.width - 60) * 0.12,
                                              child: Text(
                                                mProvider
                                                        .selectedSettlement
                                                        .settlementPapers[index]
                                                        .settlementItems
                                                        .isEmpty
                                                    ? ""
                                                    : "등 ${mProvider.selectedSettlement.settlementPapers[index].settlementItems.length}개",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.end,
                                                overflow: TextOverflow.fade,
                                                softWrap: false,
                                              ),
                                            )
                                          ]),
                                        )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 60) * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("정산 금액",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: basic[3],
                                )),
                            Column(
                                children: List.generate(
                              mProvider
                                  .selectedSettlement.settlementPapers.length,
                              (index) => mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .isEmpty
                                  ? const SizedBox.shrink()
                                  : Container(
                                      width: (size.width - 60) * 0.3,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: Text(
                                        "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].totalPrice)} 원",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width - 45,
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    "총 금액 ${priceToString.format(mProvider.selectedSettlement.totalPrice.toInt())}원",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                      color: basic[8],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: basic[2],
                ),
              ],
            ),
          );
  }
}

class OneStmPaper extends ConsumerWidget {
  final int index;
  const OneStmPaper({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mProvider = ref.watch(mainProvider);
    final Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: basic[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(
                  left: 20, top: 20, bottom: 20, right: 20),
              child: Text(
                  mProvider
                      .selectedSettlement.settlementPapers[index].memberName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  )),
            ),
          ),
          mProvider.selectedSettlement.settlementPapers[index].settlementItems
                  .isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: (size.width - 60) * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("메뉴 이름",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: basic[3],
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .length,
                                  (stmItemIndex) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: RichText(
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          maxLines: 1,
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: mProvider
                                                  .selectedSettlement
                                                  .settlementPapers[index]
                                                  .settlementItems[stmItemIndex]
                                                  .name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text:
                                                  "  (${mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].receiptName})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: basic[3],
                                              ),
                                            ),
                                          ]),
                                        ),
                                      )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 60) * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("메뉴 금액",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: basic[3],
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .length,
                                  (stmItemIndex) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Text(
                                          "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].receiptItemPrice)}원",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: basic[3]),
                                        ),
                                      )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 60) * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("계산할 금액",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: basic[3],
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .length,
                                  (stmItemIndex) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Text(
                                          "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].splitPrice)} 원",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      )),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: const Text(
                    "해당 멤버에게 매칭된 메뉴가 없습니다.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
          mProvider.selectedSettlement.settlementPapers[index].settlementItems
                  .isNotEmpty
              ? Container(
                  width: size.width - 45,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "정산 금액 ${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].totalPrice)} 원",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        color: basic[8],
                      )),
                )
              : const SizedBox.shrink(),
          Divider(
            thickness: 1,
            color: basic[2],
          ),
        ],
      ),
    );
  }
}
