import 'dart:math';

import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:sqlite_test/theme.dart';

final loadMemberProvider =
    ChangeNotifierProvider((ref) => LoadMemberViewModel());

class LoadMemberViewModel extends ChangeNotifier {
  bool loadMode = false;
  int selectedIndex = -1;
  List<bool> isDetailSelected = [];

  void set(int settlementLength) {
    isDetailSelected = List.generate(settlementLength, (index) => false);
  }

  void settlementDetailSelected(int index) {
    isDetailSelected[index] = !isDetailSelected[index];
    notifyListeners();
  }

  void settlementSelected(int index) {
    if (index == selectedIndex) {
      selectedIndex = -1;
      loadMode = false;
      notifyListeners();
    } else {
      loadMode = true;
      selectedIndex = index;
    }
    notifyListeners();
  }
}

class LoadMemberPage extends ConsumerStatefulWidget {
  const LoadMemberPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoadMemberPage> createState() => _LoadMemberPageState();
}

class _LoadMemberPageState extends ConsumerState<LoadMemberPage> {
  @override
  void initState() {
    super.initState();

    final lprovider = ref.read(loadMemberProvider);
    final mprovider = ref.read(mainProvider);
    lprovider.set(mprovider.settlementList.length);
  }

  @override
  Widget build(BuildContext context) {
    final lprovider = ref.watch(loadMemberProvider);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
              width: size.width,
              margin: const EdgeInsets.all(20),
              child: const Text(
                "정산에 참여하는 사람 불러오기",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
              )),
          Container(
            width: size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("생성된 정산에서 정산에서 정산할 사람들을 불러옵니다",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: basic[2],
                )),
          ),
          const Expanded(
            child: SettlementList(),
          ),
          AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInSine,
              height: lprovider.loadMode ? 50 : 0,
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("불러오기"),
              )),
        ],
      ),
    );
  }
}

class SettlementList extends ConsumerWidget {
  const SettlementList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mprovider = ref.watch(mainProvider);
    return ListView.builder(
      itemCount: mprovider.settlementList.length,
      itemBuilder: (context, index) {
        return UnitSettlement(
          index: index,
        );
      },
    );
  }
}

class UnitSettlement extends ConsumerWidget {
  const UnitSettlement({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final mprovider = ref.watch(mainProvider);
    final lprovider = ref.watch(loadMemberProvider);
    return GestureDetector(
      onTap: () {
        lprovider.settlementSelected(index);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        color: lprovider.selectedIndex == index ? basic[3] : basic[1],
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Text(mprovider.settlementList[index].settlementName),
                    Text(
                        "(${mprovider.settlementList[index].settlementPapers.length})명")
                  ],
                ),
                Text(mprovider.settlementList[index].date.toString()),
              ],
            ),
            Stack(
              children: [
                lprovider.isDetailSelected[index]
                    ? SettlementDetailView(settlementIndex: index)
                    : SettlementSimpleView(settlementIndex: index),
                Positioned(
                  right: 0,
                  top: 5,
                  child: Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () {
                        lprovider.settlementDetailSelected(index);
                      },
                      icon: lprovider.isDetailSelected[index]
                          ? const Icon(Icons.arrow_drop_up)
                          : const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettlementSimpleView extends ConsumerWidget {
  const SettlementSimpleView({super.key, required this.settlementIndex});
  final int settlementIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lprovider = ref.watch(loadMemberProvider);
    final mprovider = ref.watch(mainProvider);
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          height: 50,
          width: size.width - 90,
          margin: const EdgeInsets.only(right: 40),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(
              mprovider.settlementList[settlementIndex].settlementPapers.length,
              (index) => SettlementMember(
                  settlementIndex: settlementIndex, memberIndex: index),
            )),
          ),
        ),
        IgnorePointer(
          child: Container(
            height: 50,
            width: size.width - 90,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: lprovider.selectedIndex == settlementIndex
                    ? basic[3]
                    : basic[1],
                spreadRadius: -15,
                blurRadius: 5,
                offset: const Offset(-30, 0),
                inset: true,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class SettlementDetailView extends ConsumerWidget {
  const SettlementDetailView({super.key, required this.settlementIndex});
  final int settlementIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mprovider = ref.watch(mainProvider);
    Size size = MediaQuery.of(context).size;
    int memberLength =
        mprovider.settlementList[settlementIndex].settlementPapers.length;
    int firstRowNum = (size.width - 90) ~/ 90;
    int otherRowNum = (size.width - 50) ~/ 90;
    return Container(
      width: size.width - 50,
      child: Column(
        children: List.generate(
            (memberLength > firstRowNum ? 1 : 0) +
                max(0, memberLength - firstRowNum) ~/ otherRowNum +
                1, (index) {
          int rowNum = 0;
          if (index == 0) {
            rowNum = min(firstRowNum, memberLength);
          } else {
            rowNum = min(otherRowNum,
                memberLength - otherRowNum * (index - 1) - firstRowNum);
          }
          return Row(
            children: List.generate(
                rowNum,
                (iindex) => SettlementMember(
                    settlementIndex: settlementIndex,
                    memberIndex: iindex +
                        (index - 1) * otherRowNum +
                        firstRowNum +
                        1 +
                        (index == 0 ? 1 : 0))),
          );
        }),
      ),
    );
  }
}

class SettlementMember extends ConsumerWidget {
  const SettlementMember(
      {super.key, required this.settlementIndex, required this.memberIndex});
  final int settlementIndex;
  final int memberIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mprovider = ref.watch(mainProvider);
    return Container(
      width: 80,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.all(5),
      color: basic[2],
      child: Center(
          child: Text(
        mprovider.settlementList[settlementIndex].settlementPapers[memberIndex]
            .memberName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: basic[0], fontSize: 17, fontWeight: FontWeight.bold),
      )),
    );
  }
}
