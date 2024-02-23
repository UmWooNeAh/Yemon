import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_test/DB/sqlflite_DB.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:sqlite_test/theme.dart';
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(0.8)),
          child: child!,
        );
      },
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
      ref.read(mainProvider).setDB(db).then((value) {
        final eprovider = ref.read(editManagementProvider);
        final provider = ref.read(mainProvider);
        if (provider.db != null) {
          provider.fetchAllSettlements().then((value) {
            eprovider.setEditSettlement(provider.settlementList.length);
          });
        }
        Future.delayed(const Duration(milliseconds: 1000)).then(
          (value) {
            context.go('/');
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: basic[0],
        child: Center(
          child: SvgPicture.asset(
            'assets/Yemon.svg',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
