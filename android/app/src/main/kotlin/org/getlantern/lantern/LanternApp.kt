package org.getlantern.lantern

//import org.getlantern.lantern.util.SentryUtil
import android.app.Application
import android.content.Context
import android.os.StrictMode
import androidx.appcompat.app.AppCompatDelegate
import org.getlantern.lantern.model.InAppBilling
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternSessionManager
import org.getlantern.lantern.model.MessagingHolder
import org.getlantern.lantern.util.LanternProxySelector
import org.getlantern.lantern.util.debugOnly
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

        // Necessary to locate a back arrow resource we use from the
        // support library. See http://stackoverflow.com/questions/37615470/support-library-vectordrawable-resourcesnotfoundexception
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true)
        appContext = applicationContext
        messaging.init(this)
        session = LanternSessionManager(this)

        LanternProxySelector(session)

        lanternHttpClient = LanternHttpClient()

        // When the app starts, reset our "hasSucceedingProxy" flag to clear any old warnings
        // about proxies being unavailable.
        session.resetHasSucceedingProxy()

        inAppBilling = InAppBilling(this)
    }

    companion object {
        private val TAG = LanternApp::class.java.simpleName
        private lateinit var appContext: Context
        private lateinit var inAppBilling: InAppBilling
        private lateinit var lanternHttpClient: LanternHttpClient
        private lateinit var session: LanternSessionManager
        var messaging: MessagingHolder = MessagingHolder()

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
        fun getSession(): LanternSessionManager {
            return session
        }
    }
}
