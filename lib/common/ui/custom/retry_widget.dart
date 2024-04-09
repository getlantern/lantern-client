import '../../common.dart';

class RetryWidget extends StatelessWidget {
  final VoidCallback onRetryTap;

  const RetryWidget({
    super.key,
    required this.onRetryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: mirrorLTR(
                    context: context,
                    child: CAssetImage(
                      path: ImagePaths.cancel,
                      color: black,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                CAssetImage(
                  path: ImagePaths.error_outline,
                  size: 100,
                  color: grey4,
                ),
                const SizedBox(height: 24.0),
                CText('a_temporary_error_occurred'.i18n, style: tsHeading1),
                const SizedBox(height: 8.0),
                CText(
                  'sorry_we_are_unable_to_load_that_page'.i18n,
                  style: tsBody1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Button(
            text: "refresh".i18n,
            onPressed: onRetryTap,
          ),
        ],
      ),
    );
  }
}
