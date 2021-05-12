import 'package:lantern/package_store.dart';

class NewMessage extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Column innerColumn;

  const NewMessage(this.outbound, this.inbound, this.startOfBlock,
      this.endOfBlock, this.newestMessage, this.innerColumn)
      : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: outbound ? Colors.black38 : Colors.black12,
        borderRadius: BorderRadius.only(
          topLeft:
              inbound && !startOfBlock ? Radius.zero : const Radius.circular(5),
          topRight: outbound && !startOfBlock
              ? Radius.zero
              : const Radius.circular(5),
          bottomRight: outbound && (!endOfBlock || newestMessage)
              ? Radius.zero
              : const Radius.circular(5),
          bottomLeft: inbound && (!endOfBlock || newestMessage)
              ? Radius.zero
              : const Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
        child: innerColumn,
      ),
    );
  }
}
