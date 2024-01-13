import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sqlite_test/theme.dart';

class SettlementInformation extends ConsumerStatefulWidget {
  const SettlementInformation({super.key});

  @override
  ConsumerState<SettlementInformation> createState() =>
      _SettlementInformationState();
}

class _SettlementInformationState extends ConsumerState<SettlementInformation> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(mainProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SettlementName(),
        const SettlementMember(),
        TextButton(
          onPressed: () {},
          child: const Text("항목 삭제하기"),
        ),
        const Expanded(
          child: ReceiptList(),
        ),
        Container(
          height: 40,
          color: basic[2],
          padding: const EdgeInsets.only(right: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "총 금액",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: provider.selectedSettlement.totalPrice.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: basic[4],
                    ),
                  ),
                  const TextSpan(
                    text: " 원",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IncludedReceiptItem extends StatefulWidget {
  const IncludedReceiptItem({super.key});

  @override
  State<IncludedReceiptItem> createState() => _IncludedReceiptItemState();
}

class _IncludedReceiptItemState extends State<IncludedReceiptItem> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: List.generate(
        3,
        (index) {
          return SizedBox(
            height: 40,
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.3,
                    child: Text(
                      "항목이름1",
                      overflow: TextOverflow.ellipsis,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.25,
                    child: Text(
                      "0,000",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.2,
                    child: Text(
                      "2",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.25,
                    child: Text(
                      "0,000",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class IncludedReceipt extends StatelessWidget {
  const IncludedReceipt({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      color: basic[2],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        color: basic[1],
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 40,
              width: size.width,
              child: Row(
                children: [Text("${index} 영수증")],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.3,
                    child: Text("제품명", overflow: TextOverflow.ellipsis)),
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.25,
                    child: Text(
                      "단가",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.2,
                    child: Text(
                      "수량",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 40) * 0.25,
                    child: Text(
                      "금액",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )),
              ],
            ),
            IncludedReceiptItem(),
            Container(
              height: 40,
              width: size.width - 80,
              child: ElevatedButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
            Container(
              height: 40,
              width: size.width,
              child: Text("총금액 : 0, 0000원"),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptList extends ConsumerStatefulWidget {
  const ReceiptList({super.key});

  @override
  ConsumerState<ReceiptList> createState() => _SettlementReceiptState();
}

class _SettlementReceiptState extends ConsumerState<ReceiptList> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      itemCount: 7 + 1,
      itemBuilder: (context, index) {
        if (index == 7) {
          return Container(
            width: size.width,
            height: 70,
            color: basic[2],
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("항목 추가하기"),
            ),
          );
        }
        return IncludedReceipt(index: index);
      },
    );
  }
}

class SettlementMember extends ConsumerStatefulWidget {
  const SettlementMember({super.key});

  @override
  ConsumerState<SettlementMember> createState() => _SettlementMemberState();
}

class _SettlementMemberState extends ConsumerState<SettlementMember> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = ref.watch(mainProvider);
    return Container(
      width: size.width,
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: basic[1],
        boxShadow: [
          BoxShadow(
            color: basic[2],
            inset: true,
            blurRadius: 5,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: basic[2],
            inset: true,
            blurRadius: 5,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const MemberUpperRow(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MemberList(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      color: basic[0],
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: basic[3],
                          blurRadius: 5,
                          spreadRadius: -5,
                          offset: const Offset(5, 5),
                        ),
                      ]),
                  child: Icon(Icons.add, color: basic[2]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MemberList extends ConsumerStatefulWidget {
  const MemberList({super.key});

  @override
  ConsumerState<MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<MemberList> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = ref.watch(mainProvider);
    return Container(
      height: 80,
      width: size.width - 70,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: basic[1],
        boxShadow: [
          BoxShadow(
            color: basic[1],
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(-15, 0),
            inset: true,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            5,
            (index) {
              return IncludedMember(index: index);
            },
          ),
        ),
      ),
    );
  }
}

class IncludedMember extends ConsumerWidget {
  const IncludedMember({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    return Stack(
      children: [
        Container(
          height: 60,
          width: 1,
        ),
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: basic[0],
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              // Text("provider.selectedSettlement.settlementPapers[index].memberName"),
              Center(child: Text("${index}번째 멤버")),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 20,
            height: 20,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                Icons.close,
                color: basic[4],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MemberUpperRow extends ConsumerWidget {
  const MemberUpperRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "정산에 참여하는 사람",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      " ${provider.selectedSettlement.settlementPapers.length}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: basic[4],
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            context.push('/SettlementManagementPage/LoadMemberPage');
          },
          child: const Text("최근 정산 불러오기 >"),
        ),
      ],
    );
  }
}

class SettlementName extends ConsumerWidget {
  const SettlementName({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final provider = ref.watch(mainProvider);
    return Container(
      width: size.width,
      height: 60,
      // color: basic[1],
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Container(
            height: 40,
            // color: basic[2],
            margin: const EdgeInsets.only(left: 10),
            child: Center(
              child: Text(
                provider.selectedSettlement.settlementName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              width: 40,
              height: 40,
              // color: basic[2],
              child: const Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }
}
