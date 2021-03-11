import 'package:flutter/material.dart';
import 'package:lantern/model/model.dart';
import 'package:provider/provider.dart';

import '../i18n/i18n.dart';
import '../model/vpnmodel.dart';

class VPNTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<VPNModel>();
    var observableModel = context.watch<Model>();

    return Scaffold(
      appBar: AppBar(
        title: Text('VPN'.i18n),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Visibility(
            visible: model.dataCap > 0,
            child: Container(
              color: Color.fromARGB(255, 225, 225, 225),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text("Daily Data Usage".i18n,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text("${model.bandwidthUsed}/${model.dataCap}MB",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: model.dataCapUsedPercentage,
                      ),
                    ),
                  ]),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                    scale: 2,
                    child: Switch(
                      value: model.vpnOn,
                      onChanged: (bool newValue) {
                        model.toggle();
                        observableModel.put("/vpnOn", model.vpnOn);
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Lantern".i18n + " " + "is".i18n + " "),
                      Text(
                          model.vpnOn
                              ? "on".i18n.toUpperCase()
                              : "off".i18n.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Visibility(
                        visible: model.vpnOn,
                        child: Row(children: [
                          Text(": " + "Server Location".i18n + " "),
                          Text(model.serverLocation.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
