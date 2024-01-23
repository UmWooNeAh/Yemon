

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/View/settlement_matching.dart';

import '../Model/ReceiptItem.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';

class MenuSheet extends ConsumerWidget {
  const MenuSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final size =  MediaQuery.of(context).size;
    final mProvider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height*0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
            children: [
              SizedBox(height:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("메뉴 목록",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: size.width*0.15),
                  Container(
                    width: size.width*0.3,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {  },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: basic[1],
                      ),
                      child: Center(
                        child: Text("전체 매칭",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF848484),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: mProvider.selectedSettlement.receipts.isEmpty ? 50 : 10),
              mProvider.selectedSettlement.receipts.isEmpty ?
              Text("메뉴가 없습니다.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ) :
              SingleChildScrollView(
                child: Column(
                    children : List.generate(mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems.length, (index) => SingleMenu(index: index))
                ),
              )
            ]
        ),
      ),
    );
  }
}

class SingleMenu extends ConsumerStatefulWidget {
  final int index;
  const SingleMenu({super.key, required this.index});

  @override
  ConsumerState<SingleMenu> createState() => _SingleMenuState();
}

class _SingleMenuState extends ConsumerState<SingleMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sProvider = ref.watch(settlementMatchingProvider);
    final mProvider = ref.watch(mainProvider);
    final rcpItem = mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems[widget.index];
    return Column(
      children: [
        InkWell(
          onTap:(){
            if(sProvider.selectedMemberIndexList.contains(true)){
              //print(mProvider.selectedSettlement.settlementPapers.length);
              List<int> userIndexes = sProvider.matching();
              for(int index in userIndexes){
                mProvider.matching(index, widget.index, sProvider.presentReceiptIndex);
              }
            }
          },
          child: Container(
            height: 50,
            color: sProvider.selectedReceiptItemIndexList[widget.index] ? basic[1] : Colors.white,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left:40),
                  width:size.width*0.25,
                  child: Text(rcpItem.receiptItemName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  //margin: const EdgeInsets.only(right:20,left:10),
                  width: size.width *0.25,
                  child: Text(mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems[widget.index].paperOwner.length.toString()+"명",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: basic[2],
                    ),
                  ),
                ),
                Container(
                  width: size.width *0.3,
                  child: Text(rcpItem.price.toString()+"원",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
        Container(
          height:1,
          color: basic[1],
          margin: const EdgeInsets.symmetric(horizontal: 20),
        )
      ],
    );
  }
}