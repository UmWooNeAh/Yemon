import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite_test/ViewModel/mainviewmodel.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sqlite_test/theme.dart';
import '../theme.dart';
import '../ViewModel/mainviewmodel.dart';
import '../theme.dart';

int size = 10;

class EditManagement extends ChangeNotifier{
  bool isEdit = false;
  bool isAllSelect = false;
  List<bool> isSelected = List.generate(size, (index) => false);

  void toggleEdit(){
    isEdit = !isEdit;
    isSelected = List.generate(size, (index) => false);
    notifyListeners();
  }

  void toggleSelect(int index){
    isSelected[index] = !isSelected[index];
    notifyListeners();
  }

  void toggleAllSelect(){
    isAllSelect = !isAllSelect;
    isSelected = List.generate(size, (index) => isAllSelect);
    notifyListeners();
  }

  bool checkMultipleSelect(){
    int cnt = isSelected.where((element) => element == true).length;

    return cnt >= 2;
  }

}

final editManagementProvider = ChangeNotifierProvider((ref) => EditManagement());

class SettlementListPage extends ConsumerStatefulWidget {
  const SettlementListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettlementListPage> createState() => _SettlementListPageState();
}

class _SettlementListPageState extends ConsumerState<SettlementListPage> {

  @override
  Widget build(BuildContext context) {
    final editManagement = ref.watch(editManagementProvider);
    final provider = ref.watch(mainProvider);
    final sizes = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: editManagement.isEdit ? Row(
                    children: [
                      Column(
                        children: [
                          Transform.scale(
                            scale: 1.6,
                            child: Checkbox(
                              value: editManagement.isAllSelect,
                              onChanged: (value){
                                editManagement.toggleAllSelect();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Text("전체")
                        ],
                      ),
                      Text("${editManagement.isSelected.where((element) => element == true).length}개 선택됨",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: basic[3],
                        ),
                      )
                    ],
                  ): const Text("최근 정산 목록",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap:(){
                    editManagement.toggleEdit();
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(right:20),
                      child: Text("목록 편집",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: basic[2],
                        ),
                      ),
                    ),
                )
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(size, (index) => SingleSettlement(index:index))
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 150),
              width: sizes.width,
              height: editManagement.isEdit && editManagement.isSelected.contains(true) ? 80 : 0,
                decoration: BoxDecoration(
                  color: basic[1],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      inset: true,
                      blurRadius: 5,
                      spreadRadius: -5,
                      offset: const Offset(0, -5),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      inset: true,
                      blurRadius: 5,
                      spreadRadius: -5,
                      offset: const Offset(0, 5),
                    ),

                  ],
                ),
              child: InkWell(
                onTap:(){
                },
                child: editManagement.checkMultipleSelect() ? Container(
                  margin: const EdgeInsets.only(left: 40, right: 40, top: 10, bottom:10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete),
                      Text("삭제",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                    ],
                  ),
                ) :
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: (){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: const Text("정산 이름 변경"),
                            content: TextField(
                              onChanged: (value){

                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: const Text("취소"),
                              ),
                              TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: const Text("확인"),
                              ),
                            ],
                          );
                        });
                      },
                      child: Container(
                        width: sizes.width * 0.4,
                        height: 60,
                        color: basic[2],
                        child: const Center(
                          child: Text("이름 변경",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){},
                      child: Container(
                        width: sizes.width * 0.4,
                        height: 60,
                        color: basic[2],
                        child: const Center(
                          child: Text("삭제",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              )
            )
          ]
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: editManagement.isEdit && editManagement.isSelected.contains(true) ? 80 : 0),
        child: FloatingActionButton(
          onPressed: (){
            context.push('/SettlementManagementPage');
          },
          backgroundColor: basic[6],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SingleSettlement extends ConsumerStatefulWidget {
  final int index;
  const SingleSettlement({Key? key, required this.index}) : super(key: key);

  @override
  ConsumerState<SingleSettlement> createState() => _SingleSettlementState();
}

class _SingleSettlementState extends ConsumerState<SingleSettlement> {
  @override
  Widget build(BuildContext context) {
    final editManagement = ref.watch(editManagementProvider);
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap:(){
                if(editManagement.isEdit) {
                  editManagement.toggleSelect(widget.index);
                } else {
                  context.push('/SettlementInformation');
                }
              },
              onLongPress: (){
                if(!editManagement.isEdit) {
                  editManagement.toggleEdit();
                }
                editManagement.toggleSelect(widget.index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size.width * 0.9,
                height: 80,
                margin: EdgeInsets.only(left: editManagement.isEdit ? 80 : 40, right: 40, top:25, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("정산 이름",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5,bottom: 5),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "6명",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ": 참여자 이름, 참여자 이름, 참여자 이름",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: basic[3],
                              ),
                            ),
                          ]
                        )
                      ),
                      ),
                    Text("2024-01-01 화",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: basic[3]
                      ),
                    ),
                  ],
                ),
              ),
            ),
            editManagement.isEdit ?
            Positioned(
              top: 40, left: 20,
              child: Transform.scale(
                scale: 1.6,
                child: Checkbox(
                  value: editManagement.isSelected[widget.index],
                  onChanged: (value){
                    editManagement.toggleSelect(widget.index);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  checkColor: Colors.white,
                  activeColor: basic[6],
                  side: BorderSide(color: basic[1]),
                ),
              ),
            ) :
            const SizedBox.shrink(),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Divider(
            thickness: 2,
          ),
        ),
      ],
    );
  }
}

