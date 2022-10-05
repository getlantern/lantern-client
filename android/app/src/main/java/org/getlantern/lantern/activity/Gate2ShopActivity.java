 package org.getlantern.lantern.activity;

 import android.graphics.Bitmap;
 import android.webkit.WebView;
 import android.webkit.WebViewClient;

 import org.androidannotations.annotations.AfterViews;
 import org.androidannotations.annotations.EActivity;
 import org.getlantern.lantern.LanternApp;
 import org.getlantern.lantern.R;
 import org.getlantern.lantern.model.LanternHttpClient;
 import org.getlantern.lantern.model.PaymentHandler;
 import org.getlantern.lantern.model.ProPlan;
 import org.getlantern.mobilesdk.Logger;

 import java.util.HashMap;
 import java.util.Locale;
 import java.util.Map;

 import okhttp3.HttpUrl;

@EActivity(R.layout.webview)
public class Gate2ShopActivity extends WebViewActivity {
    private static final String TAG = Gate2ShopActivity.class.getName();
    private static final String PROVIDER = "Gate2Shop";
    
    private PaymentHandler paymentHandler;

    private HttpUrl buildUrl() {
        final ProPlan proPlan = LanternApp.getSession().getSelectedPlan();
        if (proPlan == null) {
            Logger.error(TAG, "Could not find selected pro plan");
            return null;
        }

        final String planId = proPlan.getId();
        final Map<String, String> params = new HashMap<String, String>();
        params.put("email", LanternApp.getSession().email());
        params.put("widgetKey", "m2_1");
        params.put("deviceName", LanternApp.getSession().deviceName());
        params.put("forcePaymentProvider", "gate2shop");
        params.put("platform", "android");
        params.put("locale", lang());
        params.put("currency", LanternApp.getSession().getSelectedPlanCurrency().toLowerCase());
        params.put("plan", planId);
        return LanternHttpClient.createProUrl("/payment-gateway-widget", params);
    }

    // This is actually returning a four-letter encoded locale (as in "zh-CN")
    private String lang() {
        final Locale locale = new Locale(LanternApp.getSession().getLanguage());
        final String locLang = locale.getLanguage();
        final String country = locale.getCountry();
        // TODO <10-05-22, kalli> Use isFrom() here?
        if (locLang.equalsIgnoreCase("zh")) {
            if (country.equalsIgnoreCase("CN")) {
                return "zh_CN";
            } else if (country.equalsIgnoreCase("TW")) {
                return "zh_TW";
            // TODO <10-05-22, kalli> Add case for "HK"?
            } else {
                return "zh_CN";
            }
        } else if (locLang.equals("pt") && country.equalsIgnoreCase("BR")) {
            return "pt_BR";
        }
        return locLang;
    }


    @AfterViews
    void afterViews() {
        final HttpUrl url = buildUrl();
        if (url == null) {
            Logger.error(TAG, "Unable to construct url");
            return;
        }
        paymentHandler = new PaymentHandler(this, PROVIDER);
        setWebViewClient();
        openWebview(url.toString());
    }

    private void purchaseSuccess(final String url) {
        paymentHandler.sendPurchaseRequest();
    }

    private void setWebViewClient() {
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                if (url.contains("gate2shop-success")) {
                    hideProgressDialog();
                    purchaseSuccess(url);
                    return;
                }
            }
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon)
            {
                showProgressDialog();
            }
        });

    }
}  
