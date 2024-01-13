import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettlementMatching extends ConsumerStatefulWidget {
  const SettlementMatching({super.key});

  @override
  ConsumerState<SettlementMatching> createState() => _SettlementMatchingState();
}

class _SettlementMatchingState extends ConsumerState<SettlementMatching> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settlement Matching"));
  }
}
