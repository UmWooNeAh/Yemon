import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/View/settlement_check.dart';
import 'package:sqlite_test/View/settlement_information.dart';
import 'package:sqlite_test/View/settlement_matching.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';

class SettlementManagementPage extends ConsumerStatefulWidget {
  const SettlementManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettlementManagementPage> createState() =>
      _SettlementManagementPageState();
}

class _SettlementManagementPageState
    extends ConsumerState<SettlementManagementPage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettlementName(),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          SettlementInformation(),
          SettlementMatching(),
          SettlementCheck(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            if (selectedIndex == 2) {
              ref.watch(mainProvider).updateMemberTotalPrice();
            }
          });
        },
        backgroundColor: basic[0],
        selectedFontSize: 16,
        selectedItemColor: basic[9],
        unselectedItemColor: basic[5],
        unselectedFontSize: 14,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/Enter.png',
                height: 20,
                width: 20,
                color: selectedIndex == 0 ? basic[9] : basic[5],
              ),
              label: "정산 정보 입력"),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/Matching.png',
                height: 20,
                width: 20,
                color: selectedIndex == 1 ? basic[9] : basic[5],
              ),
              label: "정산 매칭"),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/Check.png',
                height: 20,
                width: 20,
                color: selectedIndex == 2 ? basic[9] : basic[5],
              ),
              label: "정산 결과"),
        ],
      ),
    );
  }
}

class SettlementName extends ConsumerWidget {
  const SettlementName({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final provider = ref.watch(mainProvider);
    return Container(
      width: size.width,
      height: 60,
      // color: basic[1],
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            height: 40,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.width - 140),
                child: Text(
                  provider.selectedSettlement.settlementName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const EditSettlementName();
                  });
            },
            child: Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 5),
              child: FittedBox(
                  fit: BoxFit.fill, child: Image.asset('assets/Edit.png')),
            ),
          ),
        ],
      ),
    );
  }
}

class EditSettlementName extends ConsumerStatefulWidget {
  const EditSettlementName({super.key});

  @override
  ConsumerState<EditSettlementName> createState() => _EditSettlementNameState();
}

class _EditSettlementNameState extends ConsumerState<EditSettlementName> {
  TextEditingController controller = TextEditingController();
  bool isError = false;

  @override
  void initState() {
    super.initState();
    controller.text = ref.read(mainProvider).selectedSettlement.settlementName;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      elevation: 0,
      title: Text(
        "정산의 이름을 수정합니다",
        style: TextStyle(
          fontSize: 18,
          color: basic[4],
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: basic[0],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isError ? 60 : 30,
            // color: Colors.red,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                errorText: isError ? "공백은 이름이 될 수 없습니다." : null,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: basic[5]),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: basic[5]),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: basic[5]),
                ),
              ),
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Container(
          height: 50,
          width: size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: basic[2], width: 1.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: basic[0],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
            },
            child: Text("취소",
                style: TextStyle(
                    color: basic[5],
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        Container(
          height: 50,
          width: size.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: basic[9],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            onPressed: () {
              if (controller.text == "") {
                setState(() {
                  isError = true;
                });
                return;
              }
              final provider = ref.watch(mainProvider);
              provider.editSelectedSettlementName(controller.text);
              context.pop();
            },
            child: Text("이름 변경",
                style: TextStyle(
                    color: basic[0],
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
