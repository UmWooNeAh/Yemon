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
    int length = mprovider.selectedSettlement.receipts.length;
    return Container(
      height: 130,
      width: size.width,
      margin: const EdgeInsets.only(top: 50),
      child: ScrollSnapList(
        itemCount:  length + (length < 2 ? 0 : 1),
        itemSize: 100,
        onItemFocus: (index) {
          if(length == 1){
            sprovider.selectReceipt(0);
            return;
          }
          sprovider.selectReceipt(index - 1);
        },
        itemBuilder: (context, index) {
          if(length == 1){
            return const ListedReceiptShape(index: 0);
          }
          return ListedReceiptShape(
            index: index - 1,
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
            alignment: const Alignment(0, 0.7),
            child: SizedBox(
              height: 15,
              width: 80,
              child: Center(
                child: Text(
                  index == -1
                      ? "영수증 모아보기"
                      : (index < mprovider.selectedSettlement.receipts.length
                          ? mprovider.selectedSettlement.receipts[index].receiptName
                          : ""),
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
