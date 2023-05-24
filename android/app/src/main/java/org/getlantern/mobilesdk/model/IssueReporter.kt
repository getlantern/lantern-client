package org.getlantern.mobilesdk.model

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.os.AsyncTask
import android.os.Build
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.util.showAlertDialog
import org.getlantern.mobilesdk.Logger

// IssueReporter calls Go's `internalsdk/issue.go:SendIssueReport` method to
// submit issue reports. If successful, onSuccess() callback would trigger,
// else onError().
class IssueReporter @JvmOverloads constructor(
    private val context: Context,
    private val issueType: String,
    private val description: String?,
) : AsyncTask<String, Void, Boolean>() {
    private var dialog: ProgressDialog? = null

    fun onError(message: String) {
        dialog?.let { dialog ->
            if (dialog.isShowing) {
                dialog.dismiss()
            }
        }
        (context as Activity).showAlertDialog(
            context.getString(R.string.unable_to_submit_issue),
            message,
            // Don't close the dialog if there's an error. This'll remove the
            // user's input. Let the user close the dialog or try again if they
            // want.
            finish = false,
        )
    }

    fun onSuccess() {
        dialog?.let { dialog ->
            if (dialog.isShowing) {
                dialog.dismiss()
            }
        }
        (context as Activity).showAlertDialog(
            context.getString(R.string.report_sent),
            context.getString(R.string.thank_you_for_reporting_your_issue),
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

    override fun doInBackground(vararg params: String): Boolean {
        val session = LanternApp.getSession()
        try {
            internalsdk.Internalsdk.sendIssueReport(
                session,
                issueType,
                description,
                if (session.isProUser) "pro" else "free",
                session.email(),
                Build.DEVICE,
                Build.MODEL,
                "" + Build.VERSION.SDK_INT + " (" + Build.VERSION.RELEASE + ")"
            )
            onSuccess()
            return true
        } catch (e: Exception) {
            Logger.error(TAG, "Error submitting issue report: ", e)
            onError(e.localizedMessage)
            return false
        }
    }

    companion object {
        private val TAG = IssueReporter::class.java.name
    }

    init {
        dialog = ProgressDialog(context)
        dialog!!.setCancelable(false)
        dialog!!.setCanceledOnTouchOutside(false)
    }
}
