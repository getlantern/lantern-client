import 'package:lantern/common/common.dart';

class PlanStep extends StatelessWidget {
  final String stepNum;
  final String description;

  const PlanStep({
    Key? key,
    required this.stepNum,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.only(
            start: 12.0,
            top: 0,
            end: 12.0,
            bottom: 2.0,
          ),
          decoration: BoxDecoration(
            color: black,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: CText(
            'Step $stepNum'.i18n,
            style: tsBody1.copiedWith(color: white),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8.0),
          child: CText(description, style: tsBody1),
        )
      ],
    );
  }
}
