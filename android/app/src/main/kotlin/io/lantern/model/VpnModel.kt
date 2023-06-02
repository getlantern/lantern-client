package io.lantern.model

import android.app.Activity
import com.google.protobuf.ByteString
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.apps.AppsDataProvider
import org.getlantern.lantern.util.castToBoolean
import org.getlantern.mobilesdk.Logger

class VpnModel(
    activity: Activity,
    flutterEngine: FlutterEngine,
    private var switchLanternHandler: ((vpnOn: Boolean) -> Unit)? = null,
) : BaseModel("vpn", flutterEngine, masterDB.withSchema(VPN_SCHEMA)) {
    private val appsDataProvider: AppsDataProvider = AppsDataProvider(
        activity.packageManager, activity.packageName
    )

    companion object {
        private const val TAG = "VpnModel"
        const val VPN_SCHEMA = "vpn"

        const val PATH_VPN_STATUS = "/vpn_status"
        const val PATH_SERVER_INFO = "/server_info"
        const val PATH_BANDWIDTH = "/bandwidth"
        const val PATH_SPLIT_TUNNELING = "/splitTunneling"
        const val PATH_APPS_DATA = "/appsData/"
    }

    init {
        val start = System.currentTimeMillis()
        db.registerType(1000, Vpn.ServerInfo::class.java)
        db.registerType(1001, Vpn.Bandwidth::class.java)
        db.registerType(1002, Vpn.AppData::class.java)
        Logger.debug(TAG, "register types finished at ${System.currentTimeMillis() - start}")
        db.mutate { tx ->
            tx.put(
                PATH_SPLIT_TUNNELING,
                castToBoolean(tx.get(PATH_SPLIT_TUNNELING), false)
            )
        }
        db.mutate { tx ->
            // initialize vpn status for fresh install
            tx.put(PATH_VPN_STATUS, tx.get<String>(PATH_VPN_STATUS) ?: "disconnected")
        }
        Logger.debug(TAG, "db.mutate finished at ${System.currentTimeMillis() - start}")
        updateAppsData()
    }

    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "refreshAppsList") {
            updateAppsData()
            result.success(null)
        } else {
            super.doOnMethodCall(call, result)
        }
    }

    override fun doMethodCall(call: MethodCall, notImplemented: () -> Unit): Any? {
        return when (call.method) {
            "switchVPN" -> {
                val on = call.argument<Boolean>("on") ?: false
                saveVpnStatus(if (on) "connecting" else "disconnecting")
                switchLantern(on)
            }

            "setSplitTunneling" -> {
                val on = call.argument("on") ?: false
                saveSplitTunneling(on)
            }

            "allowAppAccess" -> {
                updateAppData(call.argument("packageName")!!, true)
            }

            "denyAppAccess" -> {
                updateAppData(call.argument("packageName")!!, false)
            }

            else -> super.doMethodCall(call, notImplemented)
        }
    }

    fun splitTunnelingEnabled(): Boolean {
        return db.get(PATH_SPLIT_TUNNELING) ?: false
    }

    // appsAllowedAccess returns a list of package names for those applications that are allowed
    // to access the VPN connection. If split tunneling is enabled, and any app is added to
    // the list, only those applications (and no others) are allowed access.
    fun appsAllowedAccess(): List<String> {
        var installedApps = db.list<Vpn.AppData>(PATH_APPS_DATA + "%")
        val apps = mutableListOf<String>()
        for (appData in installedApps) {
            if (appData.value.allowedAccess) apps.add(appData.value.packageName)
        }
        return apps
    }

    private fun saveSplitTunneling(value: Boolean) {
        db.mutate { tx ->
            tx.put(PATH_SPLIT_TUNNELING, value)
        }
    }

    // updateAppData looks up the app data for the given package name and updates whether or
    // not the app is allowed access to the VPN connection in the database
    private fun updateAppData(packageName: String, allowedAccess: Boolean) {
        db.mutate { tx ->
            var appData = tx.get<Vpn.AppData>(PATH_APPS_DATA + packageName)
            appData?.let {
                tx.put(
                    PATH_APPS_DATA + packageName, Vpn.AppData.newBuilder()
                        .setPackageName(it.packageName).setIcon(it.icon)
                        .setName(it.name).setAllowedAccess(allowedAccess).build()
                )
            }
        }
    }

    // updateAppsData stores app data for the list of applications installed for the current
    // user in the database
    private fun updateAppsData() {
        // This can be quite slow, run it on its own thread
        Thread {
            val appsList = appsDataProvider.listOfApps()
            // First add just the app names to get a list quickly
            db.mutate { tx ->
                appsList.forEach {
                    val path = PATH_APPS_DATA + it.packageName
                    if (!tx.contains(path)) {
                        // App not already in list, add it
                        tx.put(
                            path,
                            Vpn.AppData.newBuilder()
                                .setPackageName(it.packageName).setName(it.name)
                                .build()
                        )
                    }
                }
            }

            // Then add icons
            db.mutate { tx ->
                appsList.forEach {
                    val path = PATH_APPS_DATA + it.packageName
                    tx.get<Vpn.AppData>(path)?.let { existing ->
                        if (existing.icon.isEmpty) {
                            it.icon.let { icon ->
                                tx.put(
                                    path,
                                    existing.toBuilder()
                                        .setIcon(ByteString.copyFrom(icon))
                                        .build(),
                                )
                            }
                        }
                    }
                }
            }
        }.start()
    }

    fun isConnectedToVpn(): Boolean {
        val vpnStatus = vpnStatus()
        return vpnStatus == "connected" || vpnStatus == "disconnecting"
    }

    private fun vpnStatus(): String {
        return db.get(PATH_VPN_STATUS) ?: ""
    }

    private fun switchLantern(value: Boolean) {
        switchLanternHandler?.invoke(value)
    }

    fun setVpnOn(vpnOn: Boolean) {
        val vpnStatus = if (vpnOn) "connected" else "disconnected"
        saveVpnStatus(vpnStatus)
    }

    fun saveVpnStatus(vpnStatus: String) {
        db.mutate { tx ->
            tx.put(PATH_VPN_STATUS, vpnStatus)
        }
    }

    fun saveServerInfo(serverInfo: Vpn.ServerInfo) {
        db.mutate { tx ->
            tx.put(PATH_SERVER_INFO, serverInfo)
        }
    }

    fun saveBandwidth(bandwidth: Vpn.Bandwidth) {
        Logger.d(
            TAG, "Bandwidth updated to " + bandwidth.remaining + " remaining out of " +
                    bandwidth.allowed + " allowed"
        )
        db.mutate { tx ->
            tx.put(PATH_BANDWIDTH, bandwidth)
        }
    }
}
