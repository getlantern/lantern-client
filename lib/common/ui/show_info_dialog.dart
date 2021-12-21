import 'package:lantern/common/common.dart';

void showInfoDialog(
  BuildContext parentContext, {
  Key? dialogKey,
  dynamic title,
  required dynamic des,
  String? assetPath,
  String? cancelButtonText,
  String confirmButtonText = 'OK',
  Function? confirmButtonAction,
  String? checkboxText,
  Function? confirmCheckboxAction,
}) {
  showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      var checkboxChecked = false;
      return StatefulBuilder(
          builder: (statefulContext, setState) => AlertDialog(
                key: dialogKey,
                contentPadding: const EdgeInsetsDirectional.only(
                    top: 24,
                    bottom: 24,
                    start: 8.0,
                    end:
                        8.0), // the checkbox introduces a stubborn padding on its own, so we are lowering the surrounding padding and bumping up each individual child's horizontal padding values
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
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(bottom: 16.0),
                          child: CAssetImage(
                            path: assetPath,
                          ),
                        ),
                      // * TITLE
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 16.0, end: 16.0),
                        child: Align(
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
                      ),
                      // * DESCRIPTION
                      Padding(
                        padding: const EdgeInsetsDirectional.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 8.0, end: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  checkColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                      side: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(2.0))),
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
                        ),
                      // * BUTTONS
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 16, end: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (cancelButtonText != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  focusColor: grey3,
                                  onTap: () {
                                    context.router.pop();
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
                      ),
                    ],
                  ),
                ),
              ));
    },
  );
}
