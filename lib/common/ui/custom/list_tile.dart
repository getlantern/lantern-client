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
              height: tileHeight,
              child: InkWell(
                onTap: onTap ?? () {},
                child: Ink(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 4.0, end: 16.0),
                        child: leading ?? const SizedBox(),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          child: content,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                        child: trailing,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
