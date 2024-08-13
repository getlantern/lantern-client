package org.getlantern.lantern


import android.annotation.SuppressLint
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.Html
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import internalsdk.SessionModelOpts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.model.MessagingModel
import io.lantern.model.ReplicaModel
import io.lantern.model.SessionModel
import io.lantern.model.VpnModel
import kotlinx.coroutines.*
import org.getlantern.lantern.activity.WebViewActivity
import org.getlantern.lantern.event.AppEvent
import org.getlantern.lantern.event.AppEvent.*
import org.getlantern.lantern.event.EventHandler
import org.getlantern.lantern.event.EventManager
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.lantern.notification.NotificationReceiver
import org.getlantern.lantern.plausible.Plausible
import org.getlantern.lantern.service.LanternService
import org.getlantern.lantern.util.DeviceUtil
import org.getlantern.lantern.util.PermissionUtil
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.Event
import org.getlantern.mobilesdk.model.Survey
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.*

class MainActivity :
    FlutterActivity(),
    MethodChannel.MethodCallHandler,
    CoroutineScope by MainScope() {
    private lateinit var messagingModel: MessagingModel
    private lateinit var vpnModel: VpnModel
    private lateinit var sessionModel: SessionModel
    private lateinit var replicaModel: ReplicaModel
    private lateinit var eventManager: EventManager
    private lateinit var flutterNavigation: MethodChannel
    private lateinit var notifications: NotificationHelper
    private lateinit var receiver: NotificationReceiver
    private var accountInitDialog: AlertDialog? = null
    private var lastSurvey: Survey? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine,
    ) {
        val start = System.currentTimeMillis()
        super.configureFlutterEngine(flutterEngine)
        messagingModel = MessagingModel(this, flutterEngine, LanternApp.messaging.messaging)
        vpnModel = VpnModel(flutterEngine, ::switchLantern)
        val opts = SessionModelOpts()
        opts.lang = DeviceUtil.getLanguageCode(this)
        opts.deviceID = DeviceUtil.deviceId(this)
        opts.model = DeviceUtil.model()
        opts.osVersion = DeviceUtil.deviceOs()
        opts.playVersion = DeviceUtil.isStoreVersion(this)
        opts.device = DeviceUtil.model()
        opts.platform = DeviceUtil.devicePlatform()
        opts.developmentMode = BuildConfig.DEVELOPMENT_MODE
        opts.timeZone = TimeZone.getDefault().displayName
        sessionModel = SessionModel(this, flutterEngine, opts)
        replicaModel = ReplicaModel(this, flutterEngine)
        receiver = NotificationReceiver()
        notifications = NotificationHelper(this, receiver)
        eventManager =
            object : EventManager("lantern_event_channel", flutterEngine) {
                override fun onListen(event: Event) {
                    if (LanternApp.getSession().lanternDidStart()) {
                        Plausible.init(applicationContext)
                        Plausible.enable(true)
                        Logger.debug(TAG, "Plausible initialized")
                        checkIfSurveyAvailable()
                    }
                    LanternApp.getSession().dnsDetector.publishNetworkAvailability()
                }
            }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lantern_method_channel",
        ).setMethodCallHandler(this)

        flutterNavigation =
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "navigation",
            )

        flutterNavigation.setMethodCallHandler { call, _ ->
            if (call.method == "ready") {
                intent.let { intent ->
                    // If the user clicks on a message notification and MainActivity opens in
                    // response, this ensures that we navigate to the corresponding conversation.
                    navigateForIntent(intent)
                }
            }
        }

        Logger.debug(
            TAG,
            "configureFlutterEngine finished at ${System.currentTimeMillis() - start}",
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val start = System.currentTimeMillis()
        super.onCreate(savedInstanceState)
        Logger.debug(TAG, "Default Locale is %1\$s", Locale.getDefault())
        val intent = Intent(this, LanternService::class.java)
        context.startService(intent)
        Logger.debug(TAG, "startService finished at ${System.currentTimeMillis() - start}")
        subscribeAppEvents()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // If the user clicks on a message notification and MainActivity is already the top activity,
        // this ensures that we navigate to the corresponding conversation.
        navigateForIntent(intent)
    }

    private fun subscribeAppEvents() {
        EventHandler.subscribeAppEvents { appEvent ->
            when (appEvent) {
                is AppEvent.AccountInitializationEvent -> onInitializingAccount(appEvent.status)
                else -> {
                    Logger.debug(TAG, "Unknown app event " + appEvent)
                }
            }
        }
    }


    private fun navigateForIntent(intent: Intent) {
        // handles text messaging intent
        intent.getByteArrayExtra("contactForConversation")?.let { contact ->
            flutterNavigation.invokeMethod("openConversation", contact)
            intent.removeExtra("contactForConversation")
        }
    }

    @SuppressLint("WrongConstant")
    override fun onStart() {
        super.onStart()
        val packageName = activity.packageName
        IntentFilter("$packageName.intent.VPN_DISCONNECTED").also {
            ContextCompat.registerReceiver(
                this@MainActivity,
                receiver,
                it,
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
        }
    }

    override fun onStop() {
        super.onStop()
        unregisterReceiver(receiver)
    }

    override fun onResume() {
        val start = System.currentTimeMillis()
        super.onResume()

        val isServiceRunning = Utils.isServiceRunning(activity, LanternVpnService::class.java)
        if (vpnModel.isConnectedToVpn() && !isServiceRunning) {
            Logger.d(TAG, "LanternVpnService isn't running, clearing VPN preference")
            vpnModel.setVpnOn(false)
        } else if (!vpnModel.isConnectedToVpn() && isServiceRunning) {
            Logger.d(TAG, "LanternVpnService is running, updating VPN preference")
            vpnModel.setVpnOn(true)
        }
        Logger.debug(TAG, "onResume() finished at ${System.currentTimeMillis() - start}")
    }

    override fun onDestroy() {
        super.onDestroy()
        accountInitDialog?.let { it.dismiss() }
        vpnModel.destroy()
        sessionModel.destroy()
        replicaModel.destroy()
        messagingModel.destroy()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "showLastSurvey" -> {
                showSurvey(lastSurvey!!)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Fetch the latest loconf config and update the UI based on those
     * settings
     */
    private fun checkIfSurveyAvailable() {
        val handler = Handler(Looper.getMainLooper())
        handler.postDelayed({
            try {
                val surveyString = sessionModel.getSurvey()
                Logger.debug("Survey", "Survey string: $surveyString")
                Gson().fromJson(surveyString, Survey::class.java)?.let {
                    sendSurveyEvent(it)
                }
            } catch (e: Exception) {
                Logger.error("Survey", "Error fetching loconf", e)
            }
        }, 2000L)
    }

    private fun onInitializingAccount(status: AccountInitializationStatus.Status) {
        val appName = getString(R.string.app_name)
        when (status) {
            AccountInitializationStatus.Status.PROCESSING -> {
                accountInitDialog = AlertDialog.Builder(this).create()
                accountInitDialog?.setCancelable(false)
                val inflater: LayoutInflater = this.layoutInflater
                val dialogView = inflater.inflate(R.layout.init_account_dialog, null)
                accountInitDialog?.setView(dialogView)
                val tvMessage: TextView = dialogView.findViewById(R.id.tvMessage)
                tvMessage.text = getString(R.string.init_account, appName)
                dialogView.findViewById<View>(R.id.btnCancel).setOnClickListener {
                    accountInitDialog?.dismiss()
                    finish()
                }
                accountInitDialog?.show()
            }

            AccountInitializationStatus.Status.SUCCESS -> {
                accountInitDialog?.let { it.dismiss() }
            }

            AccountInitializationStatus.Status.FAILURE -> {
                accountInitDialog?.let { it.dismiss() }

                Utils.showAlertDialog(
                    this,
                    getString(R.string.connection_error),
                    getString(R.string.reopen_to_try, appName),
                    getString(R.string.ok),
                    true,
                    null,
                    false,
                )
            }
        }
    }

    private fun sendSurveyEvent(survey: Survey) {
        val url = survey.url
        if (url != "") {
            if (LanternApp.getSession().checkIfSurveyLinkOpened(url)) {
                Logger.debug(
                    TAG,
                    "User already opened link to survey; not displaying snackbar",
                )
                return
            }
        }
        lastSurvey = survey
        Logger.debug(TAG, "Sending events to UI")
        eventManager.onNewEvent(
            Event.SurveyAvailable,
            hashMapOf("message" to survey.message, "buttonText" to survey.button),
        )
    }

    private fun showSurvey(survey: Survey) {
        val intent = Intent(this, WebViewActivity::class.java)
        intent.putExtra("url", survey.url)
        startActivity(intent)
        LanternApp.getSession().setSurveyLinkOpened(survey.url)
    }

    @Throws(Exception::class)
    private fun switchLantern(on: Boolean) {
        Logger.d(TAG, "switchLantern to %1\$s", on)

        // disable the on/off switch while the VpnService
        // is updating the connection
        if (on) {
            // Make sure we have the necessary permissions
            val neededPermissions: Array<String> = PermissionUtil.missingPermissions(context)
            if (neededPermissions.isNotEmpty()) {
                val msg = StringBuilder()
                for (permission in neededPermissions) {
                    if (!PermissionUtil.hasPermission(permission, context)) {
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
                                nmfe,
                            )
                            msg.append(permission)
                        }
                        msg.append("</b>&nbsp;")
                        msg.append(getString(R.string.permission_for))
                        msg.append("&nbsp;")
                        var description = "..."
                        try {
                            description =
                                getString(
                                    resources.getIdentifier(
                                        permission,
                                        "string",
                                        "org.getlantern.lantern",
                                    ),
                                )
                        } catch (t: Throwable) {
                            Logger.warn(
                                PERMISSIONS_TAG,
                                "Couldn't get permission description for %s: %s",
                                permission,
                                t,
                            )
                        }
                        msg.append(description)
                        msg.append("</p>")
                    }
                }
                Logger.debug(
                    PERMISSIONS_TAG,
                    msg.toString(),
                )
                showAlertDialog(
                    title = getString(R.string.please_allow_lantern_to),
                    msg = Html.fromHtml(msg.toString()),
                    okLabel = getString(R.string.continue_),
                    onClick = {
                        ActivityCompat.requestPermissions(
                            this,
                            neededPermissions,
                            FULL_PERMISSIONS_REQUEST,
                        )
                    },
                )
                return
            }

            // Prompt the user to enable full-device VPN mode
            // Make a VPN connection from the client
            Logger.debug(
                TAG,
                "Load VPN configuration",
            )
            val intent = VpnService.prepare(this)
            if (intent != null) {
                Logger.warn(
                    TAG,
                    "Requesting VPN connection",
                )
                startActivityForResult(intent, REQUEST_VPN)
            } else {
                Logger.debug(
                    TAG,
                    "VPN enabled, starting Lantern...",
                )
                // If user come here it mean user has all permissions needed
                // Also user given permission for VPN service dialog as well
                LanternApp.getSession().setHasAllNetworkPermissions(true)
                updateStatus(true)
                startVpnService()
            }
        } else {
            sendBroadcast(notifications.disconnectIntent())
            // Update VPN status
            vpnModel.updateStatus(false)
        }
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
                    grantResults.size,
                )
                var i = 0
                while (i < permissions.size) {
                    val permission = permissions[i]
                    val result = grantResults[i]
                    if (result == PackageManager.PERMISSION_DENIED) {
                        Logger.debug(
                            PERMISSIONS_TAG,
                            "User denied permission %s",
                            permission,
                        )
                        return
                    }
                    i++
                }
                Logger.debug(
                    PERMISSIONS_TAG,
                    "User granted requested permissions, attempt to switch on Lantern",
                )
                try {
                    switchLantern(true)
                } catch (e: java.lang.Exception) {
                    Logger.error(PERMISSIONS_TAG, "Unable to switch on Lantern", e)
                }
                return
            }

            else -> super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }

    override fun onActivityResult(
        request: Int,
        response: Int,
        data: Intent?,
    ) {
        super.onActivityResult(request, response, data)
        if (request == REQUEST_VPN) {
            val useVpn = response == RESULT_OK
            updateStatus(useVpn)
            if (useVpn) {
                startVpnService()
                // This check is for new user that will start app first time
                // this mean user has already given
                // system permissions
                LanternApp.getSession().setHasAllNetworkPermissions(true)
//                sessionModel.checkAdsAvailability()
            }
        }
    }

    private fun startVpnService() {
        val intent: Intent =
            Intent(
                this,
                LanternVpnService::class.java,
            ).apply {
                action = LanternVpnService.ACTION_CONNECT
            }

        startService(intent)
        notifications.vpnConnectedNotification()
    }

    private fun updateStatus(useVpn: Boolean) {
        Logger.d(TAG, "Updating VPN status to %1\$s", useVpn)
//        LanternApp.getSession().updateVpnPreference(useVpn)
//        LanternApp.getSession().updateBootUpVpnPreference(useVpn)
        vpnModel.updateStatus(useVpn)
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName
        private val SURVEY_TAG = "$TAG.survey"
        private val PERMISSIONS_TAG = "$TAG.permissions"
        private val FULL_PERMISSIONS_REQUEST = 8888
        val RECORD_AUDIO_PERMISSIONS_REQUEST = 8889
        private val REQUEST_VPN = 7777
    }
}
