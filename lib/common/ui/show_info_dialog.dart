import 'package:lantern/common/common.dart';

void showInfoDialog(BuildContext context,
    {String title = '',
    String des = '',
    String icon = '',
    String buttonText = 'OK'}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsetsDirectional.only(
            start: 20, end: 20, top: 20, bottom: 12),
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
                path: icon,
                size: 24,
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
                  child: CTextWrap(
                    des,
                    style: tsBody1Color(unselectedTabLabelColor),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Ink(
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
