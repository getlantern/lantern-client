package org.getlantern.lantern.datadog

import android.util.Log
import com.datadog.android.Datadog
import com.datadog.android.DatadogSite
import com.datadog.android.core.configuration.BatchSize
import com.datadog.android.core.configuration.Configuration
import com.datadog.android.core.configuration.Credentials
import com.datadog.android.core.configuration.UploadFrequency
import com.datadog.android.privacy.TrackingConsent
import com.datadog.android.rum.GlobalRum
//import com.datadog.android.rum.Rum
//import com.datadog.android.rum.RumConfiguration
import com.datadog.android.rum.RumMonitor
import com.datadog.android.rum.tracking.AcceptAllActivities
import com.datadog.android.rum.tracking.ActivityViewTrackingStrategy
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import java.net.InetSocketAddress
import java.net.Proxy

class DatadogProvider {
	companion object {
	    private val tracedHosts = listOf(
	        "datadoghq.com",
	        "127.0.0.1"
	    )

		fun initialize() {
			val session = LanternApp.getSession()
	        Datadog.setVerbosity(Log.VERBOSE)
	        val datadogConfig = Configuration.Builder(
	            logsEnabled = true,
	            tracesEnabled = true,
	            crashReportsEnabled = true,
	            rumEnabled = true,
	        )
	        .setBatchSize(BatchSize.SMALL)
	        .setProxy(Proxy(Proxy.Type.HTTP, InetSocketAddress(session.settings.httpProxyHost, 
	        	session.settings.httpProxyPort.toInt())), null)
	        .sampleRumSessions(100f)
	        .setUploadFrequency(UploadFrequency.FREQUENT)
	        .useSite(DatadogSite.EU1)
	        .trackInteractions()
	        .trackLongTasks()
	        .setFirstPartyHosts(tracedHosts)
	        .useViewTrackingStrategy(ActivityViewTrackingStrategy(
	            trackExtras = false,
	            componentPredicate = FlutterExcludingComponentPredicate()
	        ))
	        .build()

	        val datadogCredentials = Credentials(
	        	clientToken = BuildConfig.DD_CLIENT_TOKEN, 
	        	envName = "prod",
	        	rumApplicationId = BuildConfig.DD_APPLICATION_ID,
	        	variant = "release",
	        	serviceName = "lantern-android"
	        )

	        Datadog.initialize(
	            LanternApp.getAppContext(),
	            credentials = datadogCredentials,
	            configuration = datadogConfig,
	            TrackingConsent.GRANTED
	        )

        	Datadog.setUserInfo(
            	id = LanternApp.getSession().userId().toString(),
            )

	        val monitor = RumMonitor.Builder().build()
	        GlobalRum.registerIfAbsent(monitor)
	    }
	}
}
