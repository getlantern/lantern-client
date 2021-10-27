import 'package:lantern/common/common.dart';

void showSnackbar(
    {required BuildContext context,
    required String content,
    Duration duration = defaultAnimationDuration,
    SnackBarAction? action}) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: CText(
          content,
          style: tsBody1Color(white),
          textAlign: TextAlign.start,
        )),
      ],
    ),
    action: action,
    backgroundColor: black,
    duration: duration,
    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
