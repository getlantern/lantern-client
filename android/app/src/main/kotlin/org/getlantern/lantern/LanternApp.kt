package org.getlantern.lantern

import android.app.Application
import android.content.Context
import android.os.StrictMode
import androidx.appcompat.app.AppCompatDelegate
import androidx.multidex.MultiDex
import com.datadog.android.Datadog
import com.datadog.android.DatadogSite
import com.datadog.android.core.configuration.Configuration
import com.datadog.android.event.EventMapper
import com.datadog.android.privacy.TrackingConsent
import com.datadog.android.rum.GlobalRumMonitor
import com.datadog.android.rum.Rum
import com.datadog.android.rum.RumConfiguration
import com.datadog.android.rum.event.ViewEventMapper
import com.datadog.android.rum.model.ActionEvent
import com.datadog.android.rum.model.ErrorEvent
import com.datadog.android.rum.model.LongTaskEvent
import com.datadog.android.rum.model.ResourceEvent
import com.datadog.android.rum.model.ViewEvent
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

        initializeDatadog()

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

    private fun initializeDatadog() {
        Datadog.setVerbosity(Log.VERBOSE)
        Datadog.initialize(
            this,
            createDatadogConfiguration(),
            TrackingConsent.GRANTED
        )
        val rumConfig = createRumConfiguration()
        Rum.enable(rumConfig)    
    }

    private fun createRumConfiguration(): RumConfiguration {
        return RumConfiguration.Builder(BuildConfig.DD_RUM_APPLICATION_ID)
            .apply {
                if (BuildConfig.DD_OVERRIDE_RUM_URL.isNotBlank()) {
                    useCustomEndpoint(BuildConfig.DD_OVERRIDE_RUM_URL)
                }
            }
            .setTelemetrySampleRate(100f)
            .trackUserInteractions()
            .trackLongTasks(250L)
            .setViewEventMapper(object : ViewEventMapper {
                override fun map(event: ViewEvent): ViewEvent {
                    event.context?.additionalProperties?.put(ATTR_IS_MAPPED, true)
                    return event
                }
            })
            .setActionEventMapper(object : EventMapper<ActionEvent> {
                override fun map(event: ActionEvent): ActionEvent {
                    event.context?.additionalProperties?.put(ATTR_IS_MAPPED, true)
                    return event
                }
            })
            .setResourceEventMapper(object : EventMapper<ResourceEvent> {
                override fun map(event: ResourceEvent): ResourceEvent {
                    event.context?.additionalProperties?.put(ATTR_IS_MAPPED, true)
                    return event
                }
            })
            .setErrorEventMapper(object : EventMapper<ErrorEvent> {
                override fun map(event: ErrorEvent): ErrorEvent {
                    event.context?.additionalProperties?.put(ATTR_IS_MAPPED, true)
                    return event
                }
            })
            .setLongTaskEventMapper(object : EventMapper<LongTaskEvent> {
                override fun map(event: LongTaskEvent): LongTaskEvent {
                    event.context?.additionalProperties?.put(ATTR_IS_MAPPED, true)
                    return event
                }
            })
            .build()
    }

    private fun createDatadogConfiguration(): Configuration {
        val configBuilder = Configuration.Builder(
            clientToken = BuildConfig.DD_CLIENT_TOKEN,
            env = BuildConfig.BUILD_TYPE,
            variant = BuildConfig.FLAVOR
        )
        .setFirstPartyHosts(tracedHosts)

        try {
            configBuilder.useSite(DatadogSite.valueOf(BuildConfig.DD_SITE_NAME))
        } catch (e: IllegalArgumentException) {
            Logger.e("Error setting site to ${BuildConfig.DD_SITE_NAME}")
        }

        return configBuilder.build()
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
            lanternHttpClient.getPlans(
                cb,
                if (session.isPlayVersion && !session.isRussianUser) inAppBilling else null
            )
        }

        @JvmStatic
        fun getSession(): LanternSessionManager {
            return session
        }
    }
}
