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
import '../Kakao/kakao_common.dart';
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
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          color: basic[0],
          child: Column(
            children: [
              Container(
                  height: 55,
                  width: size.width,
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: basic[1],
                    boxShadow: [
                      BoxShadow(
                        color: basic[3],
                        inset: true,
                        blurRadius: 8,
                        spreadRadius: -10,
                        offset: const Offset(0, -5),
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
                            height: 30,
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: showOverall ? basic[9] : basic[0],
                              border: Border.all(
                                color: showOverall ? basic[9] : basic[2],
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
                                  color:
                                      showOverall ? Colors.white : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                              mProvider
                                  .selectedSettlement.settlementPapers.length,
                              (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showOverall = false;
                                        this.index = index;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      height: 30,
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: this.index == index
                                            ? basic[8]
                                            : basic[0],
                                        border: Border.all(
                                          color: this.index == index
                                              ? basic[8]
                                              : basic[2],
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 1,
                                            offset: const Offset(1.5, 1.5),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          index == 0
                                              ? "나"
                                              : mProvider
                                                  .selectedSettlement
                                                  .settlementPapers[index]
                                                  .memberName,
                                          style: TextStyle(
                                            color: this.index == index
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                        )
                      ],
                    ),
                  )),
              showOverall
                  ? showAll
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: RepaintBoundary(
                              key: _globalKey1,
                              child: Column(
                                children: [
                                  const OverallStmPaper(),
                                  Column(
                                    children: List.generate(
                                        mProvider.selectedSettlement
                                            .settlementPapers.length,
                                        (index) => OneStmPaper(index: index)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            child: RepaintBoundary(
                              key: _globalKey2,
                              child: const OverallStmPaper(),
                            ),
                          ),
                        )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: RepaintBoundary(
                          key: _globalKey3,
                          child: OneStmPaper(index: index),
                        ),
                      ),
                    ),
              showOverall
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: basic[1],
                        boxShadow: [
                          BoxShadow(
                            color: basic[6],
                            inset: true,
                            blurRadius: 5,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: basic[6],
                            inset: true,
                            blurRadius: 5,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      // activeColor: basic[8],
                      // checkColor: basic[0],
                      // checkboxShape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      // ),

                      // side: BorderSide(color: basic[3], width: 1.5),
                      // contentPadding: const EdgeInsets.all(0),
                      // title: Container(
                      //   color: Colors.red,
                      //   child: const Text(
                      //     "모든 사람들의 정산서도 모아서 보기",
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                      // value: showAll,
                      // onChanged: (value) {
                      //   setState(() {
                      //     showAll = value!;
                      //   });
                      // },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                left: 15, top: 10, bottom: 5),
                            width: 30,
                            height: 35,
                            child: Checkbox(
                              value: showAll,
                              activeColor: basic[8],
                              checkColor: basic[0],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              side: BorderSide(color: basic[3], width: 1.5),
                              onChanged: (value) {
                                setState(() {
                                  showAll = value!;
                                });
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showAll = !showAll;
                              });
                            },
                            child: Container(
                              height: 35,
                              margin: const EdgeInsets.only(
                                  left: 5, top: 10, bottom: 5),
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "모든 사람들의 정산서도 모아서 보기",
                                  style: TextStyle(
                                    // backgroundColor: Colors.red,
                                    height: 1.4,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                  : Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: basic[1],
                        boxShadow: [
                          BoxShadow(
                            color: basic[6],
                            inset: true,
                            blurRadius: 5,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: basic[6],
                            inset: true,
                            blurRadius: 5,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: basic[1],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        captureWidget().then((value) {
                          shareMessage(
                              value,
                              showOverall
                                  ? "전체 정산서"
                                  : mProvider.selectedSettlement
                                      .settlementPapers[index].memberName,
                              mProvider.selectedSettlement.settlementName);
                        });
                      },
                      child: Container(
                        width: size.width * 0.5 - 22.5,
                        height: 55,
                        margin:
                            const EdgeInsets.only(top: 0, bottom: 10, left: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E600),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "카카오톡으로 공유",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3A1D1D)),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        sProvider.loading();
                        captureWidget().then((value) {
                          ImageGallerySaver.saveImage(value, quality: 100);
                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            sProvider.loading();
                          });
                        });
                      },
                      child: Container(
                        width: size.width * 0.5 - 22.5,
                        height: 55,
                        margin: const EdgeInsets.only(
                            top: 0, bottom: 10, right: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: basic[2],
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "사진으로 저장",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        sProvider.isLoading
            ? Container(
                width: size.width,
                height: size.height,
                color: basic[1].withOpacity(0.1),
                child: Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: basic[2],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
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
    return Container(
      color: basic[0],
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin:
                const EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 20),
            child: const Text("전체 정산서",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                )),
          ),
          sum == 0
              ? Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  width: size.width,
                  height: 30,
                  child: Center(
                    child: Text(
                      "매칭된 메뉴가 없습니다",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: basic[4],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: (size.width - 60) * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("이름",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: basic[3],
                                )),
                            const SizedBox(
                              height: 10,
                            ),
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
                                              vertical: 10),
                                          child: Text(
                                            mProvider
                                                .selectedSettlement
                                                .settlementPapers[index]
                                                .memberName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: (size.width - 60) * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (size.width - 60) * 0.4,
                              child: Text("메뉴",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: basic[3],
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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
                                          width: (size.width - 60) * 0.4 - 20,
                                          margin: const EdgeInsets.only(
                                              left: 20, top: 10, bottom: 10),
                                          child: Row(children: [
                                            Expanded(
                                              // constraints: BoxConstraints(
                                              //     maxWidth:
                                              //         (size.width - 60) * 0.28),
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
                                                textAlign: TextAlign.right,
                                                softWrap: false,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                mProvider
                                                        .selectedSettlement
                                                        .settlementPapers[index]
                                                        .settlementItems
                                                        .isEmpty
                                                    ? ""
                                                    : " 등 ${mProvider.selectedSettlement.settlementPapers[index].settlementItems.length}개",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.center,
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
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: basic[3],
                                )),
                            const SizedBox(
                              height: 10,
                            ),
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
                                          vertical: 10),
                                      child: Text(
                                        "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].totalPrice)} 원",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
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
          sum == 0
              ? SizedBox.shrink()
              : Container(
                  width: size.width - 45,
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    "총 금액   ${priceToString.format(mProvider.selectedSettlement.totalPrice.toInt())}원",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: basic[9],
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
            alignment: Alignment.topLeft,
            child: Container(
              width: size.width,
              margin: const EdgeInsets.only(
                  left: 15, top: 10, bottom: 20, right: 20),
              child: Text(
                  mProvider
                      .selectedSettlement.settlementPapers[index].memberName,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
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
                      Container(
                        width: (size.width - 60) * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" 메뉴 이름",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: basic[3],
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .length,
                                  (stmItemIndex) => Container(
                                        height: 20,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            maxLines: 1,
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text: mProvider
                                                    .selectedSettlement
                                                    .settlementPapers[index]
                                                    .settlementItems[
                                                        stmItemIndex]
                                                    .name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color: basic[5]),
                                              ),
                                              TextSpan(
                                                text:
                                                    "  (${mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].receiptName})",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                  color: basic[3],
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (size.width - 60) * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("메뉴 금액",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: basic[3],
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .length,
                                  (stmItemIndex) => Container(
                                        height: 20,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                          "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].receiptItemPrice)}원",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
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
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: basic[3],
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                  mProvider
                                      .selectedSettlement
                                      .settlementPapers[index]
                                      .settlementItems
                                      .length,
                                  (stmItemIndex) => Container(
                                        height: 20,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(
                                          "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].splitPrice)} 원",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
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
                  child: Text(
                    "해당 멤버에게 매칭된 메뉴가 없습니다",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: basic[4],
                    ),
                  ),
                ),
          mProvider.selectedSettlement.settlementPapers[index].settlementItems
                  .isNotEmpty
              ? Container(
                  width: size.width - 45,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                      "정산 금액   ${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].totalPrice)} 원",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: basic[9],
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
