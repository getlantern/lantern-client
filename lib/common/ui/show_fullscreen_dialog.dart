import 'package:lantern/common/common.dart';

Widget showFullscreenDialog(
    {required Color topColor,
    required Color iconColor,
    required BuildContext context,
    required Widget title,
    Widget? backButton,
    Function? onBackCallback,
    required Function onCloseCallback,
    required Widget child}) {
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
