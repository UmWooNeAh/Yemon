import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../shared_tool.dart';
import '../theme.dart';
import '../ViewModel/mainviewmodel.dart';

class EditManagement extends ChangeNotifier {
  bool isEdit = false;
  bool isAllSelect = false;
  List<bool> isSelected = [];

  void deleteSettlement(){
    isSelected = List.generate(isSelected.where((element) => element == false).length, (index) => false);
    notifyListeners();
  }
  
  void addSettlement() {
    isSelected.insert(0, false);
    notifyListeners();
  }

  void toggleEdit(int size) {
    isEdit = !isEdit;
    isSelected = List.generate(size, (index) => false);
    isAllSelect = false;
    notifyListeners();
  }

  void toggleSelect(int index) {
    isSelected[index] = !isSelected[index];
    notifyListeners();
  }

  void toggleAllSelect(int size) {
    isAllSelect = !isAllSelect;
    isSelected = List.generate(size, (index) => isAllSelect);
    notifyListeners();
  }

  bool checkMultipleSelect() {
    int cnt = isSelected.where((element) => element == true).length;

    return cnt >= 2;
  }
}

final editManagementProvider =
    ChangeNotifierProvider((ref) => EditManagement());

class SettlementListPage extends ConsumerStatefulWidget {
  const SettlementListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettlementListPage> createState() => _SettlementListPageState();
}

class _SettlementListPageState extends ConsumerState<SettlementListPage> {
  @override
  Widget build(BuildContext context) {
    final eprovider = ref.watch(editManagementProvider);
    final provider = ref.watch(mainProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: basic[0],
        elevation: 0,
        title: Row(
          children: [
            const Text(
              "Yemon",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            Container(
              child: FlutterLogo(),
              margin: const EdgeInsets.only(left: 5),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20),
                height: 60,
                child: eprovider.isEdit
                    ? Row(
                        children: [
                          Column(
                            children: [
                              Transform.scale(
                                scale: 1.6,
                                child: Checkbox(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: eprovider.isAllSelect,
                                  onChanged: (value) {
                                    eprovider.toggleAllSelect(
                                        provider.settlementList.length);
                                  },
                                  activeColor: basic[8],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: BorderSide(color: basic[2], width: 1),
                                ),
                              ),
                              Text(
                                "전체",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "${eprovider.isSelected.where((element) => element == true).length}개 선택됨",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: eprovider.isSelected
                                      .where((element) => element == true)
                                      .isEmpty
                                  ? basic[3]
                                  : basic[5],
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          "최근 정산 목록",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              Container(
                height: 50,
                width: 130,
                margin: const EdgeInsets.only(right: 20),
                child: OutlinedButton(
                  onPressed: () {
                    eprovider.toggleEdit(provider.settlementList.length);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: eprovider.isEdit ? basic[2] : basic[8],
                        width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    eprovider.isEdit ? "편집 취소" : "목록 편집",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  children: List.generate(provider.settlementList.length,
                      (index) => SingleSettlement(index: index))),
            ),
          ),
          AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: size.width,
              height: eprovider.isEdit && eprovider.isSelected.contains(true)
                  ? 60
                  : 0,
              decoration: BoxDecoration(
                color: basic[1],
                boxShadow: [
                  BoxShadow(
                    color: basic[1],
                    blurRadius: 8,
                    spreadRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: eprovider.checkMultipleSelect()
                  ? InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context)=>const DeleteSettlement());
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete),
                              Text(
                                "삭제",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context)=>const EditSettlementName());
                          },
                          child: SingleChildScrollView(
                            child: Container(
                              width: (size.width-20) / 2,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit),
                                  Text(
                                    "이름 변경",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          thickness: 2,
                          color: basic[2],
                          endIndent: 10,
                          indent: 10,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context)=> const DeleteSettlement());
                          },
                          child: SingleChildScrollView(
                            child: Container(
                              width: (size.width-20) / 2,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete),
                                  Text(
                                    "삭제",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
        ]),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(
            bottom: eprovider.isEdit && eprovider.isSelected.contains(true)
                ? 80
                : 0),
        child: FloatingActionButton(
          onPressed: () {
            context.push('/SettlementManagementPage');
            provider.addNewSettlement();
            provider.selectSettlement(0);
            eprovider.addSettlement();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100)
          ),
          backgroundColor: basic[8],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SingleSettlement extends ConsumerWidget {
  const SingleSettlement({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editManagement = ref.watch(editManagementProvider);
    final provider = ref.watch(mainProvider);
    final size = MediaQuery.of(context).size;
    return Container(
      color: editManagement.isSelected[index] ? basic[1] : basic[0],
      width: size.width - 40,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: EdgeInsets.symmetric(
                      horizontal: editManagement.isEdit ? 10 : 0),
                  width: editManagement.isEdit ? 30 : 0,
                  height: 30,
                  child: Visibility(
                    visible: editManagement.isEdit,
                    child: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        value: editManagement.isSelected[index],
                        onChanged: (value) {
                          if (!editManagement.isEdit) return;
                          editManagement.toggleSelect(index);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkColor: Colors.white,
                        activeColor: basic[8],
                        side: BorderSide(width: 1, color: basic[2]),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (editManagement.isEdit) {
                      editManagement.toggleSelect(index);
                    } else {
                      provider.selectSettlement(index);
                      context.push('/SettlementManagementPage');
                    }
                  },
                  onLongPress: () {
                    if (!editManagement.isEdit) {
                      editManagement.toggleEdit(provider.settlementList.length);
                    }
                    editManagement.toggleSelect(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: size.width - (editManagement.isEdit ? 90 : 70),
                    height: 95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 35,
                          width: size.width - 70,
                          margin: const EdgeInsets.only(top: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              provider.settlementList[index].settlementName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 25,
                          width: size.width - 90,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${provider.settlementList[index].settlementPapers.length} 명 : ",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                                TextSpan(
                                  text: List.generate(
                                      provider.settlementList[index]
                                          .settlementPapers.length,
                                      (pindex) => provider
                                          .settlementList[index]
                                          .settlementPapers[pindex]
                                          .memberName).join(", "),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: basic[3],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width - 70,
                          height: 25,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top:5 ),
                                child: Text(
                                  provider.settlementList[index].date
                                      .toString()
                                      .substring(0, 10),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: basic[3]),
                                ),
                              ),
                              Text(
                                "  ${intToWeekDay(provider.settlementList[index].date.weekday)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: basic[3],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: basic[2],
            height: 1,
            width: size.width,
          )
        ],
      ),
    );
  }
}

class EditSettlementName extends ConsumerStatefulWidget {
  const EditSettlementName({Key? key}) : super(key: key);

  @override
  ConsumerState<EditSettlementName> createState() => _EditSettlementNameState();
}

class _EditSettlementNameState extends ConsumerState<EditSettlementName> {
  @override
  Widget build(BuildContext context) {
    String newName = "";
    final eprovider = ref.watch(editManagementProvider);
    final provider = ref.watch(mainProvider);
    return AlertDialog(
      elevation: 0,
      title: const Text(
        "정산의 이름을 수정합니다",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
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
                borderSide:
                BorderSide(color: basic[5]),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: basic[5]),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: basic[5]),
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
      actionsAlignment:
      MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(
                color: basic[2], width: 1.5),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: basic[0],
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
            },
            child: Text("취소",
                style:
                TextStyle(color: basic[5])),
          ),
        ),
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: basic[9],
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.editSettlementName(newName, eprovider.isSelected.indexOf(true));
              context.pop();
            },
            child: Text("이름 변경",
                style: TextStyle(
                    color: basic[0],
                    fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class DeleteSettlement extends ConsumerStatefulWidget {
  const DeleteSettlement({Key? key}) : super(key: key);

  @override
  ConsumerState<DeleteSettlement> createState() => _DeleteSettlementState();
}

class _DeleteSettlementState extends ConsumerState<DeleteSettlement> {
  @override
  Widget build(BuildContext context) {
    final eprovider = ref.watch(editManagementProvider);
    final provider = ref.watch(mainProvider);
    return AlertDialog(
      elevation: 0,
      title: Text(
        "정산의 삭제하면 다시 되돌릴 수 없습니다\n선택한 정산을 삭제하시겠습니까?",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: basic[4],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: basic[0],
      actionsAlignment:
      MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(
                color: basic[2], width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: basic[0],
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.pop();
            },
            child: Text("취소",
                style: TextStyle(color: basic[5])),
          ),
        ),
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width * 0.35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: basic[7],
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.deleteSettlement(eprovider.isSelected);
              eprovider.deleteSettlement();
              context.pop();
            },
            child: Text("정산 삭제",
                style: TextStyle(
                    color: basic[0], fontSize: 15)),
          ),
        ),
      ],
    );
  }
}


