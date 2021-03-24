package org.getlantern.lantern

import android.Android
import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.*
import android.text.Html
import android.view.View
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import com.thefinestartist.finestwebview.FinestWebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.lantern.android.model.SessionModel
import io.lantern.android.model.VpnModel
import okhttp3.Response
import org.getlantern.lantern.activity.PopUpAdActivity_
import org.getlantern.lantern.activity.PrivacyDisclosureActivity_
import org.getlantern.lantern.activity.UpdateActivity_
import org.getlantern.lantern.model.*
import org.getlantern.lantern.model.LanternHttpClient.ProUserCallback
import org.getlantern.lantern.service.LanternService_
import org.getlantern.lantern.vpn.LanternVpnService
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.*
import org.getlantern.mobilesdk.model.LoConf.Companion.fetch
import org.getlantern.mobilesdk.model.Utils
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.util.*

class MainActivity : FlutterActivity() {

    private lateinit var vpnModel: VpnModel
    private lateinit var sessionModel: SessionModel
    private lateinit var navigator: Navigator

    private val lanternClient = LanternApp.getLanternHttpClient()

    private var countDown: AuctionCountDown? = null

    private lateinit var appVersion: String

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        vpnModel = VpnModel(flutterEngine, ::switchLantern)
        sessionModel = SessionModel(flutterEngine)
        navigator = Navigator(this, flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Logger.debug(TAG, "Default Locale is %1\$s", Locale.getDefault())
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this)
        }

        val intent = Intent(this, LanternService_::class.java)
        bindService(intent, lanternServiceConnection, BIND_AUTO_CREATE)

        appVersion = Utils.appVersion(this)
    }

    override fun onResume() {
        // TODO [issue42] migrate to MainActivity
//        if (LanternApp.getSession().yinbiEnabled()) {
//            bulkRenewSection.setVisibility(View.VISIBLE)
//        } else {
//            val tab = viewPagerTab.getTabAt(Constants.YINBI_AUCTION_TAB)
//            if (tab != null) {
//                tab.visibility = View.GONE
//            }
//        }

        updateUserData()

        super.onResume()

        if (LanternApp.getSession().lanternDidStart()) {
            fetchLoConf()
        }

        if (Utils.isPlayVersion(this)) {
            if (!LanternApp.getSession().hasAcceptedTerms()) {
                startActivity(Intent(this, PrivacyDisclosureActivity_::class.java))
            }
        }

        if (vpnModel.isConnectedToVpn() && !Utils.isServiceRunning(
                activity,
                LanternVpnService::class.java
            )
        ) {
            Logger.d(TAG, "LanternVpnService isn't running, clearing VPN preference")
            vpnModel.setVpnOn(false)
        }
    }

    override fun onPause() {
        super.onPause()
        // stop auction countdown
        countDown?.cancel()
        countDown = null
    }

    override fun onDestroy() {
        super.onDestroy()
        vpnModel.destroy()
        sessionModel.destroy()
        EventBus.getDefault().unregister(this)
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

    /**
     * Fetch the latest loconf config and update the UI based on those
     * settings
     */
    private fun fetchLoConf() {
        fetch { loconf -> runOnUiThread { processLoconf(loconf) } }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun lanternStarted(status: LanternStatus) {
        updateUserData()
    }

    private fun updateUserData() {
        lanternClient.userData(object : ProUserCallback {

            override fun onFailure(throwable: Throwable, error: ProError) {
                Logger.error(TAG, "Unable to fetch user data", throwable)
            }

            override fun onSuccess(response: Response, user: ProUser?) {
                runOnUiThread {
                    user?.let {
                        val yinbiEnabled = user.yinbiEnabled
                        if (yinbiEnabled) {
                            setYinbiAuctionInfo()
                        }
                        LanternApp.getSession().setYinbiEnabled(yinbiEnabled)
                    }
                }
            }
        })
    }

    private fun setYinbiAuctionInfo() {
        // TODO [issue42] migrate to MainActivity
//        val tab = viewPagerTab.getTabAt(Constants.YINBI_AUCTION_TAB) as View
//            ?: return
//        val title = tab.findViewById<View>(R.id.tabText) as TextView
//        if (countDown != null && countDown!!.isRunning) {
//            return
//        }
//        lanternClient.getYinbiAuctionInfo(
//            AuctionInfoCallback { info ->
//                if (info == null || info.timeLeft == null) {
//                    return@AuctionInfoCallback
//                }
//                EventBus.getDefault().post(info)
//                runOnUiThread {
//                    countDown = AuctionCountDown(info, title)
//                    countDown!!.start()
//                }
//            })
    }

    fun showSurvey(survey: Survey) {
        val url = survey.url
        if (url != null && url != "") {
            if (LanternApp.getSession().surveyLinkOpened(url)) {
                Logger.debug(
                    TAG,
                    "User already opened link to survey; not displaying snackbar"
                )
                return
            }
        }
        val surveyListener = View.OnClickListener {
            if (survey.showPlansScreen) {
                startActivity(Intent(this@MainActivity, LanternApp.getSession().plansActivity()))
                return@OnClickListener
            }
            LanternApp.getSession().setSurveyLinkOpened(survey.url)
            FinestWebView.Builder(this@MainActivity)
                .webViewLoadWithProxy(LanternApp.getSession().hTTPAddr)
                .webViewSupportMultipleWindows(true)
                .webViewJavaScriptEnabled(true)
                .swipeRefreshColorRes(R.color.black)
                .webViewAllowFileAccessFromFileURLs(true)
                .webViewJavaScriptCanOpenWindowsAutomatically(true)
                .show(survey.url!!)
        }
        Logger.debug(TAG, "Showing user survey snackbar")
        // TODO [issue42] migrate to MainActivity
//        org.getlantern.lantern.model.Utils.showSnackbar(
//            coordinatorLayout, survey.message, survey.button,
//            resources.getColor(R.color.pink), Snackbar.LENGTH_INDEFINITE, surveyListener
//        )
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun processLoconf(loconf: LoConf) {
        doProcessLoconf(loconf)
        if (loconf.ads != null) {
            handleBannerAd(loconf.ads!!)
        }
    }

    private fun doProcessLoconf(loconf: LoConf) {
        val locale = LanternApp.getSession().language
        val countryCode = LanternApp.getSession().countryCode
        Logger.debug(
            SURVEY_TAG,
            "Processing loconf; country code is $countryCode"
        )
        if (loconf.popUpAds != null) {
            handlePopUpAd(loconf.popUpAds!!)
        }
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
            key = countryCode.toLowerCase()
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
                survey.url
            )
            val userType = survey.userType
            if (userType != null) {
                if (userType == "free" && LanternApp.getSession().isProUser) {
                    Logger.debug(
                        SURVEY_TAG,
                        "Not showing messages targetted to free users to Pro users"
                    )
                    return
                } else if (userType == "pro" && !LanternApp.getSession().isProUser) {
                    Logger.debug(
                        SURVEY_TAG,
                        "Not showing messages targetted to free users to Pro users"
                    )
                    return
                }
            }
            showSurvey(survey)
        }
    }

    /**
     * Check if a popup ad is enabled for the current region or language
     * and display the corresponding ad to the user if so
     * @param popUpAds the popUpAds as defined in loconf
     */
    private fun handlePopUpAd(popUpAds: Map<String, PopUpAd>) {
        var popUpAd = popUpAds[LanternApp.getSession().countryCode]
        if (popUpAd == null) {
            popUpAd = popUpAds[LanternApp.getSession().language]
        }
        if (popUpAd == null || !popUpAd.enabled) {
            return
        }
        if (!LanternApp.getSession().hasPrefExpired("popUpAd")) {
            Logger.debug(
                TAG,
                "Not showing popup ad: not enough time has elapsed since it was last shown to the user"
            )
            return
        }
        Logger.debug(TAG, "Displaying popup ad..")
        val numSeconds = popUpAd.displayFrequency
        LanternApp.getSession().saveExpiringPref("popUpAd", numSeconds!!)
        val intent = Intent(this, PopUpAdActivity_::class.java)
        intent.putExtra("popUpAdStr", Gson().toJson(popUpAd))
        startActivity(intent)
    }

    /**
     * Check if the banner ad for our region or language is enabled and display. Returns true if ad
     * was displayed.
     *
     * @param ads the ads as defined in loconf
     */
    private fun handleBannerAd(ads: Map<String, BannerAd>): Boolean {
        // TODO [issue42] migrate to MainActivity
//        var ad = ads[LanternApp.getSession().countryCode]
//        if (ad == null) {
//            ad = ads[LanternApp.getSession().language]
//        }
//        if (ad != null && ad.enabled) {
//            val adUrl = ad.url
//            Logger.debug(
//                TAG,
//                "Displaying banner ad with url " + adUrl + " " + ad.text
//            )
//            yinbiAdText.setText(ad.text)
//            //Utils.setMargins(viewPagerTab, 125, 450, 0, 0);
//            org.getlantern.lantern.model.Utils.clickify(
//                yinbiWebsite, getString(R.string.visit_yinbi_website)
//            ) {
//                val intent = Intent(this@MainActivity, WebViewActivity_::class.java)
//                intent.putExtra("url", adUrl)
//                startActivity(intent)
//                Lantern.sendEvent(this@MainActivity, "yinbi_link_clicked_on")
//            }
//            yinbiWebsite.setPaintFlags(0)
//            Lantern.sendEvent(this, "yinbi_ad_shown")
//            yinbiAdLayout.setVisibility(View.VISIBLE)
//            return true
//        }
        return false
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun runCheckUpdate(checkUpdate: CheckUpdate) {
        val userInitiated = checkUpdate.userInitiated
        if (Utils.isPlayVersion(this)) {
            Logger.debug(TAG, "App installed via Play; not checking for update")
            if (userInitiated) {
                // If the user installed the app via Google Play,
                // we just open the Play store
                // because self-updating will not work:
                // "An app downloaded from Google Play may not modify,
                // replace, or update itself
                // using any method other than Google Play's update mechanism"
                // https://play.google.com/about/privacy-and-security.html#malicious-behavior
                Utils.openPlayStore(this)
            }
            return
        }
        UpdateTask(this, userInitiated).execute()
    }

    /**
     * UpdateTask compares the current app version with the latest available
     * If an update is available, we start the Update activity
     * and prompt the user to download it
     * - If no update is available, an alert dialog is displayed
     * - userInitiated is a boolean used to indicate whether the udpate was
     * triggered from the side-menu or is an automatic check
     */
    private inner class UpdateTask(
        private val activity: Activity,
        private val userInitiated: Boolean
    ) :
        AsyncTask<Void, Void, String?>() {

        override fun doInBackground(vararg v: Void): String? {
            try {
                Logger.debug(TAG, "Checking for updates")
                return Android.checkForUpdates()
            } catch (e: java.lang.Exception) {
                Logger.error(TAG, "Error checking for update", e)
            }
            return null
        }

        override fun onPostExecute(url: String?) {
            // No error occurred but the returned url is empty which
            // means no update is available
            if (url == null) {
                val appName: String = resources.getString(R.string.app_name)
                val message: String = String.format(
                    resources.getString(R.string.error_checking_for_update),
                    appName
                )
//                Utils.showAlertDialog(activity, appName, message, false) // TODO [issue42] migrate to MainActivity
                return
            }
            if (url == "") {
                noUpdateAvailable(userInitiated)
                Logger.debug(TAG, "No update available")
                return
            }
            Logger.debug(
                TAG,
                "Update available at $url"
            )
            // an updated version of Lantern is available at the given url
            val intent = Intent(activity, UpdateActivity_::class.java)
            intent.putExtra("updateUrl", url)
            startActivity(intent)
        }
    }

    private fun noUpdateAvailable(showAlert: Boolean) {
        if (!showAlert) {
            return
        }
        val appName = resources.getString(R.string.app_name)
        val noUpdateTitle = resources.getString(R.string.no_update_available)
        val noUpdateMsg =
            String.format(resources.getString(R.string.have_latest_version), appName, appVersion)
//        Utils.showAlertDialog(this, noUpdateTitle, noUpdateMsg, false) // TODO [issue42] migrate to MainActivity
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
                // TODO [issue42] migrate to MainActivity
//                Utils.showAlertDialog(this,
//                    getString(R.string.please_allow_lantern_to),
//                    Html.fromHtml(msg.toString()),
//                    getString(R.string.continue_),
//                    false,
//                    Runnable {
//                        ActivityCompat.requestPermissions(
//                            this,
//                            neededPermissions,
//                            FULL_PERMISSIONS_REQUEST
//                        )
//                    })
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

