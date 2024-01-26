import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';

final bottomSheetProvider =
    ChangeNotifierProvider((ref) => BottomSheetViewModel());

class BottomSheetViewModel extends ChangeNotifier {
  int mode = -1;
  double height = 0;
  double maxHeight = 0;
  double midHeight = 0;

  void setHeight(double maxHeight, double midHeight) {
    mode = 0;
    this.maxHeight = maxHeight;
    this.midHeight = midHeight;
    height = this.midHeight;
  }

  void changeMode(int index) {
    mode = index;
    notifyListeners();
  }

  void changeHeight(double dy) {
    double newHeight = height - dy;
    if (midHeight <= newHeight && newHeight <= maxHeight) {
      height = newHeight;
    }
    notifyListeners();
  }

  void dragEnd(double dy) {
    if (dy > 10) {
      height = midHeight;
    } else if (dy < -10) {
      height = maxHeight;
    } else {
      if ((height - midHeight).abs() < (height - maxHeight).abs()) {
        height = midHeight;
      } else {
        height = maxHeight;
      }
    }
    notifyListeners();
  }
}

class CustomBottomSheet extends ConsumerWidget {
  const CustomBottomSheet({super.key, required this.childWidget});
  final Widget childWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bprovider = ref.watch(bottomSheetProvider);
    final Size size = MediaQuery.of(context).size;
    if (bprovider.mode == -1) {
      ref
          .read(bottomSheetProvider)
          .setHeight(size.height * 0.8 - 100, size.height * 0.8 - 300);
    }
    return Positioned(
      bottom: 100,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          bprovider.changeHeight(details.delta.dy);
        },
        onVerticalDragStart: (details) {
          bprovider.changeMode(1);
        },
        onVerticalDragEnd: (details) {
          bprovider.changeMode(0);
          bprovider.dragEnd(details.velocity.pixelsPerSecond.dy);
        },
        onVerticalDragCancel: () {
          bprovider.changeMode(0);
          bprovider.dragEnd(0);
        },
        child: AnimatedContainer(
          duration: bprovider.mode == 0
              ? const Duration(milliseconds: 100)
              : const Duration(milliseconds: 0),
          height: bprovider.height,
          width: size.width,
          padding: const EdgeInsets.only(top: 17),
          decoration: BoxDecoration(
              color: basic[0],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: childWidget,
        ),
      ),
    );
  }
}
