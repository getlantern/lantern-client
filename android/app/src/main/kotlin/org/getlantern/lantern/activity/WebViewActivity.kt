package org.getlantern.lantern.activity

import android.app.ProgressDialog
import android.view.KeyEvent
import android.view.View
import android.webkit.WebSettings.PluginState
import android.webkit.WebView
import android.webkit.WebViewClient
import org.androidannotations.annotations.AfterViews
import org.androidannotations.annotations.EActivity
import org.androidannotations.annotations.Extra
import org.androidannotations.annotations.ViewById
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.ProxySettings
import org.getlantern.mobilesdk.Logger

@EActivity(R.layout.webview)
open class WebViewActivity : BaseFragmentActivity() {

    private var dialog: ProgressDialog? = null

    @Extra
    @JvmField
    protected var url: String? = null

    @ViewById
    lateinit var webView: WebView

    @AfterViews
    fun afterViews() {
        dialog = ProgressDialog(this)

        url?.let { openWebview(url!!) }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN && keyCode == KeyEvent.KEYCODE_BACK) {
            if (webView.canGoBack()) webView.goBack() else finish()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun showProgressDialog() {
        dialog?.show()
    }

    private fun hideProgressDialog() {
        dialog?.let { if (it.isShowing) it.dismiss() }
    }

    private fun openWebview(url: String) {
        val proxyAddr: String = LanternApp.session.hTTPAddr
        val parts = proxyAddr.split(":").toTypedArray()
        if (parts.size == 2) {
            val proxyHost = parts[0]
            val proxyPort = parts[1].toInt()
            ProxySettings.setProxy(this, webView, proxyHost, proxyPort)
        }
        Logger.d(TAG, "Opening $url in webview")

        // Added to get around an issue where we might be unable
        // to start an intent without a user gesture. This allows
        // the webview to redirect automatically to the payment page
        webView.setWebViewClient(object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                return false
            }
        })
        val settings = webView.getSettings()
        settings.loadWithOverviewMode = true
        settings.useWideViewPort = true
        settings.javaScriptEnabled = true
        settings.pluginState = PluginState.ON
        settings.setSupportZoom(false)
        webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY)
        webView.loadUrl(url)
    }

    fun closeWebView(view: View) {
        finish()
    }

    companion object {
        private val TAG = WebViewActivity::class.java.simpleName
    }
}
