

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/ReceiptItem.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';

class MenuSheet extends ConsumerWidget {
  const MenuSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final size =  MediaQuery.of(context).size;
    final mProvider = ref.watch(mainProvider);
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
            SizedBox(height:10),
            SingleChildScrollView(
              child: Column(
                  // children : List.generate(mProvider.selectedSettlement.receipts.first.receiptItems.length, (index) => SingleMenu(rcpItem: mProvider.selectedSettlement.receipts.first.receiptItems[index],))
              ),
            )
          ]
      ),
    );
  }
}

class SingleMenu extends StatefulWidget {
  final ReceiptItem rcpItem;
  const SingleMenu({super.key, required this.rcpItem});

  @override
  State<SingleMenu> createState() => _SingleMenuState();
}

class _SingleMenuState extends State<SingleMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: size.width*0.1),
              Text(widget.rcpItem.receiptItemName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: size.width*0.05),
              Text("2명",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: basic[2],
                ),
              ),
              SizedBox(width: size.width*0.35),
              Text(widget.rcpItem.price.toString(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

            ],
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