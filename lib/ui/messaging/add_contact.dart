import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/package_store.dart';

import 'add_contact_by_id.dart';
import 'add_contact_by_qr_code.dart';

class AddContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'Add Contact'.i18n,
      body: DefaultTabController(
        length: 2,
        child: new Scaffold(
            appBar: TabBar(
              tabs: [
                Tab(text: 'Scan QR Code'.i18n.toUpperCase()),
                Tab(text: 'Enter Messenger ID'.i18n.toUpperCase()),
              ],
            ),
            body: TabBarView(children: [
              AddContactByQrCode(),
              AddContactById(),
            ])),
      ),
    );
  }
}
