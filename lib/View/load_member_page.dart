import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:sqlite_test/shared_tool.dart';
import 'package:sqlite_test/theme.dart';

final loadMemberProvider =
    ChangeNotifierProvider((ref) => LoadMemberViewModel());

class LoadMemberViewModel extends ChangeNotifier {
  bool loadMode = false;
  int selectedIndex = -1;
  List<bool> isDetailSelected = [];

  void set(int settlementLength) {
    // isDetailSelected = List.generate(settlementLength, (index) => false);
    isDetailSelected = List.generate(10, (index) => false);
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
    final mprovider = ref.watch(mainProvider);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: const Text(
                  "기존 정산에서 정산 인원을 불러옵니다",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                )),
            const Expanded(
              child: SettlementList(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInSine,
              width: size.width,
              height: lprovider.loadMode ? 80 : 0,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: basic[1],
                boxShadow: [
                  BoxShadow(
                    color: basic[6],
                    blurRadius: 5,
                    spreadRadius: -4,
                    offset: const Offset(0, 7),
                    inset: true,
                  ),
                ],
              ),
              // decoration: BoxDecoration(
              //   color: basic[1],
              // ),
              child: ElevatedButton(
                onPressed: () {
                  mprovider.loadMemberList(lprovider.selectedIndex);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: basic[8],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "정산 참여 인원 불러오기",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: basic[0],
                  ),
                ),
              ),
            ),
          ],
        ),
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
        if (mprovider.settlementList[index].settlementId ==
            mprovider.selectedSettlement.settlementId) {
          return const SizedBox.shrink();
        }
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
    return Column(
      children: [
        InkWell(
          onTap: () {
            lprovider.settlementSelected(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: lprovider.selectedIndex == index ? basic[1] : basic[0],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width - 80,
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            mprovider.settlementList[index].settlementName,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: basic[4]),
                          ),
                          Text(
                            "   ${mprovider.settlementList[index].settlementPapers.length}명",
                            style: TextStyle(
                                color: basic[5],
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                              mprovider.settlementList[index].date
                                  .toString()
                                  .substring(0, 10),
                              style: TextStyle(
                                  color: basic[5],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300)),
                          Text(
                            "  ${intToWeekDay(mprovider.settlementList[index].date.weekday)}",
                            style: TextStyle(
                                color: basic[5],
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: size.width,
                      height: 50,
                    ),
                    lprovider.isDetailSelected[index]
                        ? SettlementDetailView(settlementIndex: index)
                        : SettlementSimpleView(settlementIndex: index),
                    Positioned(
                      right: 0,
                      top: 5,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: lprovider.selectedIndex == index
                              ? basic[0]
                              : basic[1],
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: basic[2], width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: basic[2],
                              blurRadius: 5,
                              spreadRadius: -4,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
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
                    ? basic[1]
                    : basic[0],
                spreadRadius: -15,
                blurRadius: 5,
                offset: const Offset(-40, 0),
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
    return Container(
      width: size.width - 50,
      child: Wrap(
        children: List.generate(
          memberLength,
          (index) => SettlementMember(
              settlementIndex: settlementIndex, memberIndex: index),
        ),
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
    final lprovider = ref.watch(loadMemberProvider);
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: lprovider.selectedIndex == settlementIndex ? basic[0] : basic[1],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: basic[2], width: 1.5),
        boxShadow: [
          BoxShadow(
            color: basic[5],
            spreadRadius: -4,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        mprovider.settlementList[settlementIndex].settlementPapers[memberIndex]
            .memberName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: memberIndex == 0 ? basic[3] : basic[5],
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
