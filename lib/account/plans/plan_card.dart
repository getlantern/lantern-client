import 'package:lantern/common/common.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CInkWell(
      onTap: () async {
        // TODO: select plan
        // TODO: show next step
        await context.pushRoute(Checkout());
      },
      child: Card(
        shadowColor: grey2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 1,
        child: Container(height: 200, child: Text('card info')),
      ),
    );
  }
}
