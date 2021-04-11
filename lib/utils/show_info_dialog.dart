import 'package:lantern/package_store.dart';

showInfoDialog(BuildContext context, {String title = '', String des = '', String icon}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 12),
        shape: RoundedRectangleBorder(
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
              SizedBox(
                height: 8,
              ),
              Text(
                title,
                style: GoogleFonts.roboto().copyWith(fontSize: 16),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 24,
                  ),
                  child: Text(
                    des,
                    style: GoogleFonts.roboto().copyWith(
                      fontSize: 14,
                      height: 23 / 14,
                      color: HexColor(unselectedTabLabelColor),
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
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "OK".i18n,
                      style: GoogleFonts.roboto().copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: HexColor(primaryPink),
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
