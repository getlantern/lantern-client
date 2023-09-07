package org.getlantern.lantern.datadog

import android.util.Log
import com.datadog.android.Datadog as DatadogMain
import com.datadog.android.DatadogSite
import com.datadog.android.core.configuration.BatchSize
import com.datadog.android.core.configuration.Configuration
import com.datadog.android.core.configuration.Credentials
import com.datadog.android.core.configuration.UploadFrequency
import com.datadog.android.privacy.TrackingConsent
import com.datadog.android.rum.GlobalRum
import com.datadog.android.rum.RumActionType
import com.datadog.android.rum.RumErrorSource
import com.datadog.android.rum.RumMonitor
import com.datadog.android.rum.tracking.ActivityViewTrackingStrategy
import org.getlantern.lantern.LanternApp
import org.getlantern.mobilesdk.Logger
import java.net.InetSocketAddress
import java.net.Proxy
import java.util.concurrent.atomic.AtomicBoolean

object Datadog {
    private val tracedHosts = listOf(
        "datadoghq.eu",
        "127.0.0.1",
    )
    private val initialized = AtomicBoolean()
    private lateinit var datadogConfig: Configuration

    fun initialize() {
        if (initialized.get()) return

        DatadogMain.setVerbosity(Log.VERBOSE)
        datadogConfig = createDatadogConfiguration()

        val datadogCredentials = Credentials(
            clientToken = "puba617ab01333a95a25a9d3709f04e1654",
            envName = "prod",
            rumApplicationId = "f8eabf3c-5db3-4f7e-8e6a-5a72433b46d2",
            variant = "release",
            serviceName = "lantern-android",
        )

        DatadogMain.initialize(
            LanternApp.getAppContext(),
            credentials = datadogCredentials,
            configuration = datadogConfig,
            TrackingConsent.GRANTED,
        )

        DatadogMain.setUserInfo(
            id = LanternApp.getSession().userId().toString(),
        )

        val monitor = RumMonitor.Builder().build()
        GlobalRum.registerIfAbsent(monitor)
        initialized.set(true)
    }

    fun addError(
        message: String,
        throwable: Throwable? = null,
        attributes: Map<String, Any?> = emptyMap(),
    ) {
        Logger.e(TAG, message, throwable)
        GlobalRum.get().addError(message, RumErrorSource.SOURCE, throwable, attributes)
    }

    // trackUserAction is used to track specific user actions (such as taps, clicks, and scrolls)
    // with RumMonitor
    fun trackUserAction(
        actionType: RumActionType,
        name: String,
        actionAttributes: Map<String, Any?> = emptyMap(),
    ) {
         GlobalRum.get().addUserAction(actionType, name, actionAttributes)
    }

    // trackUserClick is used to track user clicks with RumMonitor
    fun trackUserClick(
        name: String,
        actionAttributes: Map<String, Any?> = emptyMap(),
    ) {
        trackUserAction(RumActionType.CLICK, name, actionAttributes)
    }

    // trackUserTap is used to track user taps with RumMonitor
    fun trackUserTap(
        name: String,
        actionAttributes: Map<String, Any?> = emptyMap(),
    ) {
        trackUserAction(RumActionType.TAP, name, actionAttributes)
    }

    private fun createDatadogConfiguration(): Configuration {
        val session = LanternApp.getSession()
        return Configuration.Builder(
            logsEnabled = true,
            tracesEnabled = true,
            crashReportsEnabled = true,
            rumEnabled = true,
        )
            .setBatchSize(BatchSize.SMALL)
            .setProxy(
                Proxy(
                    Proxy.Type.HTTP,
                    InetSocketAddress(
                        session.settings.httpProxyHost,
                        session.settings.httpProxyPort.toInt(),
                    ),
                ),
                null,
            )
            .sampleRumSessions(100f)
            .setUploadFrequency(UploadFrequency.FREQUENT)
            .useSite(DatadogSite.EU1)
            .trackInteractions()
            .trackLongTasks()
            .setFirstPartyHosts(tracedHosts)
            .useViewTrackingStrategy(
                ActivityViewTrackingStrategy(
                    trackExtras = false,
                    componentPredicate = FlutterExcludingComponentPredicate(),
                ),
            )
            .build()
    }

    private val TAG = Datadog::class.java.name
}
