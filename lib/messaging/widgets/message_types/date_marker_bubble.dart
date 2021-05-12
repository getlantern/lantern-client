import 'package:lantern/package_store.dart';
import 'package:intl/intl.dart';

class DateMarker extends StatelessWidget {
  final date = DateFormat.yMMMMd('en_US')
      .format(DateTime.now())
      .split(',')[0]
      .toString();

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: Text(date, // TODO: Add i18n
              style: const TextStyle(fontSize: 10, color: Colors.white)),
        ));
  }
}
