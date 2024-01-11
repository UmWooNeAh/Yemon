import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          Text("엄"),
          Text("준"),
          Text("식")
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index){
          setState(() {
            selectedIndex = index;

          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add),label: "정산 정보 입력"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_sharp),label: "정산 매칭"),
          BottomNavigationBarItem(icon: Icon(Icons.adb_outlined),label: "정산 결과"),
        ],
      ),
    );
  }
}
