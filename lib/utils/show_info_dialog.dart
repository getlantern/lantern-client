import 'package:lantern/package_store.dart';

void showInfoDialog(BuildContext context,
    {String title = '', String des = '', String icon = ''}) {
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
              CustomAssetImage(
                path: icon,
                size: 24,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                title,
                style: GoogleFonts.roboto().copyWith(fontSize: 16),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 16,
                    bottom: 24,
                  ),
                  child: Text(
                    des,
                    style: GoogleFonts.roboto().copyWith(
                      fontSize: 14,
                      height: 23 / 14,
                      color: unselectedTabLabelColor,
                    ),
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
                    child: Text(
                      'OK'.i18n,
                      style: GoogleFonts.roboto().copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryPink,
                      ),
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
