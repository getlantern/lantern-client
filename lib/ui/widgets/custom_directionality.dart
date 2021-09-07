import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class CustomDirectionality extends StatefulWidget {
  final Widget child;

  CustomDirectionality({Key? key, required this.child}) : super(key: key);

  @override
  _CustomDirectionalityState createState() => _CustomDirectionalityState();
}

class _CustomDirectionalityState extends State<CustomDirectionality> {
  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: isRtlLanguage() ? TextDirection.rtl : TextDirection.ltr,
      child: widget.child);

  bool isRtlLanguage() =>
      intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);

  @override
  void didUpdateWidget(CustomDirectionality oldWidget) =>
      super.didUpdateWidget(oldWidget);
}
