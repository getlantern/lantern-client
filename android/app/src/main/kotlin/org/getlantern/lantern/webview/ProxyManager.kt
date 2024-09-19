package org.getlantern.lantern.webview

import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import org.getlantern.mobilesdk.Logger

class ProxyManager {

    companion object {
        private val TAG = ProxyManager::class.java.simpleName

        fun setWebViewProxy(host: String) = setProxy(host, null)

        internal fun setProxy(host: String, httpsHost: String?) {
            try {
                if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
                    val config = ProxyConfig.Builder().apply {
                        if (httpsHost != null && httpsHost.isNotEmpty()) {
                            addProxyRule(host, ProxyConfig.MATCH_HTTP)
                            addProxyRule(httpsHost, ProxyConfig.MATCH_HTTPS)
                        } else {
                            addProxyRule(host)
                        }
                    }.build()
                    ProxyController.getInstance().setProxyOverride(config, {
                        Logger.e(TAG, "setProxyOverride execute")
                    }, {
                        Logger.e(TAG, "Error setting proxy override")
                    })
                }
            } catch (e: IllegalArgumentException) {
                Logger.e(TAG, "Unable to set proxy", e)
            }
        }

        fun clearProxy() {
            if (!WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) return
            ProxyController.getInstance().clearProxyOverride({
                Logger.e(TAG, "clearProxyOverride execute")
            }, {
                Logger.e(TAG, "Error clearing proxy override");
            })
        }
    }
}