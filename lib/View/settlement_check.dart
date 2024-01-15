import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sqlite_test/theme.dart';
import '../theme.dart';

int size = 4;

class SettlementCheck extends ConsumerStatefulWidget {
  const SettlementCheck({super.key});

  @override
  ConsumerState<SettlementCheck> createState() => _SettlementCheckState();
}

class _SettlementCheckState extends ConsumerState<SettlementCheck> {
  bool showOverall = true;
  bool showAll = false;
  int index = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: basic[1],
            boxShadow: [
              BoxShadow(
                color: basic[2],
                inset: true,
                blurRadius: 8,
                spreadRadius: -8,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: basic[2],
                inset: true,
                blurRadius: 8,
                spreadRadius: -8,
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
                    color: showOverall ? basic[3] : basic[2],
                    height: 40,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    margin: const EdgeInsets.only(left: 20),
                    child: Center(
                      child: Text(
                        "전체",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                      4,
                      (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                showOverall = false;
                                this.index = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              color: this.index == index ? basic[3] : basic[2],
                              height: 40,
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              margin: const EdgeInsets.only(left: 20),
                              child: Center(
                                child: Text(
                                  index == 0 ? "나" : "멤버 $index",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
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
        showOverall ?
        showAll ? Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                OverallStmPaper(),
                Column(
                  children: List.generate(
                      size,
                          (index) => oneStmPaper(index: index)
                  ),
                )
              ],
            ),
          )
        ): Expanded(child: OverallStmPaper()) :
        Expanded(child: oneStmPaper(index: index)),
        Column(
          children: [
            showOverall ? Container(
              height:50,
              color: basic[1],
              child: CheckboxListTile(
                title: Text("모든 사람들의 정산서도 모아서 보기",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: showAll,
                onChanged: (value){
                  setState(() {
                    showAll = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              )
            ) : SizedBox.shrink(),
            Container(
              color: basic[1],
              height:80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap:(){},
                    child: Container(
                      color: basic[2],
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Text("카카오톡으로 공유",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap:(){},
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: basic[2],
                      child: Center(
                        child: Text("사진으로 저장",
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
}

class OverallStmPaper extends StatefulWidget {
  const OverallStmPaper({Key? key}) : super(key: key);

  @override
  State<OverallStmPaper> createState() => _OverallStmPaperState();
}

class _OverallStmPaperState extends State<OverallStmPaper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Text("전체 정산서",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("이름",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
            const Text("메뉴",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
            const Text("금액",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
                children: List.generate(
                    size,
                    (index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "이름 $index",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ))),
            Column(
                children: List.generate(
                    size,
                    (index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "메뉴 $index 등 ${index % 2}개",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        )
                )
            ),
            Column(
                children: List.generate(
                    size,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "${index * 1000} 원",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    )
                )
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20,bottom: 20),
              child: Text("총 금액 10,000원",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  )
              ),
            ),
          ],
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(thickness: 1)
        ),
      ],
    );
  }
}

class oneStmPaper extends StatefulWidget {
  final int index;
  const oneStmPaper({Key? key,required this.index}) : super(key: key);

  @override
  State<oneStmPaper> createState() => _oneStmPaperState();
}

class _oneStmPaperState extends State<oneStmPaper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Text("이름 ${widget.index}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("제품 명",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
            const Text("금액",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
                children: List.generate(
                    size,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "메뉴 $index",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    )
                )
            ),
            Column(
                children: List.generate(
                    size,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "${index * 1000} 원",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    )
                )
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20,bottom: 20),
              child: Text("정산할 금액 10,000원",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  )
              ),
            ),
          ],
        ),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(thickness: 1)
        ),
      ],
    );
  }
}
