package org.getlantern.mobilesdk.model

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.os.AsyncTask
import internalsdk.EmailMessage
import internalsdk.EmailResponseHandler
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
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
) : AsyncTask<String, Void, Boolean>(), EmailResponseHandler {
    private var dialog: ProgressDialog? = null
    private val mergeValues: MutableMap<String, String> = HashMap()

    override fun onError(message: String) {
        dialog?.let { dialog ->
            if (dialog.isShowing) {
                dialog.dismiss()
            }
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
            if (dialog.isShowing) {
                dialog.dismiss()
            }
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
        msg.to = params[0]
        if (template == "manual-recover-account") {
            msg.putInt("userid", LanternApp.getSession().userID)
            msg.putString("usertoken", LanternApp.getSession().token)
            msg.putString("deviceid", LanternApp.getSession().deviceID)
            msg.putString("deviceName", LanternApp.getSession().deviceName())
            msg.putString("email", LanternApp.getSession().email())
            msg.putString("referralCode", LanternApp.getSession().code())
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
        val msg = R.string.success_email
        return context.resources.getString(msg).format(getAppName())
    }

    private fun getAppName(): String {
        return context.resources.getString(R.string.app_name)
    }

    companion object {
        private val TAG = MailSender::class.java.name
    }

    init {
        dialog = ProgressDialog(context)
        dialog!!.setCancelable(false)
        dialog!!.setCanceledOnTouchOutside(false)
    }
}
