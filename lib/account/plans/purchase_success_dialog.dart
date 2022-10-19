import 'package:lantern/common/common.dart';

class PurchaseSuccessDialog extends StatelessWidget {
  final String title;
  final String description;

  const PurchaseSuccessDialog({
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.only(
              top: 24,
              bottom: 16,
            ),
            child: CAssetImage(
              path: ImagePaths.lantern_star,
              size: 80,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 24,
              end: 24,
            ),
            child: CText(
              title,
              style: tsSubtitle1Short,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 24,
              end: 24,
              top: 24,
            ),
            child: CText(
              description,
              style: tsBody1.copiedWith(
                color: grey5,
              ),
            ),
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            context.router.popUntilRoot();
          },
          child: CText(
            'Continue'.i18n.toUpperCase(),
            style: tsButtonPink,
          ),
        ),
      ],
    );
  }
}
