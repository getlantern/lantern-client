package org.getlantern.lantern

import android.app.Application
import android.content.Context
import android.os.StrictMode
import androidx.appcompat.app.AppCompatDelegate
import androidx.multidex.MultiDex

import org.getlantern.lantern.model.InAppBilling
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternSessionManager
import org.getlantern.lantern.util.debugOnly
import org.getlantern.lantern.util.LanternProxySelector
import org.getlantern.lantern.util.SentryUtil
import org.getlantern.mobilesdk.util.HttpClient

open class LanternApp : Application() {

    init {
        debugOnly {
            System.setProperty("kotlinx.coroutines.debug", "on")
        }

        if (BuildConfig.DEBUG) {
            StrictMode.setThreadPolicy(
                StrictMode.ThreadPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .build(),
            )
            StrictMode.setVmPolicy(
                StrictMode.VmPolicy.Builder()
                    .detectLeakedSqlLiteObjects()
                    .detectLeakedClosableObjects()
                    .penaltyLog()
                    .build(),
            )
        }
    }

    override fun onCreate() {
        super.onCreate()
        SentryUtil.enableGoPanicEnrichment(this)
        // Necessary to locate a back arrow resource we use from the
        // support library. See http://stackoverflow.com/questions/37615470/support-library-vectordrawable-resourcesnotfoundexception
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true)
        appContext = applicationContext
        session = LanternSessionManager(this)
        LanternProxySelector(session)

        if (session.isPlayVersion) inAppBilling = InAppBilling(this)

        lanternHttpClient = LanternHttpClient()

        // When the app starts, reset our "hasSucceedingProxy" flag to clear any old warnings
        // about proxies being unavailable.
        session.resetHasSucceedingProxy()
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        // this is necessary running earlier versions of Android
        // multidex support has to be added manually
        // in addition to being enabled in the app build.gradle
        // See http://stackoverflow.com/questions/36907916/java-lang-noclassdeffounderror-while-registering-eventbus-in-onstart-method-for
        MultiDex.install(this)
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
            var iab: InAppBilling? = null
            if (session.isPlayVersion) {
                iab = inAppBilling
            }
            if (session.isRussianUser) {
                iab = null
            }
            lanternHttpClient.getPlans(cb, iab)
        }

        @JvmStatic
        fun getSession(): LanternSessionManager {
            return session
        }
    }
}
