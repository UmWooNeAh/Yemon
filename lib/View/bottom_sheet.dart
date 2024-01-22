import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';

final bottomSheetProvider =
    ChangeNotifierProvider((ref) => BottomSheetViewModel());

class BottomSheetViewModel extends ChangeNotifier {
  int mode = 0;
  double height = 0;

  void changeMode(int index) {
    mode = index;
    notifyListeners();
  }


}

class CustomBottomSheet extends ConsumerWidget {
  const CustomBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bprovider = ref.watch(bottomSheetProvider);
    final Size size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 100 + bprovider.height,
          width: size.width,
          decoration: BoxDecoration(
              color: basic[0],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
        ),
      ),
    );
  }
}
