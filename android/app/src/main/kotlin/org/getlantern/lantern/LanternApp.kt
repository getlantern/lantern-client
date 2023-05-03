package org.getlantern.lantern

import android.app.Application
import android.content.Context
import android.os.StrictMode
import androidx.appcompat.app.AppCompatDelegate

import org.getlantern.lantern.model.InAppBilling
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternSessionManager
// import org.getlantern.lantern.model.MessagingHolder;
import org.getlantern.lantern.util.debugOnly
import org.getlantern.lantern.util.LanternProxySelector
import org.getlantern.mobilesdk.util.HttpClient

open class LanternApp : Application() {

    init {
        debugOnly {
            System.setProperty("kotlinx.coroutines.debug", "on")
        }

        if (BuildConfig.DEBUG) {
            StrictMode.enableDefaults()
        } else {
            StrictMode.setVmPolicy(StrictMode.VmPolicy.LAX)
            StrictMode.setThreadPolicy(StrictMode.ThreadPolicy.LAX)
        }
    }

    override fun onCreate() {
        super.onCreate()
        // Necessary to locate a back arrow resource we use from the
        // support library. See http://stackoverflow.com/questions/37615470/support-library-vectordrawable-resourcesnotfoundexception
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true)
        appContext = applicationContext
        session = LanternSessionManager(this)
        LanternProxySelector(session)

        if (session.isPlayVersion()) inAppBilling = InAppBilling(this)


        lanternHttpClient = LanternHttpClient()
    }

    companion object {
        private val TAG = LanternApp::class.java.simpleName
        private lateinit var appContext: Context
        private lateinit var inAppBilling: InAppBilling
        private lateinit var lanternHttpClient: LanternHttpClient
        private lateinit var session: LanternSessionManager

        @JvmStatic
        fun getAppContext(): Context {
            return appContext
        }

        @JvmStatic
        fun getHttpClient(): HttpClient {
            return lanternHttpClient
        }

        @JvmStatic
        fun getInAppBilling(): InAppBilling {
            return inAppBilling
        }

        @JvmStatic
        fun getLanternHttpClient(): LanternHttpClient {
            return lanternHttpClient
        }

        @JvmStatic
        fun getPlans(cb: LanternHttpClient.PlansCallback) {
            var iab: InAppBilling? = inAppBilling
            if (session.isRussianUser) iab = null
            lanternHttpClient.getPlans(cb, iab)
        }

        @JvmStatic
        fun getSession(): LanternSessionManager {
            return session
        }
    }
}
