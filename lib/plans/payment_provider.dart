import 'package:lantern/common/common.dart';
import 'package:lantern/plans/utils.dart';

class PaymentProvider extends StatelessWidget {
  final List<String> logoPaths;
  final Function onChanged;
  final Providers selectedPaymentProvider;
  final Providers paymentType;
  final bool useNetwork;

  const PaymentProvider({
    Key? key,
    required this.logoPaths,
    required this.onChanged,
    required this.selectedPaymentProvider,
    required this.paymentType,
    this.useNetwork = false,
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
              (p) => Flexible(
                  child: Container(
                margin: const EdgeInsetsDirectional.only(
                  end: 8,
                ),
                padding: EdgeInsetsDirectional.all(isDesktop() ? 3.0 : 8.0),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: useNetwork
                    ? SvgPicture.network(p)
                    : CAssetImage(
                        path: p,
                      ),
              )),
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
