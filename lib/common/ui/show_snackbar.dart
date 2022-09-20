import 'package:lantern/common/common.dart';

void showSnackbar({
  required BuildContext context,
  required dynamic content,
  Duration duration = defaultAnimationDuration,
  SnackBarAction? action,
}) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: content is String
              ? CText(
                  content,
                  style: tsBody1Color(white),
                  textAlign: TextAlign.start,
                )
              : content,
        ),
      ],
    ),
    action: action,
    backgroundColor: black,
    duration: duration,
    margin: const EdgeInsetsDirectional.all(2),
    padding: const EdgeInsetsDirectional.only(
      top: 12,
      bottom: 12,
      start: 16,
      end: 16,
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
