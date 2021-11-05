import 'package:flutter/material.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/custom/rounded_rectangle_border.dart';

class CustomBottomItem extends StatelessWidget {
  final int currentIndex;
  final int position;
  final int total;
  final CText label;
  final Widget? iconWidget;
  final Widget icon;
  final VoidCallback onTap;

  const CustomBottomItem({
    required this.currentIndex,
    required this.total,
    required this.icon,
    required this.position,
    this.iconWidget,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: CInkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(
                    currentIndex != 0 ? borderRadius : 0,
                  ),
                  topEnd:
                      Radius.circular(currentIndex != total ? borderRadius : 0),
                ),
              ),
              onTap: onTap,
              child: Container(
                decoration: ShapeDecoration(
                  color: position == currentIndex
                      ? selectedTabColor
                      : unselectedTabColor,
                  shape: CRoundedRectangleBorder(
                    topSide: position == currentIndex
                        ? null
                        : BorderSide(
                            color: borderColor,
                            width: 1,
                          ),
                    endSide: currentIndex == position + 1
                        ? BorderSide(
                            color: borderColor,
                            width: 1,
                          )
                        : null,
                    startSide: currentIndex == position - 1
                        ? BorderSide(
                            color: borderColor,
                            width: 1,
                          )
                        : null,
                    topStartCornerSide: BorderSide(
                      color: currentIndex == position - 1
                          ? borderColor
                          : Colors.white,
                    ),
                    topEndCornerSide: BorderSide(
                      color: currentIndex == position + 1
                          ? borderColor
                          : Colors.white,
                    ),
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(
                        currentIndex == position - 1 ? borderRadius : 0,
                      ),
                      topEnd: Radius.circular(
                        currentIndex == position + 1 ? borderRadius : 0,
                      ),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: icon),
                    Flexible(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        label,
                        iconWidget ?? const SizedBox(),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
