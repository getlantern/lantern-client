import 'package:lantern/package_store.dart';

class DateMarker extends StatelessWidget {
  final String? isDateMarker;

  DateMarker(this.isDateMarker) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: Text(isDateMarker!.i18n.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.white)),
    );
  }
}
