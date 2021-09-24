import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';

class DateMarker extends StatelessWidget {
  final String? isDateMarker;

  DateMarker(this.isDateMarker) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: black,
                borderRadius: const BorderRadius.all(Radius.circular(100)),
              ),
              child: CText(isDateMarker!.i18n.toUpperCase(),
                  style: tsOverline.copiedWith(color: white).short),
            ),
          ),
        ],
      ),
    );
  }
}
