import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadMemberPage extends ConsumerStatefulWidget {
  const LoadMemberPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoadMemberPage> createState() => _LoadMemberPageState();
}

class _LoadMemberPageState extends ConsumerState<LoadMemberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text("Load Member Page")),
    );
  }
}
