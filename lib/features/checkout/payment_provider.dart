import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/utils.dart';
import 'package:http/http.dart' as http;

class PaymentIconRow extends StatelessWidget {
  final List<String> defaultAssets;
  final List<String>? networkIconUrls;
  final double iconSize;
  final double spacing;
  final bool useNetwork;

  const PaymentIconRow({
    super.key,
    required this.defaultAssets,
    this.networkIconUrls,
    this.iconSize = 40,
    this.spacing = 8,
    this.useNetwork = false,
  });

  static final Map<String, Future<bool>> _cache = {};

  Future<bool> _canLoad(String url) {
    return _cache[url] ??= _checkUrl(url);
  }

  Future<bool> _checkUrl(String url) async {
    try {
      final response =
          await http.head(Uri.parse(url)).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(defaultAssets.length, (i) {
        final defaultAsset = defaultAssets[i];
        final networkUrl =
            (networkIconUrls != null && i < networkIconUrls!.length)
                ? networkIconUrls![i]
                : null;
        Widget icon;

        if (useNetwork && networkUrl != null) {
          icon = FutureBuilder<bool>(
            future: _canLoad(networkUrl),
            builder: (context, snapshot) {
              final shouldUseNetwork =
                  snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == true;

              return shouldUseNetwork
                  ? SvgPicture.network(
                      networkUrl,
                      height: iconSize,
                      width: iconSize,
                      fit: BoxFit.contain,
                    )
                  : SvgPicture.asset(
                      defaultAsset,
                      height: iconSize,
                      width: iconSize,
                      fit: BoxFit.contain,
                    );
            },
          );
        } else {
          icon = SvgPicture.asset(
            defaultAsset,
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          );
        }

        return Container(
          width: iconSize + spacing * 2,
          height: iconSize + spacing * 2,
          margin: EdgeInsets.only(
            right: i < defaultAssets.length - 1 ? spacing : 0,
          ),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: icon,
        );
      }),
    );
  }
}

class PaymentProviderOption extends StatelessWidget {
  final Providers paymentType;
  final Providers? selectedPaymentProvider;
  final VoidCallback onChanged;
  final List<String> defaultLogoPaths;
  final List<String>? networkIconUrls;
  final bool useNetwork;

  const PaymentProviderOption({
    super.key,
    required this.paymentType,
    required this.selectedPaymentProvider,
    required this.onChanged,
    required this.defaultLogoPaths,
    this.networkIconUrls,
    this.useNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPaymentProvider == paymentType;

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 16),
      child: IntrinsicWidth(
        child: OutlinedButton(
          onPressed: onChanged,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: isSelected ? pink1 : white,
            side: BorderSide(
              width: isSelected ? 2.0 : 1.0,
              color: isSelected ? pink4 : grey3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaymentIconRow(
                useNetwork: useNetwork,
                defaultAssets: defaultLogoPaths,
                networkIconUrls: networkIconUrls,
                iconSize: 40,
                spacing: 8,
              ),
              const SizedBox(width: 12),
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
                activeColor: black,
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (_) => isSelected ? black : grey3,
                ),
                onChanged: (_) => onChanged(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<PaymentProviderOption> buildPaymentProviders({
  required PaymentMethod paymentMethods,
  required Providers selectedProvider,
  required void Function(Providers) onSelected,
  bool useNetwork = false,
}) {
  var providers = <PaymentProviderOption>[];
  for (final provider in paymentMethods.providers) {
    final providerEnum = provider.name.toPaymentEnum();
    final defaultAssets = switch (providerEnum) {
      Providers.stripe => const [
          ImagePaths.visa,
          ImagePaths.mastercard,
          ImagePaths.unionpay,
        ],
      Providers.shepherd => const [ImagePaths.alipay],
      _ => throw UnimplementedError(),
    };

    providers.add(
      PaymentProviderOption(
        defaultLogoPaths: defaultAssets,
        networkIconUrls: provider.logoUrls,
        useNetwork: useNetwork,
        paymentType: provider.name.toPaymentEnum(),
        onChanged: () => onSelected(providerEnum),
        selectedPaymentProvider: selectedProvider!,
      ),
    );
  }
  return providers;
}
