import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';

class DateMarker extends StatelessWidget {
  final StoredMessage msg;

  const DateMarker(this.msg) : super();

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
          child: Text(msg.ts.toInt().humanizeDate(),
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white)), //TODO: Return [day/date] format
        ));
  }
}
