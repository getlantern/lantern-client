import 'package:lantern/common/common.dart';

enum Providers { stripe, btcpay, freekassa }

class PaymentProvider extends StatelessWidget {
  final List<String> logoPaths;
  final Function onChanged;
  final Providers selectedPaymentProvider;
  final Providers paymentType;

  const PaymentProvider({
    Key? key,
    required this.logoPaths,
    required this.onChanged,
    required this.selectedPaymentProvider,
    required this.paymentType,
  }) : super(key: key);

  BorderSide borderSide() => BorderSide(
        width: 1.0,
        color: grey2,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsetsDirectional.only(bottom: 16),
      child: OutlinedButton(
        onPressed: () => onChanged(),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              selectedPaymentProvider == paymentType ? pink1 : white,
          side: BorderSide(
            width: selectedPaymentProvider == paymentType ? 2.0 : 1.0,
            color: selectedPaymentProvider == paymentType ? pink4 : grey3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...logoPaths.map(
              (p) => Container(
                width: 47,
                height: 32,
                margin: const EdgeInsetsDirectional.only(
                  end: 8,
                ),
                padding: const EdgeInsetsDirectional.only(
                  start: 8.0,
                  end: 8.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border(
                    top: borderSide(),
                    left: borderSide(),
                    right: borderSide(),
                    bottom: borderSide(),
                  ),
                ),
                child: CAssetImage(
                  path: p,
                ),
              ),
            ),
            Radio(
              value: selectedPaymentProvider == paymentType,
              groupValue: true,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              activeColor: black,
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (states) =>
                    selectedPaymentProvider == paymentType ? black : grey3,
              ),
              onChanged: (value) async => onChanged(),
            ),
          ],
        ),
      ),
    );
  }
}
