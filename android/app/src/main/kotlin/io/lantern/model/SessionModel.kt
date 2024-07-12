package io.lantern.model

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Proxy
import android.util.ArrayMap
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import com.google.protobuf.ByteString
import internalsdk.SessionModel
import internalsdk.SessionModelOpts
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.apps.AppsDataProvider
import io.lantern.model.dbadapter.DBAdapter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.Utils
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.Settings
import org.getlantern.mobilesdk.StartResult
import org.getlantern.mobilesdk.util.DnsDetector
import java.io.PrintWriter
import java.io.StringWriter
import java.lang.reflect.InvocationTargetException
import java.util.Base64

class SessionModel internal constructor(
    private val activity: Activity,
    flutterEngine: FlutterEngine,
    opts: SessionModelOpts
) : GoModel<SessionModel>(
    "session",
    flutterEngine,
    masterDB.withSchema("session"),
    SessionModel(DBAdapter(masterDB.db), opts),
) {
    companion object {
        const val TAG = "SessionModel"
        const val PATH_SPLIT_TUNNELING = "/splitTunneling"
        const val SHOULD_SHOW_GOOGLE_ADS = "shouldShowGoogleAds"
        const val PATH_APPS_DATA = "/appsData/"
        val fakeDnsIP = "1.1.1.1"
        const val PREFERENCES_SCHEMA = "session_model"
    }

    val settings: Settings = Settings.init(activity)
    private var startResult: StartResult? = null
    val dnsDetector = DnsDetector(activity, fakeDnsIP)
    private val appsDataProvider: AppsDataProvider = AppsDataProvider(
        activity.packageManager, activity.packageName
    )

    init {
        LanternApp.setGoSession(model)
        updateAppsData()
    }

    /// Utils class methods

    val language: String = model.locale()

    val ipAddress: String?
        get() = model.ipAddress()

    fun setHasFirstSessionCompleted(bool: Boolean) {

    }

    fun isStoreVersion(): Boolean {
        if (BuildConfig.PLAY_VERSION || model.isStoreVersion) {
            return true
        }
        try {
            val validInstallers: List<String> = ArrayList(
                listOf(
                    "com.android.vending",
                    "com.google.android.feedback"
                )
            )
            val installer = activity.packageManager
                .getInstallerPackageName(activity.packageName)
            return installer != null && validInstallers.contains(installer)
        } catch (e: java.lang.Exception) {
            Logger.error(TAG, "Error fetching package information: " + e.message)
        }
        return false
    }


    fun appVersion(): String {
        return Utils.appVersion(activity)
    }

    fun deviceID(): String {
        if (model.deviceID == "") {
            val deviceId = android.provider.Settings.Secure.getString(
                activity.contentResolver,
                android.provider.Settings.Secure.ANDROID_ID
            )
            setDeviceId(deviceId)
            return deviceId
        }
        return model.deviceID
    }

    fun setDeviceId(deviceId: String) {
        model.invokeMethod("setDevice", Arguments(mapOf("deviceID" to deviceId)))
    }

    fun updateVpnPreference(useVpn: Boolean) {
        model.invokeMethod("updateVpnPref", Arguments(mapOf("useVpn" to useVpn)))
    }

    // appsAllowedAccess returns a list of package names for those applications that are allowed
//    // to access the VPN connection. If split tunneling is enabled, and any app is added to
//    // the list, only those applications (and no others) are allowed access.
    fun appsAllowedAccess(): List<String> {
        val result = model.invokeMethod("appsAllowedAccess", Arguments(mapOf("useVpn" to true)))
        result.toJava()
        Logger.debug(TAG, "appsAllowedAccess: ${result.toJava()}")

//        var installedApps = db.list<Vpn.AppData>(PATH_APPS_DATA + "%")
//        val apps = mutableListOf<String>()
//        for (appData in installedApps) {
//            if (appData.value.allowedAccess) apps.add(appData.value.packageName)
//        }
        return listOf()
    }

    fun splitTunnelingEnabled(): Boolean {
        return model.splitTunnelingEnabled()
    }

    fun isProUser(): Boolean {
        return model.isProUser

    }

    fun userId(): Long {
        return model.userID
    }

    fun countryCode(): String {
        return model.countryCode
    }

    // TO update to use sessionModel go
    fun chatEnabled(): Boolean = false

    fun lanternDidStart(): Boolean {
        return startResult != null
    }

    val hTTPAddr: String
        get() = if (startResult == null) {
            ""
        } else {
            startResult!!.httpAddr
        }
    val sOCKS5Addr: String
        get() = if (startResult == null) {
            ""
        } else {
            startResult!!.socks5Addr
        }
    val dNSGrabAddr: String
        get() = if (startResult == null) {
            ""
        } else {
            startResult!!.dnsGrabAddr
        }

    fun setStartResult(result: StartResult?) {
        startResult = result
        setWebViewProxy()
        Logger.debug(
            TAG,
            String.format(
                "Lantern successfully started; HTTP proxy address: %s SOCKS proxy address: %s",
                hTTPAddr,
                sOCKS5Addr,
            ),
        )
    }

    private fun setWebViewProxy() {
        // We set ourselves as the WebView proxy if and only if WebViewFeature.PROXY_OVERRIDE
        // is supported.
        if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
            val proxyConfig = ProxyConfig.Builder()
                .addProxyRule("http://${hTTPAddr}")
                .build()
            ProxyController.getInstance().setProxyOverride(
                proxyConfig,
                ContextCompat.getMainExecutor(activity),
            ) {}
        } else {
            // Below code based on suggestion here - https://stackoverflow.com/a/18453384
            try {
                val appContext = activity.applicationContext
                val addressParts = hTTPAddr.split(":")
                val host = addressParts[0]
                val port = addressParts[1]
                System.setProperty("http.proxyHost", host)
                System.setProperty("http.proxyPort", port)
                System.setProperty("https.proxyHost", host)
                System.setProperty("https.proxyPort", port)
                val applicationClass = LanternApp::class.java
                val loadedApkField = applicationClass.getField("mLoadedApk")
                loadedApkField.isAccessible = true
                val loadedApk: Any = loadedApkField.get(appContext)
                val loadedApkCls = Class.forName("android.app.LoadedApk")
                val receiversField = loadedApkCls.getDeclaredField("mReceivers")
                receiversField.isAccessible = true
                val receivers =
                    receiversField.get(loadedApk) as ArrayMap<Context, ArrayMap<BroadcastReceiver, Any>>
                for (receiverMap in receivers.values) {
                    for (rec in (receiverMap as ArrayMap).keys) {
                        val clazz: Class<*> = rec.javaClass
                        if (clazz.name.contains("ProxyChangeListener")) {
                            val onReceiveMethod = clazz.getDeclaredMethod(
                                "onReceive",
                                Context::class.java,
                                Intent::class.java,
                            )
                            val intent = Intent(Proxy.PROXY_CHANGE_ACTION)
                            onReceiveMethod.invoke(rec, appContext, intent)
                        }
                    }
                }
                Log.d(TAG, "Setting proxy with >= 4.4 API successful!")
            } catch (e: ClassNotFoundException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: NoSuchFieldException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: IllegalAccessException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: IllegalArgumentException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: NoSuchMethodException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            } catch (e: InvocationTargetException) {
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val exceptionAsString = sw.toString()
                e.message?.let { Log.v(TAG, it) }
                Log.v(TAG, exceptionAsString)
            }
        }
    }


    //updateAppsData stores app data for the list of applications installed for the current
    // user in the database
    private fun updateAppsData() {
        // This can be quite slow, run it on its own coroutine
        CoroutineScope(Dispatchers.IO).launch {
            val appsList = appsDataProvider.listOfApps()
            // First add just the app names to get a list quickly
            val apps = buildJsonArray {
                appsList.forEach { app ->
                    add(
                        buildJsonObject {
                            val byte = ByteString.copyFrom(app.icon)
                            val encodedIcon = Base64.getEncoder().encodeToString(byte.toByteArray())
                            put("packageName", app.packageName)
                            put("name", app.name)
                            put("icon", encodedIcon)
                        }
                    )
                }
            }

            model.invokeMethod(
                "updateAppsData",
                Arguments(mapOf("appsList" to apps.toString()))
            )

//            db.mutate { tx ->
//                appsList.forEach {
//                    val path = PATH_APPS_DATA + it.packageName
//                    if (!tx.contains(path)) {
//                        // App not already in list, add it
//                        tx.put(
//                            path,
//                            Vpn.AppData.newBuilder().setPackageName(it.packageName).setName(it.name)
//                                .setIcon(ByteString.copyFrom(it.icon)).build()
//                        )
//                    }
//                }
//            }

        }
    }


}