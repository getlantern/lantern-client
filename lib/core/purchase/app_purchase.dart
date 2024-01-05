import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lantern/replica/common.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../common/common.dart';

class AppPurchase {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> plansSku = [];
  final Set<String> _iosPlansIds = {"1Y", '2Y'};
  VoidCallback? _onSuccess;
  Function(dynamic error)? _onError;
  String _planId = "";
  String _email = "";

  void init() {
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    getAvailablePlans();
  }

  Future<void> getAvailablePlans() async {
    final response = await _inAppPurchase.queryProductDetails(_iosPlansIds);
    plansSku.clear();
    plansSku.addAll(response.productDetails);
  }

  Future<void> startPurchase({
    required String planId,
    required String email,
    required VoidCallback onSuccess,
    required Function(dynamic error) onFailure,
  }) async {
    _email = email;
    _planId = planId;
    _onSuccess = onSuccess;
    _onError = onFailure;
    final plan = _normalizePlan(planId);
    final purchaseParam = PurchaseParam(productDetails: plan);
    try {
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      logger.e('Error while calling purchase api', error: e);
      Sentry.captureException(e);
      _onError?.call(e);
    } catch (e) {
      logger.e('Payment failed', error: e);
      _onError?.call(e);
    }
  }

  ProductDetails _normalizePlan(String planId) {
    ///  We have different ids for IOS, Android And servers
    ///  Convert Server plan to App Store plans
    ///  For ios we are using plans such as 1Y, 2Y, but server plan is 1y-xx-xx
    ///  So we split and compare with lowercase
    final newPlanId = planId.split('-')[0];
    return plansSku.firstWhere(
      (element) => element.id.toLowerCase() == newPlanId.toLowerCase(),
    );
  }

  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    logger.i("_onPurchaseUpdate called with $purchaseDetailsList");
    for (var purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.canceled) {
      /// if user cancels purchase and then try to purchase again it will get penning transaction errr
      /// To avoid edge case complete purchase
      // User has canceled the purchase
      await _inAppPurchase.completePurchase(purchaseDetails);
      _onError?.call("Purchase canceled");
      return;
    }
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      try {
        await sessionModel.submitApplePlay(
          _email,
          _planId,
          purchaseDetails.verificationData.serverVerificationData,
        );
        _onSuccess?.call();
      } catch (e) {
        logger.e("purchase error", error: e);
        Sentry.captureException(e);
        _onError?.call(e);
      }
    }
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  void _updateStreamOnDone() {
    _onError = null;
    _onSuccess = null;
    _planId = "";
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
    logger.e("purchase error", error: error);
    if (_onError != null) {
      _onError?.call(error);
    }
  }
}
