import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/View/settlement_check.dart';
import 'package:sqlite_test/View/settlement_information.dart';
import 'package:sqlite_test/View/settlement_matching.dart';

import '../ViewModel/mainviewmodel.dart';

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
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "정산 정보 입력"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_sharp), label: "정산 매칭"),
          BottomNavigationBarItem(
              icon: Icon(Icons.adb_outlined), label: "정산 결과"),
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
                    fontSize: 30,
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
              width: 40,
              height: 40,
              child: const Icon(Icons.edit),
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
  String newName = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Settlement Name"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("New Settlement Name : "),
          TextField(
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text("취소하기"),
        ),
        TextButton(
          onPressed: () {
            final provider = ref.watch(mainProvider);
            provider.editSettlementName(newName);
            context.pop();
          },
          child: const Text("변경하기"),
        ),
      ],
    );
  }
}