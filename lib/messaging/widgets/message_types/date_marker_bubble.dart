import 'package:lantern/package_store.dart';

class DateMarker extends StatelessWidget {
  final String? isDateMarker;

  DateMarker(this.isDateMarker) : super();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(),
          child: Container(
            width: 100,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Text(isDateMarker!, // TODO: Add i18n
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ))
    ]);
  }
}
