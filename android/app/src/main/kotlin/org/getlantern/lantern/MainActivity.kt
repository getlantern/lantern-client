package org.getlantern.lantern

import android.annotation.SuppressLint
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Bundle
import android.text.Html
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.annotation.NonNull
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.lantern.model.MessagingModel
import io.lantern.model.ReplicaModel
import io.lantern.model.SessionModel
import io.lantern.model.Vpn
import io.lantern.model.VpnModel
import kotlinx.coroutines.*
import okhttp3.Response
import org.getlantern.lantern.activity.WebViewActivity_
import org.getlantern.lantern.event.EventManager
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.Bandwidth
import org.getlantern.lantern.model.LanternHttpClient.PlansV3Callback
import org.getlantern.lantern.model.LanternHttpClient.ProUserCallback
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.PaymentMethods
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.model.ProUser
import org.getlantern.lantern.model.Stats
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.model.VpnState
import org.getlantern.lantern.notification.NotificationHelper
import org.getlantern.lantern.notification.NotificationReceiver
import org.getlantern.lantern.plausible.Plausible
import org.getlantern.lantern.service.LanternService_
import org.getlantern.lantern.util.PermissionUtil
import org.getlantern.lantern.util.PlansUtil
import org.getlantern.lantern.util.restartApp
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.Event
import org.getlantern.mobilesdk.model.LoConf
import org.getlantern.mobilesdk.model.LoConf.Companion.fetch
import org.getlantern.mobilesdk.model.Survey
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.util.Locale
import java.util.concurrent.*

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler,
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
    private var autoUpdateJob: Job? = null
    private val lanternClient = LanternApp.getLanternHttpClient()

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine,
    ) {
        val start = System.currentTimeMillis()
        super.configureFlutterEngine(flutterEngine)
        messagingModel = MessagingModel(this, flutterEngine, LanternApp.messaging.messaging)
        vpnModel = VpnModel(flutterEngine, ::switchLantern)
        sessionModel = SessionModel(this, flutterEngine)
        replicaModel = ReplicaModel(this, flutterEngine)
        receiver = NotificationReceiver()
        notifications = NotificationHelper(this, receiver)
        eventManager = object : EventManager("lantern_event_channel", flutterEngine) {
            override fun onListen(event: Event) {
                if (LanternApp.getSession().lanternDidStart()) {
                    Plausible.init(applicationContext)
                    Logger.debug(TAG, "Plausible initialized")
                    Plausible.enable(true)
                    fetchLoConf()
                    Logger.debug(
                        TAG,
                        "fetchLoConf() finished at ${System.currentTimeMillis() - start}",
                    )
                }
                LanternApp.getSession().dnsDetector.publishNetworkAvailability()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lantern_method_channel",
        ).setMethodCallHandler(this)

        flutterNavigation = MethodChannel(
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

        // if not in dev mode, prevent screenshots of this activity by other apps
        if (!BuildConfig.DEVELOPMENT_MODE) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }

        Logger.debug(TAG, "Default Locale is %1\$s", Locale.getDefault())
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this)
        }
        Logger.debug(TAG, "EventBus.register finished at ${System.currentTimeMillis() - start}")

        val intent = Intent(this, LanternService_::class.java)
        context.startService(intent)
        Logger.debug(TAG, "startService finished at ${System.currentTimeMillis() - start}")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // If the user clicks on a message notification and MainActivity is already the top activity,
        // this ensures that we navigate to the corresponding conversation.
        navigateForIntent(intent)
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

        sessionModel.checkAdsAvailability()
        Logger.debug(TAG, "onResume() finished at ${System.currentTimeMillis() - start}")
    }

    override fun onDestroy() {
        super.onDestroy()
        accountInitDialog?.let { it.dismiss() }
        vpnModel.destroy()
        sessionModel.destroy()
        replicaModel.destroy()
        EventBus.getDefault().unregister(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "showLastSurvey" -> {
                showSurvey(lastSurvey)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Fetch the latest loconf config and update the UI based on those
     * settings
     */
    private fun fetchLoConf() {
        fetch { loconf -> runOnUiThread { processLoconf(loconf) } }
    }

    @Subscribe(sticky = true, threadMode = ThreadMode.MAIN)
    fun onInitializingAccount(status: AccountInitializationStatus) {
        val appName = getString(R.string.app_name)

        when (status.status) {
            AccountInitializationStatus.Status.PROCESSING -> {
                accountInitDialog = AlertDialog.Builder(this).create()
                accountInitDialog?.setCancelable(false)
                val inflater: LayoutInflater = this.layoutInflater
                val dialogView = inflater.inflate(R.layout.init_account_dialog, null)
                accountInitDialog?.setView(dialogView)
                val tvMessage: TextView = dialogView.findViewById(R.id.tvMessage)
                tvMessage.text = getString(R.string.init_account, appName)
                dialogView.findViewById<View>(R.id.btnCancel).setOnClickListener {
                    EventBus.getDefault().removeStickyEvent(status)
                    accountInitDialog?.dismiss()
                    finish()
                }
                accountInitDialog?.show()
            }

            AccountInitializationStatus.Status.SUCCESS -> {
                EventBus.getDefault().removeStickyEvent(status)
                accountInitDialog?.let { it.dismiss() }
            }

            AccountInitializationStatus.Status.FAILURE -> {
                EventBus.getDefault().removeStickyEvent(status)
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

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun vpnStateChanged(state: VpnState) {
        updateStatus(state.useVpn)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun lanternStarted(status: LanternStatus) {
        updateUserData()
        updatePaymentMethods()
    }

    @Subscribe(sticky = true, threadMode = ThreadMode.MAIN)
    fun onEvent(event: Event) {
        eventManager.onNewEvent(event = event)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun statsUpdated(stats: Stats) {
        Logger.debug("Stats updated", stats.toString())
        sessionModel.saveServerInfo(
            Vpn.ServerInfo.newBuilder().setCity(stats.city).setCountry(stats.country)
                .setCountryCode(stats.countryCode).build(),
        )
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun bandwidthUpdated(bandwidth: Bandwidth) {
        Logger.debug("bandwidth updated", bandwidth.toString())
        vpnModel.updateBandwidth(bandwidth)
    }

    private fun updateUserData() {
        lanternClient.userData(
            object : ProUserCallback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    Logger.error(TAG, "Unable to fetch user data: $error", throwable)
                }

                override fun onSuccess(
                    response: Response,
                    user: ProUser,
                ) {
                    // save latest user data
                    LanternApp.getSession().storeUserData(user)
                }
            },
        )
    }

    private fun updatePaymentMethods() {
        lanternClient.plansV4(
            object : PlansV3Callback {
                override fun onFailure(
                    throwable: Throwable?,
                    error: ProError?,
                ) {
                    Logger.error(TAG, "Unable to fetch payment methods: $error", throwable)
                }

                override fun onSuccess(
                    proPlans: Map<String, ProPlan>,
                    paymentMethods: List<PaymentMethods>,

                    ) {
                    Logger.debug(TAG, "Successfully fetched payment methods with payment methods: $paymentMethods and plans $proPlans")
                    processPaymentMethods(proPlans, paymentMethods)
                }
            }
        )
    }


    fun processPaymentMethods(
        proPlans: Map<String, ProPlan>,
        paymentMethods: List<PaymentMethods>,

        ) {
        for (planId in proPlans.keys) {
            proPlans[planId]?.let { PlansUtil.updatePrice(activity, it) }
        }
        LanternApp.getSession().setUserPlans(proPlans)
        LanternApp.getSession().setPaymentMethods(paymentMethods)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun processLoconf(loconf: LoConf) {
        doProcessLoconf(loconf)
    }

    private fun doProcessLoconf(loconf: LoConf) {
        val locale = LanternApp.getSession().language
        val countryCode = LanternApp.getSession().countryCode
        Logger.debug(
            SURVEY_TAG,
            "Processing loconf; country code is $countryCode",
        )
        if (loconf.surveys == null) {
            Logger.debug(SURVEY_TAG, "No survey config")
            return
        }
        for (key in loconf.surveys!!.keys) {
            Logger.debug(SURVEY_TAG, "Survey: " + loconf.surveys!![key])
        }
        var key = countryCode
        var survey = loconf.surveys!![key]
        if (survey == null) {
            key = countryCode.lowercase()
            survey = loconf.surveys!![key]
        }
        if (survey == null || !survey.enabled) {
            key = locale
            survey = loconf.surveys!![key]
        }
        if (survey == null) {
            Logger.debug(SURVEY_TAG, "No survey found")
        } else if (!survey.enabled) {
            Logger.debug(SURVEY_TAG, "Survey disabled")
        } else if (Math.random() > survey.probability) {
            Logger.debug(SURVEY_TAG, "Not showing survey this time")
        } else {
            Logger.debug(
                SURVEY_TAG,
                "Deciding whether to show survey for '%s' at %s",
                key,
                survey.url,
            )
            val userType = survey.userType
            if (userType != null) {
                if (userType == "free" && LanternApp.getSession().isProUser) {
                    Logger.debug(
                        SURVEY_TAG,
                        "Not showing messages targetted to free users to Pro users",
                    )
                    return
                } else if (userType == "pro" && !LanternApp.getSession().isProUser) {
                    Logger.debug(
                        SURVEY_TAG,
                        "Not showing messages targetted to free users to Pro users",
                    )
                    return
                }
            }
            showSurveySnackbar(survey)
        }
    }

    fun showSurveySnackbar(survey: Survey) {
        val url = survey.url
        if (url != null && url != "") {
            if (LanternApp.getSession().surveyLinkOpened(url)) {
                Logger.debug(
                    TAG,
                    "User already opened link to survey; not displaying snackbar",
                )
                return
            }
        }
        lastSurvey = survey
        Logger.debug(TAG, "Showing user survey snackbar")
        eventManager.onNewEvent(
            Event.SurveyAvailable,
            hashMapOf("message" to survey.message, "buttonText" to survey.button),
        )
    }

    private var lastSurvey: Survey? = null

    private fun showSurvey(survey: Survey?) {
        survey ?: return
        val intent = Intent(this, WebViewActivity_::class.java)
        intent.putExtra("url", survey.url!!)
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
                            description = getString(
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
                LanternApp.getSession().setHasFirstSessionCompleted(true)
                sessionModel.checkAdsAvailability()
                updateStatus(true)
                startVpnService()
            }
        } else {
            sendBroadcast(notifications.disconnectIntent())
            //Update VPN status
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
                LanternApp.getSession().setHasFirstSessionCompleted(true)
                sessionModel.checkAdsAvailability()
            }
        }
    }

    private fun startVpnService() {
        val intent: Intent = Intent(
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
        LanternApp.getSession().updateVpnPreference(useVpn)
        LanternApp.getSession().updateBootUpVpnPreference(useVpn)
        vpnModel.updateStatus(useVpn)
    }

    // Recreate the activity when the language changes
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun languageChanged(locale: Locale) {
        recreate()
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
