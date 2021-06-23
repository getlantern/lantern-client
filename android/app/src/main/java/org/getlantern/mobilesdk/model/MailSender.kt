package org.getlantern.mobilesdk.model

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.os.AsyncTask
import android.os.Build
import internalsdk.EmailMessage
import internalsdk.EmailResponseHandler
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger

class MailSender @JvmOverloads constructor(
    private val context: Context,
    private val template: String,
    private val showProgress: Boolean,
    private val finish: Boolean,
    private val title: String? = null,
    private val message: String? = null
) : AsyncTask<String, Void, Boolean>(), EmailResponseHandler {
    private var dialog: ProgressDialog? = null
    private val userEmail: String
    private val appVersion: String
    private val sendLogs: Boolean
    private val mergeValues: MutableMap<String, String> = HashMap()
    fun addMergeVar(name: String, value: String) {
        mergeValues[name] = value
    }

    override fun onError(message: String) {
        try {
            (context as Activity).showErrorDialog(message)
        } catch (e: Exception) {
            Logger.error(TAG, "Unable to show error message sending email: ", e)
        }
    }

    override fun onPreExecute() {
        dialog?.let { dialog ->
            dialog.setMessage(context.resources.getString(R.string.sending_request))
            dialog.show()
        }
    }

    protected override fun doInBackground(vararg params: String): Boolean {
        val msg = EmailMessage()
        msg.template = template
        if (sendLogs) {
            msg.subject = params[0]
            msg.from = userEmail
            msg.maxLogSize = "10MB"
            msg.putInt("userid", LanternApp.getSession().userID)
            msg.putString("protoken", LanternApp.getSession().token)
            msg.putString("deviceid", LanternApp.getSession().deviceID)
            msg.putString("emailaddress", userEmail)
            msg.putString("appversion", "${getAppName()} $appVersion")
            msg.putString("prouser", LanternApp.getSession().isProUser.toString())
            msg.putString("androiddevice", Build.DEVICE)
            msg.putString("androidmodel", Build.MODEL)
            msg.putString("androidversion", "" + Build.VERSION.SDK_INT + " (" + Build.VERSION.RELEASE + ")")
        } else {
            msg.to = params[0]
            if (template == "manual-recover-account") {
                msg.putInt("userid", LanternApp.getSession().userID)
                msg.putString("usertoken", LanternApp.getSession().token)
                msg.putString("deviceid", LanternApp.getSession().deviceID)
                msg.putString("deviceName", LanternApp.getSession().deviceName())
                msg.putString("email", userEmail)
                msg.putString("referralCode", LanternApp.getSession().code())
            }
        }
        for ((key, value) in mergeValues) {
            msg.putString(key, value)
        }
        try {
            msg.send(this)
        } catch (e: Exception) {
            Logger.error(TAG, "Error trying to send mail: ", e)
            return false
        }
        return true
    }

    private fun getResponseMessage(success: Boolean): String {
        val msg: Int
        msg = if (success) {
            Logger.debug(TAG, "Successfully called send mail")
            if (sendLogs) R.string.success_log_email else R.string.success_email
        } else {
            if (sendLogs) R.string.error_log_email else R.string.error_email
        }
        return context.resources.getString(msg).format(getAppName())
    }

    private fun getAppName(): String {
        return context.resources.getString(R.string.app_name)
    }

    override fun onPostExecute(success: Boolean) {
        super.onPostExecute(success)
        dialog?.let { dialog ->
            if (dialog.isShowing()) {
                dialog.dismiss()
            }
        }
        if (showProgress) {
            (context as Activity).showAlertDialog(
                title ?: getAppName(),
                message ?: getResponseMessage(success),
                finish = finish
            )
        }
    }

    companion object {
        private val TAG = MailSender::class.java.name
    }

    init {
        appVersion = Utils.appVersion(context)
        userEmail = LanternApp.getSession().email()
        sendLogs = template == "user-send-logs"
        if (showProgress) {
            dialog = ProgressDialog(context)
            dialog!!.setCancelable(false)
            dialog!!.setCanceledOnTouchOutside(false)
        }
    }
}
