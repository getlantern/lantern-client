import 'package:lantern/common/common.dart';

class PaymentProviderButton extends StatelessWidget {
  final List<String> logoPaths;
  final Function onChanged;
  final String selectedPaymentProvider;
  final String paymentType;

  const PaymentProviderButton({
    Key? key,
    required this.logoPaths,
    required this.onChanged,
    required this.selectedPaymentProvider,
    required this.paymentType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 200,
      margin: const EdgeInsetsDirectional.only(bottom: 16),
      child: OutlinedButton(
        onPressed: () => onChanged(),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              selectedPaymentProvider == paymentType ? pink1 : white,
          side: BorderSide(
            width: 2.0,
            color: selectedPaymentProvider == paymentType ? pink4 : grey3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...logoPaths.map((p) => buildLogoIcon(path: p)),
            Transform.scale(
              scale: 0.9,
              child: Radio(
                value: selectedPaymentProvider == paymentType,
                groupValue: true,
                activeColor: black,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) =>
                      selectedPaymentProvider == paymentType ? black : grey3,
                ),
                onChanged: (value) async => onChanged(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildLogoIcon({required String path}) => Container(
      width: 55,
      height: 40,
      padding: const EdgeInsetsDirectional.only(
        start: 10.0,
        end: 10.0,
        top: 10.0,
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border(
          top: BorderSide(
            width: 1.0,
            color: grey2,
          ),
          left: BorderSide(
            width: 1.0,
            color: grey2,
          ),
          right: BorderSide(
            width: 1.0,
            color: grey2,
          ),
          bottom: BorderSide(
            width: 1.0,
            color: grey2,
          ),
        ),
      ),
      child: CAssetImage(
        path: path,
      ),
    );
