// ignore_for_file: use_build_context_synchronously

import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/plans/tos.dart';
import 'package:lantern/plans/utils.dart';

class ResellerCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue value,
  ) {
    final newValue = value.text;
    var formattedValue = '';

    for (var i = 0; i < newValue.length; i++) {
      if (newValue[i] != '-') formattedValue += newValue[i];
      var index = i + 1;
      var dashIndex = index == 5 || index == 11 || index == 17 || index == 23;
      if (dashIndex &&
          index != newValue.length &&
          !(formattedValue.endsWith('-'))) {
        formattedValue += '-';
      }
    }
    return value.copyWith(
      text: formattedValue,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formattedValue.length),
      ),
    );
  }
}

@RoutePage(name: "ResellerCodeCheckout")
class ResellerCodeCheckout extends StatefulWidget {
  final bool isPro;
  final String email;

  ///This otp is needed to while resting password
  /// If otp is null it means user is pro
  /// if otp is not null it means user is not pro send them to password screen
  final String? otp;

  const ResellerCodeCheckout({
    required this.isPro,
    required this.email,
    this.otp,
    Key? key,
  }) : super(key: key);

  @override
  State<ResellerCodeCheckout> createState() => _ResellerCodeCheckoutState();
}

class _ResellerCodeCheckoutState extends State<ResellerCodeCheckout> {
  final resellerCodeFieldKey = GlobalKey<FormState>();
  late final resellerCodeController = CustomTextEditingController(
    formKey: resellerCodeFieldKey,
    validator: (value) => value != null &&
            // only allow letters, numbers and hyphens as well as length excluding dashes should be exactly 25 characters
            // TODO: reject our own referral code
            RegExp(r'^[a-zA-Z0-9-]*$').hasMatch(value) &&
            value.replaceAll('-', '').length == 25
        ? null
        : 'your_activation_code_is_invalid'.i18n,
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      title: const AppBarProHeader(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              HeadingText(
                title: 'enter_activation_code'.i18n,
              ),
              const SizedBox(height: 24),
              _buildEmail(),
              const SizedBox(height: 24),
              Form(
                key: resellerCodeFieldKey,
                child: CTextField(
                  maxLength: 25 + 4,
                  //accounting for dashes
                  controller: resellerCodeController,
                  autovalidateMode: AutovalidateMode.disabled,
                  inputFormatters: [ResellerCodeFormatter()],
                  label: 'Activation Code'.i18n,
                  keyboardType: TextInputType.text,
                  prefixIcon: const CAssetImage(path: ImagePaths.dots),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Button(
                  primary: true,
                  disabled:
                      resellerCodeFieldKey.currentState?.validate() == false,
                  text: 'continue'.i18n,
                  onPressed: onRegisterPro,
                ),
              ),
              const SizedBox(height: 24),
              const TOS(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onRegisterPro() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      context.loaderOverlay.show();
      Locale locale = Localizations.localeOf(context);
      final format = NumberFormat.simpleCurrency(locale: locale.toString());
      final currencyName = format.currencyName ?? "USD";

      await sessionModel.redeemResellerCode(
        widget.email,
        currencyName,
        Platform.operatingSystem,
        resellerCodeController.text,
      );
      context.loaderOverlay.hide();
      if (!widget.isPro) {
        // it mean user is coming from signup flow
        openPassword();
      } else {
        showSuccessDialog(context, widget.isPro,
            isReseller: true, barrierDismissible: false);
      }
    } catch (error, stackTrace) {
      appLogger.e(error, stackTrace: stackTrace);
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: error,
        stackTrace: stackTrace,
        description: error.localizedDescription // This is coming localized
      );
    }
  }

  Widget _buildEmail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: grey1,
        border: Border.all(
          width: 1,
          color: grey3,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(
            ImagePaths.email,
          ),
          const SizedBox(width: 8),
          CText(widget.email,
              textAlign: TextAlign.center,
              style: tsBody1!.copiedWith(
                leadingDistribution: TextLeadingDistribution.even,
              ))
        ],
      ),
    );
  }

  void openPassword() {
    context.pushRoute(CreateAccountPassword(
      email: widget.email.validateEmail,
      code: widget.otp!,
    ));
  }
}
