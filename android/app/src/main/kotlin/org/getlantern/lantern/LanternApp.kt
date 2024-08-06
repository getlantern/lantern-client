package org.getlantern.lantern

//import org.getlantern.lantern.util.SentryUtil
//import org.getlantern.lantern.model.LanternHttpClient
import android.app.Application
import android.content.Context
import android.os.StrictMode
import androidx.appcompat.app.AppCompatDelegate
import io.lantern.model.SessionModel
import org.getlantern.lantern.model.InAppBilling
import org.getlantern.lantern.model.MessagingHolder
import org.getlantern.lantern.util.debugOnly

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
//        session = LanternSessionManager(this)
//        // When the app starts, reset our "hasSucceedingProxy" flag to clear any old warnings
//        // about proxies being unavailable.
//        session.resetHasSucceedingProxy()
//        LanternProxySelector(session)

//        lanternHttpClient = LanternHttpClient()

    }

    companion object {
        private val TAG = LanternApp::class.java.simpleName
        private lateinit var appContext: Context
        private lateinit var inAppBilling: InAppBilling
        private lateinit var session: SessionModel
        private lateinit var goSession: internalsdk.SessionModel
        var messaging: MessagingHolder = MessagingHolder()

        @JvmStatic
        fun getAppContext(): Context {
            return appContext
        }

        @JvmStatic
        fun getInAppBilling(): InAppBilling {
            return inAppBilling
        }
        @JvmStatic
        fun setInAppBilling(inAppBilling: InAppBilling)  {
             this.inAppBilling= inAppBilling
        }


        @JvmStatic
        fun getGoSession(): internalsdk.SessionModel {
            return goSession
        }

        @JvmStatic
        fun getSession(): SessionModel {
            return session
        }

        @JvmStatic
        fun setSession(sessionModel :SessionModel) {
            session= sessionModel
        }
        @JvmStatic
        fun setGoSession(sessionModel :internalsdk.SessionModel) {
            goSession= sessionModel
        }
    }
}
