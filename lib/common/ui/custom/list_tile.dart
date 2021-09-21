import 'package:lantern/common/common.dart';

class CListTile extends StatelessWidget {
  final Widget? leading;
  final Widget content;
  final Widget trailing;
  final void Function()? onTap;

  CListTile({
    this.leading,
    required this.content,
    required this.trailing,
    this.onTap,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
              height: 72,
              child: InkWell(
                onTap: onTap ?? () {},
                child: Ink(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      leading ?? const SizedBox(),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          child: content,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 16.0, end: 16.0),
                        child: trailing,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
