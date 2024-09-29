import '../../../core/utils/common.dart';

class EmailTag extends StatelessWidget {
  final String email;

  const EmailTag({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: grey1,
        border: Border.all(
          width: 1,
          color: grey3,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(
            ImagePaths.email,
          ),
          const SizedBox(width: 8),
          CText(email,
              textAlign: TextAlign.center,
              style: tsBody1!.copiedWith(
                leadingDistribution: TextLeadingDistribution.even,
              ))
        ],
      ),
    );
  }
}
