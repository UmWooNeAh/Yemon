import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/View/settlement_matching.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sqlite_test/shared_tool.dart';
import 'package:sqlite_test/theme.dart';
import 'package:dotted_border/dotted_border.dart';

final receiptProvider =
    ChangeNotifierProvider((ref) => ReceiptInformationViewModel());

class ReceiptInformationViewModel extends ChangeNotifier {
  bool deleteMode = false;
  List<bool> isReceiptSelected = [];
  List<List<bool>> isReceiptItemSelected = [];

  void setDeleteMode(int receiptNumber, List<int> itemNumber) {
    deleteMode = !deleteMode;
    if (deleteMode) {
      set(receiptNumber, itemNumber);
    }
    notifyListeners();
  }

  void addReceipt() {
    isReceiptSelected.add(false);
    isReceiptItemSelected.add([]);
    notifyListeners();
  }

  void addReceiptItem(int receiptIndex) {
    isReceiptItemSelected[receiptIndex].add(isReceiptSelected[receiptIndex]);
    notifyListeners();
  }

  void set(int receiptNumber, List<int> itemNumber) {
    isReceiptSelected = List.generate(receiptNumber, (index) => false);
    isReceiptItemSelected = List.generate(
      receiptNumber,
      (index) => List.generate(itemNumber[index], (index) => false),
    );
  }

  void selectReceipt(int index) {
    isReceiptSelected[index] = !isReceiptSelected[index];
    for (int i = 0; i < isReceiptItemSelected[index].length; i++) {
      isReceiptItemSelected[index][i] = isReceiptSelected[index];
    }
    notifyListeners();
  }

  void selectReceiptItem(int receiptIndex, int itemIndex) {
    isReceiptItemSelected[receiptIndex][itemIndex] =
        !isReceiptItemSelected[receiptIndex][itemIndex];
    if (!isReceiptItemSelected[receiptIndex][itemIndex]) {
      isReceiptSelected[receiptIndex] = false;
    }
    notifyListeners();
  }

  void deleteSelected() {
    for (int i = isReceiptItemSelected.length - 1; i >= 0; i--) {
      for (int j = isReceiptItemSelected[i].length - 1; j >= 0; j--) {
        if (isReceiptItemSelected[i][j]) {
          isReceiptItemSelected[i].removeAt(j);
        }
      }
    }
    for (int i = isReceiptSelected.length - 1; i >= 0; i--) {
      if (isReceiptSelected[i]) {
        isReceiptSelected.removeAt(i);
        isReceiptItemSelected.removeAt(i);
      }
    }
    notifyListeners();
  }
}

class SettlementInformation extends ConsumerStatefulWidget {
  const SettlementInformation({super.key});

  @override
  ConsumerState<SettlementInformation> createState() =>
      _SettlementInformationState();
}

class _SettlementInformationState extends ConsumerState<SettlementInformation> {
  @override
  void initState() {
    super.initState();
    final rprovider = ref.read(receiptProvider);
    final mprovider = ref.read(mainProvider);
    rprovider.set(
        mprovider.selectedSettlement.receipts.length,
        List.generate(
            mprovider.selectedSettlement.receipts.length,
            (index) => mprovider
                .selectedSettlement.receipts[index].receiptItems.length));
  }

  @override
  Widget build(BuildContext context) {
    final rprovider = ref.watch(receiptProvider);
    final mprovider = ref.watch(mainProvider);
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: basic[0],
        child: Column(
          children: [
            const SettlementMember(),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: basic[1],
                  boxShadow: [
                    BoxShadow(
                      color: basic[2],
                      blurRadius: 5,
                      spreadRadius: -5,
                      offset: const Offset(0, 5),
                      inset: true,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                        height: 60,
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        margin: const EdgeInsets.only(top: 5),
                        child: const ReceiptUpperRow()),
                    const Expanded(
                      child: ReceiptList(),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const RealDeletePopUp();
                    });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: size.width,
                height: rprovider.deleteMode ? 60 : 0,
                decoration: BoxDecoration(
                  color: basic[0],
                  boxShadow: [
                    BoxShadow(
                      color: basic[6],
                      blurRadius: 7,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        margin: const EdgeInsets.only(top: 10, bottom: 5),
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.asset('assets/Bin.png'),
                        ),
                      ),
                      const Text("삭제"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RealDeletePopUp extends ConsumerStatefulWidget {
  const RealDeletePopUp({super.key});

  @override
  ConsumerState<RealDeletePopUp> createState() => _RealDeletePopUpState();
}

class _RealDeletePopUpState extends ConsumerState<RealDeletePopUp> {
  @override
  Widget build(BuildContext context) {
    final rprovider = ref.watch(receiptProvider);
    final mprovider = ref.watch(mainProvider);
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      elevation: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "삭제를 진행하면 다시 되돌릴 수 없습니다.",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: basic[4],
            ),
          ),
          Text(
            "선택한 항목을 삭제하시겠습니까?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: basic[4],
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: basic[0],
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Container(
          height: 55,
          width: size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: basic[2], width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: basic[0],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
            },
            child: Text("취소", style: TextStyle(color: basic[5])),
          ),
        ),
        Container(
          height: 55,
          width: size.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: basic[7],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              mprovider.deleteReceiptItemList(rprovider.isReceiptItemSelected);
              mprovider.deleteReceiptList(rprovider.isReceiptSelected);
              rprovider.deleteSelected();
              rprovider.setDeleteMode(
                  mprovider.selectedSettlement.receipts.length,
                  List.generate(
                      mprovider.selectedSettlement.receipts.length,
                      (index) => mprovider.selectedSettlement.receipts[index]
                          .receiptItems.length));
              ref.watch(settlementMatchingProvider).selectReceipt(-1);
              context.pop();
            },
            child:
                Text("항목 삭제", style: TextStyle(color: basic[0], fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class SettlementMember extends ConsumerWidget {
  const SettlementMember({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 150,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
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
              Stack(
                children: [
                  const MemberList(),
                  IgnorePointer(
                    child: Container(
                      width: size.width - 85,
                      height: 60,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: basic[1],
                            blurRadius: 5,
                            spreadRadius: -15,
                            offset: const Offset(-20, 0),
                            inset: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AddMember();
                    },
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: basic[2], width: 1.5),
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
                  child: Icon(Icons.add, color: basic[3]),
                ),
              ),
            ],
          ),
        ],
      ),
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
                    color: basic[7],
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

class MemberList extends ConsumerWidget {
  const MemberList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 60,
      width: size.width - 85,
      margin: const EdgeInsets.only(left: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            provider.selectedSettlement.settlementPapers.length + 1,
            (index) {
              if (index ==
                  provider.selectedSettlement.settlementPapers.length) {
                return const SizedBox(
                  width: 5,
                );
              }
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
    final mprovider = ref.watch(mainProvider);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (index == 0) {
              return;
            }
            showDialog(
                context: context,
                builder: (context) {
                  return EditMemberName(index: index);
                });
          },
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                border: Border.all(color: basic[2], width: 1.5),
                color: basic[0],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: basic[5],
                    spreadRadius: -4,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ]),
            child: Center(
              child: Text(
                mprovider.selectedSettlement.settlementPapers[index].memberName,
                style: TextStyle(
                    color: index == 0 ? basic[3] : basic[5], fontSize: 17),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 5,
          child: GestureDetector(
            onTap: () {
              mprovider.deleteMember(index);
            },
            child: Container(
              width: 25,
              height: 25,
              color: Colors.transparent,
              // color: Colors.red,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 15,
                  height: index == 0 ? 0 : 15,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Image.asset('assets/Delete.png'),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class EditMemberName extends ConsumerStatefulWidget {
  const EditMemberName({super.key, required this.index});
  final int index;

  @override
  ConsumerState<EditMemberName> createState() => _EditMemberNameState();
}

class _EditMemberNameState extends ConsumerState<EditMemberName> {
  String newName = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final mprovider = ref.watch(mainProvider);
    return AlertDialog(
      elevation: 0,
      title: const Text("이름을 수정합니다"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: basic[0],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
            ),
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Wrap(
          children: [
            Container(
              height: 55,
              width: size.width * 0.35 + 5,
              margin: const EdgeInsets.only(bottom: 10, right: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: basic[2],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: basic[0],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  context.pop();
                },
                child: Text("취소", style: TextStyle(color: basic[5])),
              ),
            ),
            Container(
              height: 55,
              width: size.width * 0.35 + 5,
              margin: const EdgeInsets.only(bottom: 10, left: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: basic[8],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  context.pop();
                  mprovider.editMemberName(newName, widget.index);
                },
                child: Text("이름 저장",
                    style: TextStyle(color: basic[0], fontSize: 15)),
              ),
            ),
            Container(
              height: 30,
              width: size.width * 0.7 + 20,
              child: TextButton(
                onPressed: () {
                  context.pop();
                  mprovider.deleteMember(widget.index);
                },
                child: Text("이 멤버를 삭제하려면 이곳을 터치하세요",
                    style: TextStyle(
                        color: basic[3],
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationColor: basic[5],
                        decorationThickness: 3)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AddMember extends ConsumerStatefulWidget {
  const AddMember({super.key});

  @override
  ConsumerState<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends ConsumerState<AddMember> {
  String newName = "";
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(mainProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      elevation: 0,
      title: const Text("새 멤버를 추가합니다"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: basic[0],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
            ),
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Container(
          height: 55,
          width: size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: basic[2], width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: basic[0],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
            },
            child: Text("취소", style: TextStyle(color: basic[5])),
          ),
        ),
        Container(
          height: 55,
          width: size.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: basic[9],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.addMember([newName]);
              context.pop();
            },
            child:
                Text("멤버 추가", style: TextStyle(color: basic[0], fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class ReceiptUpperRow extends ConsumerWidget {
  const ReceiptUpperRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rprovider = ref.watch(receiptProvider);
    final mprovider = ref.watch(mainProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("정산할 제품",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
        InkWell(
          onTap: () {
            if (mprovider.selectedSettlement.receipts.isEmpty) {
              return;
            }
            rprovider.setDeleteMode(
                mprovider.selectedSettlement.receipts.length,
                List.generate(
                    mprovider.selectedSettlement.receipts.length,
                    (index) => mprovider.selectedSettlement.receipts[index]
                        .receiptItems.length));
          },
          child: Container(
            width: 115,
            height: 40,
            decoration: BoxDecoration(
              color: mprovider.selectedSettlement.receipts.isEmpty
                  ? basic[2]
                  : basic[0],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: mprovider.selectedSettlement.receipts.isEmpty
                      ? basic[2]
                      : rprovider.deleteMode
                          ? basic[2]
                          : basic[8],
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: basic[3],
                  blurRadius: 5,
                  spreadRadius: -5,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Center(
                child: Text(
              rprovider.deleteMode ? "삭제 취소" : "항목 삭제",
              style: TextStyle(
                  color: mprovider.selectedSettlement.receipts.isEmpty
                      ? basic[3]
                      : basic[5],
                  fontSize: 18),
            )),
          ),
        ),
      ],
    );
  }
}

class ReceiptList extends ConsumerWidget {
  const ReceiptList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    return ListView.builder(
      itemCount: provider.selectedSettlement.receipts.length + 2,
      itemBuilder: (context, index) {
        if (index == provider.selectedSettlement.receipts.length) {
          return const AddReceipt();
        } else if (index == provider.selectedSettlement.receipts.length + 1) {
          return const SettlementTotalPrice();
        } else {
          return IncludedReceipt(index: index);
        }
      },
    );
  }
}

class IncludedReceipt extends ConsumerWidget {
  const IncludedReceipt({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mprovider = ref.watch(mainProvider);
    final rprovider = ref.watch(receiptProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: basic[0],
        boxShadow: [
          BoxShadow(
            color: basic[2],
            blurRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 30,
            width: size.width,
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 20,
                  width: rprovider.deleteMode ? 20 : 0,
                  margin: const EdgeInsets.only(right: 5),
                  child: Visibility(
                    visible: rprovider.deleteMode,
                    child: Checkbox(
                      value: index < rprovider.isReceiptItemSelected.length
                          ? rprovider.isReceiptSelected[index]
                          : false,
                      onChanged: (value) {
                        rprovider.selectReceipt(index);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      checkColor: basic[0],
                      activeColor: basic[8],
                      side: BorderSide(color: basic[2], width: 1.5),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width - 60 - 20,
                  ),
                  child: Text(
                    mprovider.selectedSettlement.receipts[index].receiptName,
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return EditReceiptName(index: index);
                        });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, top: 5),
                    width: 15,
                    height: 15,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset('assets/Edit.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const ReceiptItemUpperRow(),
                IncludedReceiptItem(receiptIndex: index),
                AddReceiptItem(index: index),
                ReceiptTotalPrice(index: index),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditReceiptName extends ConsumerStatefulWidget {
  const EditReceiptName({super.key, required this.index});
  final int index;

  @override
  ConsumerState<EditReceiptName> createState() => _EditReceiptNameState();
}

class _EditReceiptNameState extends ConsumerState<EditReceiptName> {
  String newName = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final mprovider = ref.watch(mainProvider);
    return AlertDialog(
      elevation: 0,
      title: const Text("영수증의 이름을 수정합니다"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: basic[0],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: basic[5]),
              ),
            ),
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Container(
          height: 55,
          width: size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: basic[2], width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: basic[0],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
            },
            child: Text("취소", style: TextStyle(color: basic[5])),
          ),
        ),
        Container(
          height: 55,
          width: size.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: basic[9],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
              mprovider.editReceiptName(newName, widget.index);
            },
            child:
                Text("이름 변경", style: TextStyle(color: basic[0], fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class ReceiptItemUpperRow extends StatelessWidget {
  const ReceiptItemUpperRow({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "제품명",
                style: TextStyle(color: basic[3], fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            )),
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.25,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "단가",
                style: TextStyle(color: basic[3], fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            )),
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "수량",
                style: TextStyle(color: basic[3], fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            )),
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.25,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "금액",
                style: TextStyle(color: basic[3], fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }
}

class AddReceiptItem extends ConsumerWidget {
  const AddReceiptItem({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    final rprovider = ref.watch(receiptProvider);
    final sProvider = ref.watch(settlementMatchingProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 40,
      width: size.width - 60,
      child: DottedBorder(
        dashPattern: const [4, 4],
        strokeWidth: 1,
        strokeCap: StrokeCap.round,
        color: basic[2],
        child: InkWell(
          onTap: () {
            rprovider.addReceiptItem(index);
            provider.addReceiptItem(index);
          },
          child: const Center(
              child: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Icon(Icons.add_circle_outline_outlined))),
                Text(" 제품 추가"),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

class IncludedReceiptItem extends ConsumerWidget {
  const IncludedReceiptItem({super.key, required this.receiptIndex});
  final int receiptIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final mprovider = ref.watch(mainProvider);
    final rprovider = ref.watch(receiptProvider);
    return Column(
      children: List.generate(
        mprovider.selectedSettlement.receipts[receiptIndex].receiptItems.length,
        (index) {
          return SizedBox(
            height: 45,
            width: size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    final rprovider = ref.watch(receiptProvider);
                    rprovider.selectReceiptItem(receiptIndex, index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 30,
                    width: rprovider.deleteMode ? 20 : 0,
                    margin: const EdgeInsets.only(right: 5),
                    child: Visibility(
                      visible: rprovider.deleteMode,
                      child: Checkbox(
                        value: rprovider.isReceiptItemSelected[receiptIndex]
                            [index],
                        onChanged: (value) {
                          rprovider.selectReceiptItem(receiptIndex, index);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkColor: Colors.white,
                        activeColor: basic[8],
                        side: BorderSide(color: basic[2], width: 1.5),
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 30,
                    width: rprovider.deleteMode
                        ? (size.width - 60) * 0.3 - 20 - 5
                        : (size.width - 60) * 0.3 - 5,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: basic[5]),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: basic[8]),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: basic[5]),
                          ),
                        ),
                        onTap: () {
                          mprovider.moveReceiptItemControllerCursor(
                              receiptIndex, index, 0);
                        },
                        buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) {
                          return const SizedBox.shrink();
                        },
                        controller: mprovider
                            .receiptItemControllerList[receiptIndex][index][0],
                        onChanged: (value) {
                          mprovider.editReceiptItemName(
                              value, receiptIndex, index);
                        },
                      ),
                    )),
                Container(
                    height: 30,
                    width: (size.width - 60) * 0.25 - 20,
                    margin: const EdgeInsets.only(left: 20),
                    child: TextField(
                      onTap: () {
                        mprovider.moveReceiptItemControllerCursor(
                            receiptIndex, index, 1);
                      },
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: basic[5]),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: basic[8]),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: basic[5]),
                        ),
                      ),
                      controller: mprovider
                          .receiptItemControllerList[receiptIndex][index][1],
                      maxLength: 7,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) {
                        return const SizedBox.shrink();
                      },
                      onChanged: (value) {
                        if (value == '') {
                          value = '0';
                        }
                        value = value.replaceAll(RegExp(r'[^0-9]'), '');
                        mprovider.editReceiptItemIndividualPrice(
                            double.parse(value), receiptIndex, index);
                      },
                      textAlign: TextAlign.right,
                    )),
                Container(
                    height: 30,
                    width: (size.width - 60) * 0.2 - 30,
                    margin: const EdgeInsets.only(left: 30),
                    child: TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: basic[5]),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: basic[8]),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: basic[5]),
                        ),
                      ),
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) {
                        return const SizedBox.shrink();
                      },
                      onTap: () {
                        mprovider.moveReceiptItemControllerCursor(
                            receiptIndex, index, 2);
                      },
                      controller: mprovider
                          .receiptItemControllerList[receiptIndex][index][2],
                      onChanged: (value) {
                        if (value == '') {
                          value = '0';
                        }
                        value = value.replaceAll(RegExp(r'[^0-9]'), '');
                        mprovider.editReceiptItemCount(
                            int.parse(value), receiptIndex, index);
                      },
                      maxLength: 2,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textAlign: TextAlign.right,
                    )),
                SizedBox(
                  height: 30,
                  width: (size.width - 60) * 0.25,
                  // child: Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Text(
                  //     mprovider
                  //         .receiptItemControllerList[receiptIndex][index][3]
                  //         .text,
                  //     style: TextStyle(
                  //       color: basic[5],
                  //       fontSize: 17,
                  //     ),
                  //   ),
                  // )
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: basic[0]),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: basic[0]),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: basic[0]),
                      ),
                    ),
                    controller: mprovider
                        .receiptItemControllerList[receiptIndex][index][3],
                    onChanged: (value) {
                      if (value == '') {
                        value = '0';
                      }
                      value = value.replaceAll(RegExp(r'[^0-9]'), '');
                      mprovider.editReceiptItemPrice(
                          double.parse(value), receiptIndex, index);
                    },
                    onTap: () {
                      mprovider.moveReceiptItemControllerCursor(
                          receiptIndex, index, 3);
                    },
                    buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) {
                      return const SizedBox.shrink();
                    },
                    maxLength: 10,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReceiptTotalPrice extends ConsumerWidget {
  const ReceiptTotalPrice({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    return Container(
      height: 40,
      padding: const EdgeInsets.only(right: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "합계  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: priceToString.format(provider
                    .selectedSettlement.receipts[index].totalPrice
                    .toInt()),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: "원",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddReceipt extends ConsumerWidget {
  const AddReceipt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mprovider = ref.watch(mainProvider);
    final rprovider = ref.watch(receiptProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 50,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: basic[1],
      ),
      child: DottedBorder(
        dashPattern: const [4, 4],
        strokeWidth: 1,
        strokeCap: StrokeCap.round,
        color: basic[3],
        child: InkWell(
          onTap: () {
            rprovider.addReceipt();
            mprovider.addReceipt();
          },
          child: const Center(
              child: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Icon(Icons.add_circle_outline_outlined))),
                Text(" 영수증 추가"),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  BorderPainter(
      {required this.width,
      required this.height,
      this.horizontal = 20,
      this.vertical = 10});
  final double width, height;
  final double horizontal, vertical;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = basic[4]
      ..strokeWidth = 1;
    canvas.drawLine(Offset(horizontal, vertical),
        Offset(width - horizontal, vertical), paint);
    canvas.drawLine(Offset(width - horizontal, vertical),
        Offset(width - horizontal, height + vertical), paint);
    canvas.drawLine(Offset(width - horizontal, height + vertical),
        Offset(horizontal, height + vertical), paint);
    canvas.drawLine(Offset(horizontal, height + vertical),
        Offset(horizontal, vertical), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SettlementTotalPrice extends ConsumerWidget {
  const SettlementTotalPrice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mainProvider);
    return Container(
      height: 40,
      padding: const EdgeInsets.only(right: 10,),
      margin: const EdgeInsets.only(bottom: 30),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "합계  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: priceToString
                    .format(provider.selectedSettlement.totalPrice.toInt()),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: basic[8],
                ),
              ),
              const TextSpan(
                text: "원",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
