import 'package:lantern/common/common.dart';

void showInfoDialog(
  BuildContext parentContext, {
  String title = '',
  String des = '',
  String assetPath = '',
  String buttonText = 'OK',
  bool popParentContext = false,
}) {
  showDialog(
    context: parentContext,
    builder: (BuildContext childContext) {
      return AlertDialog(
        contentPadding: const EdgeInsetsDirectional.all(24.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CAssetImage(
                path: assetPath,
              ),
              const SizedBox(
                height: 8,
              ),
              CText(
                title,
                style: tsSubtitle1,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 16,
                    bottom: 24,
                  ),
                  child: CText(
                    des,
                    style: tsBody1Color(unselectedTabIconColor),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  focusColor: grey3,
                  onTap: () {
                    childContext.router.pop();
                    if (popParentContext) parentContext.router.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: CText(
                      buttonText,
                      style: tsButtonPink,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
