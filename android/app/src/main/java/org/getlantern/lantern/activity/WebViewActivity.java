package org.getlantern.lantern.activity;

import android.app.ProgressDialog;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.ProxySettings;
import org.getlantern.mobilesdk.Logger;

@EActivity(R.layout.webview)
public class WebViewActivity extends BaseFragmentActivity {

    private static final String TAG = WebViewActivity.class.getName();

    private ProgressDialog dialog;

    @Extra
    String url;

    @ViewById
    WebView webView;

    public void closeWebView(View view) {
        this.finish();
    }

    @AfterViews
    void afterViews() {
        if (url == null) {
            Logger.error(TAG, "Not opening webview; invalid url");
            return;
        }
        dialog = new ProgressDialog(this);
        openWebview(url);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_BACK:
                    if (webView.canGoBack()) {
                        webView.goBack();
                    } else {
                        finish();
                    }
                    return true;
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    protected void showProgressDialog() {
        if (dialog != null) {
            dialog.show();
        }
    }

    protected void hideProgressDialog() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }


    protected void openWebview(final String url) {
        final String proxyAddr = LanternApp.getSession().getHTTPAddr();
        final String[] parts = proxyAddr.split(":");
        if (parts.length > 0) {
            final String proxyHost = parts[0];
            final int proxyPort = Integer.parseInt(parts[1]);
            ProxySettings.setProxy(this,
                    webView, proxyHost, proxyPort);
        }
        Logger.debug(TAG, "Opening " + url + " in webview");

        // Added to get around an issue where we might be unable
        // to start an intent without a user gesture. This allows
        // the webview to redirect automatically to the payment page
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return false;
            }
        });

        webView.getSettings().setLoadWithOverviewMode(true);
        webView.getSettings().setUseWideViewPort(true);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setPluginState(PluginState.ON);
        webView.getSettings().setSupportZoom(false);
        webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        webView.loadUrl(url);
    }
}
