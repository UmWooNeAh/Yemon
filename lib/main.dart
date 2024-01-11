import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/DB/sqlFliteDB.dart';

import 'View/load_member_page.dart';
import 'View/settlement_list_page.dart';
import 'View/settlement_management_page.dart';



void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
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
        ),
        GoRoute(
          path: 'LoadMemberPage',
          builder: (context, state) => const LoadMemberPage(),
        ),
      ],
    ),
  ],
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SqlFliteDB _model = SqlFliteDB();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
                onPressed: () {
                  var db = _model.database;
                },
                child: Text('DB 생성'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: () async {
                      //await _model.insertStm("데모 정산");
                      await _model.insertRcp("영수증 2", "b9277cbb-e29f-4d32-bae7-0e196030590e");
                    },
                    child: Text('INSERT'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await _model.updateStm("데모 정산 1", "26262c21-596a-4210-8714-3cf094a0676a");
                  },
                  child: Text('UPDATE'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await _model.deleteStm("26262c21-596a-4210-8714-3cf094a0676a");
                  },
                  child: Text('DELETE'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await _model.joinTest("b9277cbb-e29f-4d32-bae7-0e196030590e");
                  },
                  child: Text('Query'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
