import 'package:flutter/cupertino.dart';
import 'package:lantern/common/common.dart';

import 'account.dart';

class AccountTab extends StatelessWidget {
  final bool isCN;
  final bool isPlatinum;

  AccountTab({Key? key, required this.isCN, required this.isPlatinum})
      : super(key: key);

  @override
  Widget build(BuildContext context) => AccountMenu(
        isCN: isCN,
        isPlatinum: isPlatinum,
      );
}
