import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/sqlflite_DB.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'View/load_member_page.dart';
import 'View/settlement_list_page.dart';
import 'View/settlement_management_page.dart';



void main() {
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '3261fb5134b2c138c08605111066bfe6',
    javaScriptAppKey: '119de50bf0c40a51fec11302a510fdad',
  );
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      SqlFliteDB().database.then((Database db){
      ref.watch(mainProvider).setDB(db);
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
