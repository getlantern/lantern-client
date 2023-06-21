package org.getlantern.mobilesdk.model

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.os.AsyncTask
import android.os.Build
import internalsdk.EmailMessage
import internalsdk.EmailResponseHandler
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.mobilesdk.Logger

// MailSender calls Go's `internalsdk/email.go:EmailMessage.Send()` method to
// actually send emails through the github.com/getlantern/mandrill package. If
// successful, onSuccess() callback would trigger, else onError()
class MailSender @JvmOverloads constructor(
    private val context: Context,
    private val template: String,
    private val title: String? = null,
    private val message: String? = null,
    private val methodCallResult: MethodChannel.Result? = null,
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
        dialog?.let { dialog ->
            if (dialog.isShowing()) {
                dialog.dismiss()
            }
        }
        if (methodCallResult != null) {
            methodCallResult.error("errorReportingIssue", message, null)
            return
        }
        (context as Activity).showAlertDialog(
            title ?: getAppName(),
            message ?: message,
            // Don't close the dialog if there's an error. This'll remove the
            // user's input. Let the user close the dialog or try again if they
            // want.
            finish = false,
        )
    }

    override fun onSuccess() {
        dialog?.let { dialog ->
            if (dialog.isShowing()) {
                dialog.dismiss()
            }
        }
        if (methodCallResult != null) {
            methodCallResult.success("reportedIssue")
            return
        }
        (context as Activity).showAlertDialog(
            title ?: getAppName(),
            message ?: getResponseMessage(),
            // Close the dialog after a successful send.
            finish = true,
        )
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
            // This function calls Go's `internalsdk/email.go:EmailMessage.Send()`.
            // It will call `onSuccess()` or `onError()` when it's done with
            // the request. This function doesn't block or return an error but
            // we're wrapping it with a try-catch just to be safe
            msg.send(this)
        } catch (e: Exception) {
            Logger.error(TAG, "Error trying to send mail: ", e)
            return false
        }
        return true
    }

    private fun getResponseMessage(): String {
        val msg = if (sendLogs) R.string.success_log_email else R.string.success_email
        return context.resources.getString(msg).format(getAppName())
    }

    private fun getAppName(): String {
        return context.resources.getString(R.string.app_name)
    }

    companion object {
        private val TAG = MailSender::class.java.name
    }

    init {
        appVersion = Utils.appVersion(context)
        userEmail = LanternApp.getSession().email()
        sendLogs = template == "user-send-logs"
        dialog = ProgressDialog(context)
        dialog!!.setCancelable(false)
        dialog!!.setCanceledOnTouchOutside(false)
    }
}
