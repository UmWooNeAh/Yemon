import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:sqlite_test/View/settlement_matching.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';

class ReceiptCirculator extends ConsumerWidget {
  const ReceiptCirculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mprovider = ref.watch(mainProvider);
    final sprovider = ref.watch(settlementMatchingProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 130,
      width: size.width,
      margin: const EdgeInsets.only(top: 50),
      child: ScrollSnapList(

        itemCount: mprovider.selectedSettlement.receipts.length,
        itemSize: 100,
        onItemFocus: (index) {
          sprovider.selectReceipt(index, mprovider.selectedSettlement.receipts[index].receiptItems.length);
        },
        itemBuilder: (context, index) {
          return ListedReceiptShape(
            index: index,
          );
        },
        dynamicItemSize: true,
        dynamicItemOpacity: 0.5,
      ),
    );
  }
}

class ListedReceiptShape extends ConsumerWidget {
  const ListedReceiptShape({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sprovider = ref.watch(settlementMatchingProvider);
    final mprovider = ref.watch(mainProvider);
    return Stack(
      children: [
        Container(
          width: 100,
          height: 130,
          child: FittedBox(
              fit: BoxFit.fill, child: Image.asset('assets/ListedReceipt.png')),
        ),
        Container(
          width: 100,
          height: 130,
          child: Align(
            alignment: Alignment(0, 0.7),
            child: Text(
              index.toString(),
              // mprovider.selectedSettlement.receipts[index].receiptName,
            ),
          ),
        ),
      ],
    );
  }
}
