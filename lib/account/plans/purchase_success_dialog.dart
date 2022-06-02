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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.only(
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
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 24,
                end: 24,
                top: 16,
              ),
              child: CText(
                description,
                style: tsBody1.copiedWith(
                  color: grey5,
                ),
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
