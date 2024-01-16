import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sqlite_test/theme.dart';

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
    if (isReceiptSelected[index]) {
      for (int i = 0; i < isReceiptItemSelected[index].length; i++) {
        isReceiptItemSelected[index][i] = true;
      }
    }
    notifyListeners();
  }

  void selectReceiptItem(int receiptIndex, int itemIndex) {
    isReceiptItemSelected[receiptIndex][itemIndex] =
        !isReceiptItemSelected[receiptIndex][itemIndex];
    notifyListeners();
  }

  void deleteSelected() {
    for (int i = isReceiptSelected.length - 1; i >= 0; i--) {
      if (isReceiptSelected[i]) {
        isReceiptSelected.removeAt(i);
        isReceiptItemSelected.removeAt(i);
      }
    }
    for (int i = isReceiptItemSelected.length - 1; i >= 0; i--) {
      for (int j = isReceiptItemSelected[i].length - 1; j >= 0; j--) {
        if (isReceiptItemSelected[i][j]) {
          isReceiptItemSelected[i].removeAt(j);
        }
      }
      if (isReceiptItemSelected[i].isEmpty) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SettlementName(),
        const SettlementMember(),
        TextButton(
          onPressed: () {
            rprovider.setDeleteMode(
                mprovider.selectedSettlement.receipts.length,
                List.generate(
                    mprovider.selectedSettlement.receipts.length,
                    (index) => mprovider.selectedSettlement.receipts[index]
                        .receiptItems.length));
          },
          child: const Text("항목 삭제하기"),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: basic[2],
            child: const ReceiptList(),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: size.width,
          height: rprovider.deleteMode ? 80 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 50,
                width: (size.width - 40) * 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    rprovider.setDeleteMode(
                        mprovider.selectedSettlement.receipts.length,
                        List.generate(
                            mprovider.selectedSettlement.receipts.length,
                            (index) => mprovider.selectedSettlement
                                .receipts[index].receiptItems.length));
                  },
                  child: const Text("취소하기"),
                ),
              ),
              Container(
                height: 50,
                width: (size.width - 40) * 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    mprovider
                        .deleteReceiptItemList(rprovider.isReceiptItemSelected);
                    mprovider.deleteReceiptList(rprovider.isReceiptSelected);
                    rprovider.deleteSelected();
                    rprovider.setDeleteMode(
                        mprovider.selectedSettlement.receipts.length,
                        List.generate(
                            mprovider.selectedSettlement.receipts.length,
                            (index) => mprovider.selectedSettlement
                                .receipts[index].receiptItems.length));
                  },
                  child: const Text("삭제하기"),
                ),
              ),
            ],
          ),
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
            margin: const EdgeInsets.only(left: 10),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.width - 70),
                child: Text(
                  provider.selectedSettlement.settlementName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const EditSettlementName();
                  });
            },
            child: Container(
              width: 40,
              height: 40,
              child: const Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }
}

class EditSettlementName extends ConsumerStatefulWidget {
  const EditSettlementName({super.key});

  @override
  ConsumerState<EditSettlementName> createState() => _EditSettlementNameState();
}

class _EditSettlementNameState extends ConsumerState<EditSettlementName> {
  String newName = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Settlement Name"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("New Settlement Name : "),
          TextField(
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text("취소하기"),
        ),
        TextButton(
          onPressed: () {
            final provider = ref.watch(mainProvider);
            provider.editSettlementName(newName);
            context.pop();
          },
          child: const Text("변경하기"),
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
      margin: const EdgeInsets.symmetric(vertical: 5),
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
                            blurRadius: 15,
                            spreadRadius: -20,
                            offset: const Offset(-30, 0),
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
            provider.selectedSettlement.settlementPapers.length,
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
    final mprovider = ref.watch(mainProvider);
    return Stack(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: basic[0],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(mprovider
                .selectedSettlement.settlementPapers[index].memberName),
          ),
        ),
        Positioned(
          right: 0,
          top: 5,
          child: GestureDetector(
            onTap: () {
              mprovider.deleteMember(index);
            },
            child: SizedBox(
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
          ),
        )
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
    return AlertDialog(
      title: const Text("Add Settlement Member"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("New Member Name : "),
          TextField(
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text("취소하기"),
        ),
        TextButton(
          onPressed: () {
            provider.addMember(newName);
            context.pop();
          },
          child: const Text("추가하기"),
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
      color: basic[1],
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        children: [
          Container(
            height: 30,
            width: size.width,
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    rprovider.selectReceipt(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 20,
                    width: rprovider.deleteMode ? 20 : 0,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(
                        rprovider.isReceiptSelected[index]
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: basic[4],
                      ),
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
                    margin: const EdgeInsets.only(left: 5),
                    width: 20,
                    height: 20,
                    child: const FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(Icons.edit),
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
    final mprovider = ref.watch(mainProvider);
    return AlertDialog(
      title: const Text("Edit Receipt Name"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("New Receipt Name : "),
          TextField(
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text("취소하기"),
        ),
        TextButton(
          onPressed: () {
            context.pop();
            mprovider.editReceiptName(newName, widget.index);
          },
          child: const Text("변경하기"),
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
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "제품명",
                overflow: TextOverflow.ellipsis,
              ),
            )),
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.25,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "단가",
                overflow: TextOverflow.ellipsis,
              ),
            )),
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.2,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "수량",
                overflow: TextOverflow.ellipsis,
              ),
            )),
        SizedBox(
            height: 40,
            width: (size.width - 60) * 0.25,
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "금액",
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
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 40,
      width: size.width - 80,
      decoration: BoxDecoration(
        color: basic[0],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: () {
          rprovider.addReceiptItem(index);
          provider.addReceiptItem(index);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class IncludedReceiptItem extends ConsumerWidget {
  const IncludedReceiptItem({super.key, required this.receiptIndex});
  final int receiptIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> cursorPositions = [0, 0, 0, 0];
    Size size = MediaQuery.of(context).size;
    final mprovider = ref.watch(mainProvider);
    final rprovider = ref.watch(receiptProvider);
    return Column(
      children: List.generate(
        mprovider.selectedSettlement.receipts[receiptIndex].receiptItems.length,
        (index) {
          return SizedBox(
            height: 40,
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    final rprovider = ref.watch(receiptProvider);
                    rprovider.selectReceiptItem(receiptIndex, index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 20,
                    width: rprovider.deleteMode ? 20 : 0,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(
                        rprovider.isReceiptItemSelected[receiptIndex][index]
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: basic[4],
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 40,
                    width: rprovider.deleteMode
                        ? (size.width - 60) * 0.3 - 20
                        : (size.width - 60) * 0.3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: mprovider
                            .receiptItemControllerList[receiptIndex][index][0],
                        onChanged: (value) {
                          mprovider.editReceiptItemName(
                              value, receiptIndex, index);
                        },
                      ),
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 60) * 0.25,
                    child: TextField(
                      controller: mprovider
                          .receiptItemControllerList[receiptIndex][index][1],
                      onChanged: (value) {
                        if (value == '') {
                          value = '0';
                        }
                        mprovider.editReceiptItemIndividualPrice(
                            double.parse(value), receiptIndex, index);
                      },
                      textAlign: TextAlign.right,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 60) * 0.2,
                    child: TextField(
                      controller: mprovider
                          .receiptItemControllerList[receiptIndex][index][2],
                      onChanged: (value) {
                        if (value == '') {
                          value = '0';
                        }
                        mprovider.editReceiptItemCount(
                            int.parse(value), receiptIndex, index);
                      },
                      textAlign: TextAlign.right,
                    )),
                SizedBox(
                    height: 40,
                    width: (size.width - 60) * 0.25,
                    child: TextField(
                      controller: mprovider
                          .receiptItemControllerList[receiptIndex][index][3],
                      onChanged: (value) {
                        if (value == '') {
                          value = '0';
                        }
                        mprovider.editReceiptItemPrice(
                            double.parse(value), receiptIndex, index);
                      },
                      textAlign: TextAlign.right,
                    )),
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
                text: "총 금액 ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: provider.selectedSettlement.receipts[index].totalPrice
                    .toString(),
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
      child: ElevatedButton(
        onPressed: () {
          rprovider.addReceipt();
          mprovider.addReceipt();
        },
        child: const Text("항목 추가하기"),
      ),
    );
  }
}

class SettlementTotalPrice extends ConsumerWidget {
  const SettlementTotalPrice({super.key});

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
                text: "총 금액 ",
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
    );
  }
}
