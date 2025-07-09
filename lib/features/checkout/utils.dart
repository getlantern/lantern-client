// Makes sure that payment URLs for certain providers (like Alipay) are HTTPS
String securePaymentRedirectUrl(String url) {
  if (url.startsWith("http://") && url.contains("alipay")) {
    return url.replaceFirst("http://", "https://");
  }
  return url;
}
