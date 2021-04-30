import 'package:fluttertoast/fluttertoast.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:lantern/ui/widgets/dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ExchangeTab extends StatefulWidget {
  @override
  _ExchangeTabState createState() {
    return _ExchangeTabState();
  }
}

class _ExchangeTabState extends State<ExchangeTab> {
  final paymentMethodItems = [
    PaymentMethodItem(0, title: 'Online Wallets'.i18n),
    PaymentMethodItem(1, title: 'Bank Transfers'.i18n),
    PaymentMethodItem(2, title: 'Gift Cards'.i18n),
    PaymentMethodItem(3, title: 'Game Cards'.i18n),
    PaymentMethodItem(4, title: 'Cash Payment'.i18n),
    PaymentMethodItem(5, title: 'Digital Currencies'.i18n)
  ];

  final buyItems = [
    BuyItem(0,
        title: 'Bitcoin'.i18n,
        iconPath: ImagePaths.bitcoin_icon,
        buyUrls: {
          0: 'https://paxful.com/s/Paxful_Online_Wallets',
          1: 'https://paxful.com/s/Paxful_Bank_Transfers',
          2: 'https://paxful.com/s/Paxful_Gift_Card',
          3: 'https://paxful.com/s/Paxful_GameCards',
          4: 'https://paxful.com/s/Paxful_Cash_Payment',
          5: 'https://paxful.com/s/Paxful_Digital_Currencies'
        }),
    BuyItem(1,
        title: 'Tether'.i18n,
        iconPath: ImagePaths.tether_icon,
        buyUrls: {
          0: 'https://paxful.com/s/Paxful_Online_Wallets_T1',
          1: 'https://paxful.com/s/Paxful_Bank_TransferT1',
          2: 'https://paxful.com/s/Paxful_Gift_Card_T',
          3: 'https://paxful.com/s/Paxful_Game_Card_T',
          4: 'https://paxful.com/s/Paxful_Cash_Payment_T',
          5: 'https://paxful.com/s/Paxful_Digital_Currencies_T'
        }),
  ];

  late BuyItem? buyItem;
  late PaymentMethodItem? paymentMethodItem;

  @override
  void initState() {
    super.initState();
    buyItem = buyItems.first;
    paymentMethodItem = paymentMethodItems.first;
  }

  void setBuyItem(BuyItem? item) {
    setState(() {
      buyItem = item;
    });
  }

  void setPaymentMethodItem(PaymentMethodItem? item) {
    setState(() {
      paymentMethodItem = item;
    });
  }

  void launchPaxful() async {
    var url = buyItem?.buyUrls[paymentMethodItem?.id ?? -1];
    if (url == null) {
      return;
    }
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false);
    } else {
      showToast('Could not launch $url');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: HexColor(indicatorRed),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'Exchange'.i18n,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('In partnership with'.i18n),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const CustomAssetImage(
                      path: ImagePaths.paxful_logo,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: DropDown(
                      title: 'Buy'.i18n,
                      onChanged: setBuyItem,
                      selected: buyItem,
                      items: buyItems,
                    ),
                  ),
                  Flexible(
                    child: CustomDivider(
                      label: 'With'.i18n,
                      horizontalMargin: 0,
                    ),
                  ),
                  DropDown<PaymentMethodItem>(
                      title: 'Payment Method'.i18n,
                      onChanged: setPaymentMethodItem,
                      selected: paymentMethodItem,
                      items: paymentMethodItems),
                  const Spacer(),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Button(
                        text: 'SHOW BEST DEALS'.i18n,
                        iconPath: ImagePaths.open_in_new_icon,
                        onPressed: buyItem == null || paymentMethodItem == null
                            ? null
                            : launchPaxful,
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}

class BuyItem extends DropDownItem<int> {
  late final Map<int, String> buyUrls;

  BuyItem(int id,
      {required String title, required String iconPath, required this.buyUrls})
      : super(id: id, title: title, iconPath: iconPath);
}

class PaymentMethodItem extends DropDownItem<int> {
  PaymentMethodItem(int id, {required String title})
      : super(id: id, title: title);
}
