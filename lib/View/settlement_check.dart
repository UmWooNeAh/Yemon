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
    return Column(
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
                        width: 2,
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
                                print(index);
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
                                  color:
                                      this.index == index ? basic[8] : basic[2],
                                  width: 2,
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
                              mProvider
                                  .selectedSettlement.settlementPapers.length,
                              (index) => oneStmPaper(index: index)),
                        )
                      ],
                    ),
                  ),
                )
                : Expanded(
                  child: RepaintBoundary(
                    key: _globalKey2,
                    child: OverallStmPaper(),
                  ),
                )
            : Expanded(
              child: RepaintBoundary(
                key: _globalKey3,
                child: oneStmPaper(index: index),
              ),
            ),
        Column(
          children: [
            showOverall
                ? Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: basic[1],
                      boxShadow: [
                        BoxShadow(
                          color: basic[3],
                          inset: true,
                          blurRadius: 5,
                          spreadRadius: -8,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: basic[3],
                          inset: true,
                          blurRadius: 5,
                          spreadRadius: -8,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        "모든 사람들의 정산서도 모아서 보기",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: showAll,
                      onChanged: (value) {
                        setState(() {
                          showAll = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ))
                : SizedBox.shrink(),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: basic[1],
                boxShadow: showOverall
                    ? []
                    : [
                        BoxShadow(
                          color: basic[3],
                          inset: true,
                          blurRadius: 5,
                          spreadRadius: -8,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: basic[3],
                          inset: true,
                          blurRadius: 5,
                          spreadRadius: -8,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7E600),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "카카오톡으로 공유",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      captureWidget().then((value) {
                        ImageGallerySaver.saveImage(value, quality: 100);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: basic[2],
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "사진으로 저장",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<Uint8List> captureWidget() async {
    RenderRepaintBoundary boundary = RenderRepaintBoundary();

    if (showOverall) {
      if (showAll) {
        boundary = _globalKey1.currentContext!.findRenderObject() as RenderRepaintBoundary;
      } else {
        boundary = _globalKey2.currentContext!.findRenderObject() as RenderRepaintBoundary;
      }
    } else {
      boundary = _globalKey3.currentContext!.findRenderObject() as RenderRepaintBoundary;
    }
    final ui.Image image = await boundary.toImage();
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
    return mProvider.selectedSettlement.totalPrice == 0
        ? Center(
            child: Text(
                        "정산할 내역이 없습니다.",
                        style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
                        ),
                      ))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Text("전체 정산서",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("이름",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                      Column(
                        children: List.generate(
                            mProvider
                                .selectedSettlement.settlementPapers.length,
                            (index) => Text(mProvider.selectedSettlement
                                .settlementPapers[index].memberName)),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text("메뉴",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                      Column(
                        children: List.generate(
                            mProvider
                                .selectedSettlement.settlementPapers.length,
                            (index) => Text(mProvider
                                    .selectedSettlement
                                    .settlementPapers[index]
                                    .settlementItems
                                    .isEmpty
                                ? "메뉴 없음"
                                : "${mProvider.selectedSettlement.settlementPapers[index].settlementItems.first.name} 등 ${mProvider.selectedSettlement.settlementPapers[index].settlementItems.length}개")),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text("금액",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          )),
                      Column(
                          children: List.generate(
                        mProvider.selectedSettlement.settlementPapers.length,
                        (index) => Text(
                            "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].totalPrice.toInt())} 원"),
                      ))
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 20, bottom: 20),
                    child: Text(
                        "총 금액 ${priceToString.format(mProvider.selectedSettlement.totalPrice.toInt())}원",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        )),
                  ),
                ],
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(thickness: 1)),
            ],
          );
  }
}

class oneStmPaper extends ConsumerWidget {
  final int index;
  const oneStmPaper({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mProvider = ref.watch(mainProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
          height: 40,
          child: Text(
              mProvider.selectedSettlement.settlementPapers[index].memberName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("메뉴 이름",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: basic[3],
                    )),
                //SizedBox(height:MediaQuery.of(context).size.height*0.001),
                Column(
                  children: List.generate(
                      mProvider.selectedSettlement.settlementPapers[index]
                          .settlementItems.length,
                      (stmItemIndex) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            child: RichText(
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
                                      "(${mProvider.getReceiptInformationBySettlementPaper(mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].hashCode)[0]})",
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("메뉴 금액",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: basic[3],
                    )),
                Column(
                  children: List.generate(
                      mProvider.selectedSettlement.settlementPapers[index]
                          .settlementItems.length,
                      (stmItemIndex) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              priceToString.format(mProvider
                                  .getReceiptInformationBySettlementPaper(
                                      mProvider
                                          .selectedSettlement
                                          .settlementPapers[index]
                                          .settlementItems[stmItemIndex]
                                          .hashCode)[1]),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          )),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("계산할 금액",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: basic[3],
                    )),
                Column(
                  children: List.generate(
                      mProvider.selectedSettlement.settlementPapers[index]
                          .settlementItems.length,
                      (stmItemIndex) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].settlementItems[stmItemIndex].splitPrice.toInt())} 원",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          )),
                )
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20, bottom: 20),
              child: Text(
                  "정산 금액 ${priceToString.format(mProvider.selectedSettlement.settlementPapers[index].totalPrice.toInt())} 원",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: basic[8],
                  )),
            ),
          ],
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(thickness: 1)),
      ],
    );
  }
}
