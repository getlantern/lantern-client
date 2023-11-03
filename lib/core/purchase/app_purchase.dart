import 'package:in_app_purchase/in_app_purchase.dart';

import '../../common/common.dart';

class AppPurchase {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> plansSku = [];
  final Set<String> _iosPlansIds = {"1Y",'2Y'};

  void init() {
    getAvailablePlans();
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
  }

  Future<void> getAvailablePlans() async {
    final response = await _inAppPurchase.queryProductDetails(_iosPlansIds);
    plansSku.clear();
    plansSku.addAll(response.productDetails);
  }

  void startPurchase(String planId) {
    final plan = _normalizePlan(planId);
    final purchaseParam = PurchaseParam(productDetails: plan);
    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  ProductDetails _normalizePlan(String planId) {
    ///  We have different ids for IOS, Android And servers
    ///  Convert Server plan to App Store plans
    ///  For ios we are using plans such as 1Y, 2Y, but server plan is 1y-xx-xx
    ///  So we split and compare with lowercase
    final newPlanId = planId.split('-')[0];
    return plansSku.firstWhere(
        (element) => element.id.toLowerCase() == newPlanId.toLowerCase());
  }

  // Internal methods
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    // Handle purchases here
    for (final purchase in purchaseDetailsList) {
      print("purchase $purchase");
      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
    print("purchase error $error");
  }
}
