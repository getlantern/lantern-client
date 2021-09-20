import 'package:lantern/messaging/messaging.dart';

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
      child: CText(isDateMarker!.i18n.toUpperCase(), style: tsOverline),
    );
  }
}
