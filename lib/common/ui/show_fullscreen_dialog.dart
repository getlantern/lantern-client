import 'package:lantern/common/common.dart';

Widget showFullscreenDialog({
  Color? topColor,
  Color? iconColor,
  required BuildContext context,
  Widget? title,
  Widget? backButton,
  Function? onBackCallback,
  Function? onCloseCallback,
  required Widget child,
}) {
  return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
            color: topColor,
            height: 100,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (backButton != null)
                  Container(
                    padding: const EdgeInsetsDirectional.only(top: 25),
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: backButton,
                      onPressed: () => onBackCallback!(),
                    ),
                  ),
                Container(
                  padding: const EdgeInsetsDirectional.only(top: 25),
                  alignment: Alignment.center,
                  child: title,
                ),
                if (onCloseCallback != null)
                  Container(
                    padding: const EdgeInsetsDirectional.only(top: 25),
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: iconColor,
                      ),
                      onPressed: () => onCloseCallback(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: child)
        ],
      ));
}
