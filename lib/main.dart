import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/sqlflite_DB.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'View/load_member_page.dart';
import 'View/settlement_list_page.dart';
import 'View/settlement_management_page.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  Widget build(BuildContext context) {
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
  initialLocation: '/SplashView',
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
        GoRoute(
          path: 'SplashView',
          builder: (context, state) => const SplashView(),
        ),
      ],
    ),
  ],
);

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    SqlFliteDB().database.then((Database db) {
      //앱 시작할 때 모든 테이블 데이터 날리고 시작 가능한 코드
      //db.rawDelete(sql1); db.rawDelete(sql2); db.rawDelete(sql3); db.rawDelete(sql4); db.rawDelete(sql5);
      ref.read(mainProvider).setDB(db).then((value){
        Future.delayed(const Duration(milliseconds: 1000), (){
          context.go('/');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset('assets/Yemon.svg'),
      ),
    );
  }
}
