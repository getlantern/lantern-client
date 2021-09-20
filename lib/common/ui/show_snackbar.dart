import 'package:lantern/common/common.dart';

void showSnackbar(
    {required BuildContext context,
    required Widget content,
    Duration duration = const Duration(milliseconds: 1000),
    SnackBarAction? action}) {
  final snackBar = SnackBar(
    content: content,
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
