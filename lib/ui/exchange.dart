import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:lantern/package_store.dart';
import 'package:url_launcher/url_launcher.dart';

int buy = 1;
int method = 1;

class ExchangeTab extends StatefulWidget {
  ExchangeTab({Key? key}) : super(key: key);

  @override
  _ExchangeTabState createState() => _ExchangeTabState();
}

class _ExchangeTabState extends State<ExchangeTab> {
  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false);
    } else {
      showToast('Could not launch $url');
    }
  }

  showToast(String message) {
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
          padding: EdgeInsets.all(16),
          child: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('In partnership with'.i18n),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: CustomAssetImage(
                      path: ImagePaths.paxful_logo,
                    ),
                  ),
                  Stack(children: [
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 40),
                      padding: EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: HexColor(gray4), width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        // decoration: BoxDecoration(
                        //   color: Colors.red,
                        // ),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: BuyDropDownWidget(<BuyModel>[
                          BuyModel(1, 'Bitcoin', ImagePaths.bitcoin_icon),
                          BuyModel(2, 'Tether', ImagePaths.tether_icon)
                        ]),
                      ),
                    ),
                    Positioned(
                        left: 42,
                        top: 33.5,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          color: Colors.white,
                          child: Text(
                            'Buy'.i18n,
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        )),
                  ]),
                  Stack(alignment: Alignment.center, children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 10),
                      child: Divider(
                        color: HexColor(gray4),
                      ),
                    ),
                    Positioned(
                        top: 20,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          color: Colors.white,
                          child: Text(
                            'With'.i18n,
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        )),
                  ]),
                  Stack(children: [
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                      padding: EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: HexColor(gray4), width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        // decoration: BoxDecoration(
                        //   color: Colors.red,
                        // ),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: MethodDropDownWidget(<MethodModel>[
                          MethodModel(1, 'Online Wallets'.i18n),
                          MethodModel(2, 'Bank Transfers'.i18n),
                          MethodModel(3, 'Gift Cards'.i18n),
                          MethodModel(4, 'Game Cards'.i18n),
                          MethodModel(5, 'Cash Payment'.i18n),
                          MethodModel(6, 'Digital Currencies'.i18n),
                        ]),
                      ),
                    ),
                    Positioned(
                        left: 42,
                        top: 3.5,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          color: Colors.white,
                          child: Text(
                            'Payment Method'.i18n,
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        )),
                  ]),
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin:
                              EdgeInsets.only(left: 70, right: 70, bottom: 20),
                          child: TextButton(
                            onPressed: () {
                              launchURL(getUrl(buy * 10 + method) ?? '');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SHOW BEST DEALS'.i18n,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 5),
                                CustomAssetImage(
                                  path: ImagePaths.open_in_new_icon,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    EdgeInsets.only(top: 15, bottom: 15)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        HexColor(primaryPink))),
                          ),
                        )),
                  ),
                ],
              )),
        ));
  }
}

class BuyModel {
  int id;
  String name;
  String icon;

  BuyModel(this.id, this.name, this.icon);

  @override
  bool operator ==(Object other) {
    return other != null && other is BuyModel && other.id == this.id;
  }
}

class BuyDropDownWidget extends StatefulWidget {
  final List<BuyModel> items;

  BuyDropDownWidget(this.items) : super();

  @override
  _BuyDropDownWidgetState createState() => _BuyDropDownWidgetState();
}

class _BuyDropDownWidgetState extends State<BuyDropDownWidget> {
  late BuyModel currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.items.first;
    buy = currentValue.id;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<BuyModel>(
      itemHeight: 56,
      value: currentValue,
      icon: const CustomAssetImage(
        path: ImagePaths.dropdown_icon,
      ),
      iconSize: 24,
      elevation: 16,
      isExpanded: true,
      style: const TextStyle(color: Colors.black, fontSize: 15),
      underline: Container(
        height: 0,
      ),
      onChanged: (BuyModel? newValue) {
        if(newValue == null) return;
        setState(() {
          currentValue = newValue;
          buy = newValue.id;
        });
      },
      items: widget.items.map<DropdownMenuItem<BuyModel>>((BuyModel value) {
        return DropdownMenuItem<BuyModel>(
          value: value,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 0, right: 0),
            leading: CustomAssetImage(
              path: value.icon,
            ),
            minLeadingWidth: 0,
            title: Text(value.name),
          ),
        );
      }).toList(),
    );
  }
}

class MethodModel {
  int id;
  String name;

  MethodModel(this.id, this.name);

  @override
  bool operator ==(Object other) {
    return other != null && other is MethodModel && other.id == this.id;
  }
}

class MethodDropDownWidget extends StatefulWidget {
  final List<MethodModel> items;

  const MethodDropDownWidget(this.items) : super();

  @override
  _MethodDropDownWidgetState createState() => _MethodDropDownWidgetState();
}

class _MethodDropDownWidgetState extends State<MethodDropDownWidget> {
  late MethodModel currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.items.first;
    method = currentValue.id;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<MethodModel>(
      itemHeight: 56,
      value: currentValue,
      icon: const CustomAssetImage(
        path: ImagePaths.dropdown_icon,
      ),
      iconSize: 24,
      elevation: 16,
      isExpanded: true,
      style: const TextStyle(color: Colors.black, fontSize: 15),
      underline: Container(
        height: 0,
      ),
      onChanged: (MethodModel? newValue) {
        if(newValue == null) return;
        setState(() {
          currentValue = newValue;
          method = newValue.id;
        });
      },
      items:
          widget.items.map<DropdownMenuItem<MethodModel>>((MethodModel value) {
        return DropdownMenuItem<MethodModel>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
