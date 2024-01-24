

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_test/DB/db_test.dart';
import 'package:sqlite_test/View/settlement_matching.dart';

import '../Model/ReceiptItem.dart';
import '../Model/SettlementItem.dart';
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
                      onPressed: () {
                        print("receipt item");
                        mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems.forEach((element) {
                          print(element.receiptItemName);
                          element.paperOwner.forEach((key, value) {
                            print("${key} : ${value}");
                          });
                        });
                        print("stmPaper");
                        mProvider.selectedSettlement.settlementPapers.forEach((paper) {
                          print(paper.memberName);
                          paper.settlementItems.forEach((element){
                            print("${element.name} ${element.splitPrice}");
                          });
                        });
                      },
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap:(){
            if(sProvider.selectedMemberIndexList.contains(true)){
              //print(mProvider.selectedSettlement.settlementPapers.length);
              List<int> userIndexes = sProvider.matching();
              for(int index in userIndexes){
                mProvider.matching(index, widget.index, sProvider.presentReceiptIndex);
              }
            } else {
              sProvider.toggleMatchingDetail(widget.index);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: sProvider.showMatchingDetail == widget.index ? 50 : 50,
            color: sProvider.selectedReceiptItemIndexList[widget.index] ? basic[1] : Colors.white,
            child: Column(
              children: [
                Row(
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

              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size.width,
          height:sProvider.showMatchingDetail == widget.index ? 120 : 1,
          color: basic[1],
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            children: List.generate(mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems[widget.index].paperOwner.length, (idx) => SingleSettlementMember(stmPaperId: mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems[widget.index].paperOwner.keys.toList()[idx],receiptItemId:widget.index)),
          ),
        ),
        SizedBox(height:10)
      ],
    );


  }
}

class SingleSettlementMember extends ConsumerWidget {
  final String stmPaperId;
  final int receiptItemId;
  const SingleSettlementMember({Key? key,required this.stmPaperId, required this.receiptItemId}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final sProvider = ref.watch(settlementMatchingProvider);
    final mProvider = ref.watch(mainProvider);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: basic[0],
            border: Border.all(
              color: basic[2],
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 1,
                offset: const Offset(1.5,1.5),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(height:5),
              Text(mProvider.selectedSettlement.settlementPapers.firstWhere((element) => element.settlementPaperId == stmPaperId).memberName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          child: InkWell(
            onTap: (){
              //mProvider.deleteMemberFromReceiptItem(mProvider.selectedSettlement.receipts[sProvider.presentReceiptIndex].receiptItems[receiptId], stmPaperId);
              mProvider.unmatching(sProvider.presentReceiptIndex, receiptItemId, stmPaperId);
              },
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: basic[7],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 1,
                    offset: const Offset(1.5,1.5),
                  ),
                ],
              ),
              child: const Text("✕",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
            ),
          ),
        ),
        )
      ],
    );
  }
}
