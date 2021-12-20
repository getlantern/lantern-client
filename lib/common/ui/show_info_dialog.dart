import 'package:lantern/common/common.dart';

void showInfoDialog(
  BuildContext parentContext, {
  Key? dialogKey,
  dynamic title,
  required dynamic des,
  String? assetPath,
  bool popParentContext = false,
  String? cancelButtonText,
  String confirmButtonText = 'OK',
  Function? confirmButtonAction,
  String? checkboxText,
  Function? confirmCheckboxAction,
}) {
  showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (BuildContext childContext) {
      var checkboxChecked = false;
      return StatefulBuilder(
          builder: (statefulContext, setState) => AlertDialog(
                key: dialogKey,
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
                      // * IMAGE
                      if (assetPath != null)
                        CAssetImage(
                          path: assetPath,
                        ),
                      // * TITLE
                      Align(
                        alignment: assetPath == ''
                            ? Alignment.centerLeft
                            : Alignment.center,
                        child: (title is String)
                            ? CText(
                                title,
                                style: tsSubtitle1,
                              )
                            : title,
                      ),
                      // * DESCRIPTION
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: 16,
                            bottom: 24,
                          ),
                          child: (des is String)
                              ? CText(
                                  des,
                                  style: tsBody1Color(unselectedTabIconColor),
                                )
                              : des,
                        ),
                      ),
                      // * CHECKBOX
                      if (checkboxText != null)
                        Row(
                          children: [
                            Checkbox(
                                checkColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2.0))),
                                fillColor: MaterialStateProperty.resolveWith(
                                    (states) =>
                                        getCheckboxFillColor(black, states)),
                                value: checkboxChecked,
                                onChanged: (bool? value) {
                                  setState(() => checkboxChecked = value!);
                                }),
                            Expanded(
                              child: CText(checkboxText, style: tsBody1),
                            )
                          ],
                        ),
                      // * BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (cancelButtonText != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                focusColor: grey3,
                                onTap: () {
                                  childContext.router.pop();
                                  if (popParentContext) {
                                    parentContext.router.pop();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsetsDirectional.all(8),
                                  child: CText(
                                    cancelButtonText.toUpperCase(),
                                    style: tsButtonGrey,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              focusColor: grey3,
                              onTap: () {
                                if (popParentContext) {
                                  parentContext.router.pop();
                                }
                                if (confirmButtonAction != null) {
                                  confirmButtonAction();
                                }
                                if (checkboxChecked) confirmCheckboxAction!();
                              },
                              child: Container(
                                padding: const EdgeInsetsDirectional.all(8),
                                child: CText(confirmButtonText.toUpperCase(),
                                    style: checkboxText == null
                                        ? tsButtonPink
                                        : checkboxChecked
                                            ? tsButtonPink
                                            : tsButtonGrey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
    },
  );
}
