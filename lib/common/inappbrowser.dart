import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/plans/utils.dart';

class LanternInAppBrowser extends InAppBrowser {

  final Future<void> Function() _onLoadStop;

  LanternInAppBrowser(this._onLoadStop);

  @override
  Future onBrowserCreated() async {
    print("Browser created");
  }

  @override
  Future onLoadStart(url) async {
    print("Started displaying $url");
  }

  @override
  Future onLoadStop(url) async {
    print("Stopped displaying $url");
    if (this._onLoadStop != null) {
      this._onLoadStop();
    }
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("Browser closed");
  }
}