import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/exchange_buy_dropdown.dart';
import 'package:lantern/ui/widgets/exchange_payment_method_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ExchangeTab extends StatelessWidget {
  int buyItem = 1;
  int methodItem = 1;

  void _setBuyItem(int value) {
    buyItem = value;
  }

  void _setMethodItem(int value) {
    methodItem = value;
  }

  void launchURL(String url) async {
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
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  String? getUrl(int id) {
    switch (id) {
      case 11:
        return 'https://paxful.com/s/Paxful_Online_Wallets';
      case 12:
        return 'https://paxful.com/s/Paxful_Bank_Transfers';
      case 13:
        return 'https://paxful.com/s/Paxful_Gift_Card';
      case 14:
        return 'https://paxful.com/s/Paxful_GameCards';
      case 15:
        return 'https://paxful.com/s/Paxful_Cash_Payment';
      case 16:
        return 'https://paxful.com/s/Paxful_Digital_Currencies';
      case 21:
        return 'https://paxful.com/s/Paxful_Online_Wallets_T1';
      case 22:
        return 'https://paxful.com/s/Paxful_Bank_TransferT1';
      case 23:
        return 'https://paxful.com/s/Paxful_Gift_Card_T';
      case 24:
        return 'https://paxful.com/s/Paxful_Game_Card_T';
      case 25:
        return 'https://paxful.com/s/Paxful_Cash_Payment_T';
      case 26:
        return 'https://paxful.com/s/Paxful_Digital_Currencies_T';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'Exchange'.i18n,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
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
                  Stack(children: [
                    Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 40),
                      padding: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: HexColor(gray4), width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        // decoration: BoxDecoration(
                        //   color: Colors.red,
                        // ),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: BuyDropDownWidget(<BuyModel>[
                          BuyModel(1, 'Bitcoin', ImagePaths.bitcoin_icon),
                          BuyModel(2, 'Tether', ImagePaths.tether_icon)
                        ], _setBuyItem),
                      ),
                    ),
                    Positioned(
                        left: 42,
                        top: 33.5,
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          color: Colors.white,
                          child: Text(
                            'Buy'.i18n,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        )),
                  ]),
                  Stack(alignment: Alignment.center, children: [
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 10),
                      child: Divider(
                        color: HexColor(gray4),
                      ),
                    ),
                    Positioned(
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          color: Colors.white,
                          child: Text(
                            'With'.i18n,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        )),
                  ]),
                  Stack(children: [
                    Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      padding: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: HexColor(gray4), width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        // decoration: BoxDecoration(
                        //   color: Colors.red,
                        // ),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: MethodDropDownWidget(<MethodModel>[
                          MethodModel(1, 'Online Wallets'.i18n),
                          MethodModel(2, 'Bank Transfers'.i18n),
                          MethodModel(3, 'Gift Cards'.i18n),
                          MethodModel(4, 'Game Cards'.i18n),
                          MethodModel(5, 'Cash Payment'.i18n),
                          MethodModel(6, 'Digital Currencies'.i18n),
                        ], _setMethodItem),
                      ),
                    ),
                    Positioned(
                        left: 42,
                        top: 3.5,
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          color: Colors.white,
                          child: Text(
                            'Payment Method'.i18n,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        )),
                  ]),
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 70, right: 70, bottom: 20),
                          child: TextButton(
                            onPressed: () {
                              // buyDropDownWidget
                              launchURL(
                                  getUrl(buyItem * 10 + methodItem) ?? '');
                            },
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.only(top: 15, bottom: 15)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        HexColor(primaryPink))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SHOW BEST DEALS'.i18n,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(width: 5),
                                const CustomAssetImage(
                                  path: ImagePaths.open_in_new_icon,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              )),
        ));
  }
}
