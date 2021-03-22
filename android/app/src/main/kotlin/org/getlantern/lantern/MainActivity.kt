package org.getlantern.lantern

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.*
import android.text.Html
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.android.model.VpnModel
import org.getlantern.lantern.model.VpnState
import org.getlantern.lantern.service.LanternService_
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.Utils
import org.greenrobot.eventbus.EventBus
import java.io.File
import java.util.*

class MainActivity : FlutterActivity() {

    private lateinit var vpnModel: VpnModel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        vpnModel = VpnModel(flutterEngine, ::switchLantern)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = Intent(this, LanternService_::class.java)
        bindService(intent, lanternServiceConnection, BIND_AUTO_CREATE)
    }

    override fun onResume() {
        super.onResume()
        if (vpnModel.isConnectedToVpn() && !Utils.isServiceRunning(activity, LanternVpnService::class.java)) {
            Logger.d(TAG, "LanternVpnService isn't running, clearing VPN preference")
            vpnModel.setVpnOn(false)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        vpnModel.destroy()
        try {
            unbindService(lanternServiceConnection)
        } catch (t: Throwable) {
            Logger.e(TAG, "Unable to unbind LanternService", t)
        }
    }

    private val lanternServiceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceDisconnected(name: ComponentName) {
            Logger.e(TAG, "LanternService disconnected, closing app")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                finishAndRemoveTask()
            }
        }

        override fun onServiceConnected(name: ComponentName, service: IBinder) {}
    }

    @Throws(Exception::class)
    private fun switchLantern(on: Boolean) {
        Logger.d(TAG, "switchLantern to %1\$s", on)

        // disable the on/off switch while the VpnService
        // is updating the connection
        if (on) {
            // Make sure we have the necessary permissions
            val neededPermissions: Array<String> = missingPermissions()
            if (neededPermissions.isNotEmpty()) {
                val msg = StringBuilder()
                for (permission in neededPermissions) {
                    if (!hasPermission(permission)) {
                        msg.append("<p style='font-size: 0.5em;'><b>")
                        val pm = packageManager
                        try {
                            val info =
                                    pm.getPermissionInfo(permission, PackageManager.GET_META_DATA)
                            val label = info.loadLabel(pm)
                            msg.append(label)
                        } catch (nmfe: PackageManager.NameNotFoundException) {
                            Logger.error(
                                    PERMISSIONS_TAG,
                                    "Unexpected exception loading label for permission %s: %s",
                                    permission,
                                    nmfe
                            )
                            msg.append(permission)
                        }
                        msg.append("</b>&nbsp;")
                        msg.append(getString(R.string.permission_for))
                        msg.append("&nbsp;")
                        var description = "..."
                        try {
                            description = getString(
                                    resources.getIdentifier(
                                            permission,
                                            "string",
                                            "org.getlantern.lantern"
                                    )
                            )
                        } catch (t: Throwable) {
                            Logger.warn(
                                    PERMISSIONS_TAG,
                                    "Couldn't get permission description for %s: %s",
                                    permission,
                                    t
                            )
                        }
                        msg.append(description)
                        msg.append("</p>")
                    }
                }
                Logger.debug(
                        PERMISSIONS_TAG,
                        msg.toString()
                )
                Utils.showAlertDialog(this,
                        getString(R.string.please_allow_lantern_to),
                        Html.fromHtml(msg.toString()),
                        getString(R.string.continue_),
                        false,
                        Runnable {
                            ActivityCompat.requestPermissions(
                                    this,
                                    neededPermissions,
                                    FULL_PERMISSIONS_REQUEST
                            )
                        })
                return
            }


            // Prompt the user to enable full-device VPN mode
            // Make a VPN connection from the client
            Logger.debug(
                    TAG,
                    "Load VPN configuration"
            )
            val intent = VpnService.prepare(this)
            if (intent != null) {
                Logger.warn(
                        TAG,
                        "Requesting VPN connection"
                )
                startActivityForResult(
                        intent.setAction(LanternVpnService.ACTION_CONNECT),
                        REQUEST_VPN
                )
            } else {
                Logger.debug(
                        TAG,
                        "VPN enabled, starting Lantern..."
                )
                updateStatus(true)
                startVpnService()
            }
        } else {
            stopVpnService()
            updateStatus(false)
        }
    }

    /*Note - we do not include Manifest.permission.FOREGROUND_SERVICE because this is automatically
    granted based on being included in Manifest and will show as denied even if we're eligible
    to get it.*/
    private val allRequiredPermissions = arrayOf(
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE
    )

    private fun missingPermissions(): Array<String> {
        val missingPermissions: MutableList<String> = ArrayList()
        for (permission in allRequiredPermissions) {
            if (!hasPermission(permission)) {
                missingPermissions.add(permission)
            }
        }
        return missingPermissions.toTypedArray()
    }

    private fun hasPermission(permission: String): Boolean {
        val result = ContextCompat.checkSelfPermission(
                applicationContext,
                permission
        ) == PackageManager.PERMISSION_GRANTED
        Logger.debug(PERMISSIONS_TAG, "has permission %s: %s", permission, result)
        return result
    }

    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String?>,
            grantResults: IntArray,
    ) {
        when (requestCode) {
            FULL_PERMISSIONS_REQUEST -> {
                Logger.debug(
                        PERMISSIONS_TAG,
                        "Got result for %s: %s",
                        permissions.size,
                        grantResults.size
                )
                var i = 0
                while (i < permissions.size) {
                    val permission = permissions[i]
                    val result = grantResults[i]
                    if (result == PackageManager.PERMISSION_DENIED) {
                        Logger.debug(
                                PERMISSIONS_TAG,
                                "User denied permission %s",
                                permission
                        )
                        return
                    }
                    i++
                }
                Logger.debug(
                        PERMISSIONS_TAG,
                        "User granted requested permissions, attempt to switch on Lantern"
                )
                try {
                    switchLantern(true)
                } catch (e: java.lang.Exception) {
                    Logger.error(PERMISSIONS_TAG, "Unable to switch on Lantern", e)
                }
                return
            }
        }
    }

    override fun onActivityResult(request: Int, response: Int, data: Intent?) {
        super.onActivityResult(request, response, data)
        if (request == REQUEST_VPN) {
            val useVpn = response == RESULT_OK
            updateStatus(useVpn)
            if (useVpn) {
                startVpnService()
            }
        }
    }

    private fun startVpnService() {
        startService(
                Intent(
                        this,
                        LanternVpnService::class.java
                ).setAction(LanternVpnService.ACTION_CONNECT)
        )
    }

    private fun stopVpnService() {
        startService(
                Intent(
                        this,
                        LanternVpnService::class.java
                ).setAction(LanternVpnService.ACTION_DISCONNECT)
        )
    }

    private fun updateStatus(useVpn: Boolean) {
        Logger.d(TAG, "Updating VPN status to %1\$s", useVpn)
        EventBus.getDefault().post(VpnState(useVpn))
        LanternApp.getSession().updateVpnPreference(useVpn)
        LanternApp.getSession().updateBootUpVpnPreference(useVpn)
        val handler = Handler(Looper.getMainLooper())
        // Force a delay to test the support for connecting/disconnecting state
        handler.postDelayed({
            vpnModel.setVpnOn(useVpn)
        }, 500)
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName
        private val PERMISSIONS_TAG = "$TAG.permissions"
        private val FULL_PERMISSIONS_REQUEST = 8888
        private val REQUEST_VPN = 7777
    }

//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannel).setMethodCallHandler {
//            // Note: this method is invoked on the main thread.
//            call, result ->
//            when(call.method) {
//                "getUserID" -> result.success(echoSystem.client.userID)
//                "connect" -> try {
//                    echoSystem.connect(call.argument<String>("userID") ?: throw RuntimeException("Missing userID"))
//                    result.success(null)
//                } catch (e: Throwable) {
//                    e.printStackTrace()
//                    result.error("exception", e.localizedMessage, null)
//                }
//                "send" -> {
//                    try {
//                        echoSystem.send(call.argument<String>("userID")!!, call.argument<ByteArray>("message")!!)
//                        result.success(null)
//                    } catch (e: Throwable) {
//                        e.printStackTrace()
//                        result.error("exception", e.localizedMessage, null)
//                    }
//                }
//                else -> result.notImplemented()
//            }
//        }
//
//        // Prepare channel
//        EventChannel(getFlutterEngine()?.dartExecutor, eventsChannel).setStreamHandler(this)
//    }
//
//    override fun onListen(arguments: Any?, events: EventSink?) {
//        echoSystem.client.registerListener({ from: SignalProtocolAddress, plainText: ByteArray ->
//            events?.success(hashMapOf(
//                "from" to from.name,
//                "plainText" to plainText
//            ))
//        })
//    }
//
//    override fun onCancel(arguments: Any?) {
////        TODO("Not yet implemented")
//    }
//
//    companion object {
//        private val methodChannel = "methods"
//        private val eventsChannel = "events"
//
//        private val echoSystem = EchoSystem()
//    }

}

