import 'package:flutter/cupertino.dart';
import 'package:lantern/common/common.dart';

import 'account.dart';

class AccountTab extends StatelessWidget {
  final bool platinumAvailable;
  final bool isPlatinum;

  AccountTab(
      {Key? key, required this.platinumAvailable, required this.isPlatinum})
      : super(key: key);

  @override
  Widget build(BuildContext context) => AccountMenu(
        platinumAvailable: platinumAvailable,
        isPlatinum: isPlatinum,
      );
}
