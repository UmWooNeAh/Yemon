import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/sqlflite_DB.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'View/load_member_page.dart';
import 'View/settlement_list_page.dart';
import 'View/settlement_management_page.dart';

String sql1 = "DELETE FROM Settlement";
String sql2 = "DELETE FROM Receipt";
String sql3 = "DELETE FROM SettlementPaper";
String sql4 = "DELETE FROM SettlementItem";
String sql5 = "DELETE FROM ReceiptItem";

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      SqlFliteDB().database.then((Database db){
      //앱 시작할 때 모든 테이블 데이터 날리고 시작 가능한 코드
      //db.rawDelete(sql1); db.rawDelete(sql2); db.rawDelete(sql3); db.rawDelete(sql4); db.rawDelete(sql5);
      ref.watch(mainProvider).setDB(db);
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // fontFamily: 'NotoSansKR',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ).copyWith(
          secondary: Colors.blueAccent,
        ),
      ),
      routerConfig: router,
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SettlementListPage(),
      routes: [
        GoRoute(
          path: 'SettlementManagementPage',
          builder: (context, state) => const SettlementManagementPage(),
          routes: [
            GoRoute(
              path: 'LoadMemberPage',
              builder: (context, state) => const LoadMemberPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
