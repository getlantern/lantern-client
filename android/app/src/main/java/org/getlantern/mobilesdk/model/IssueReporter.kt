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
    private val issue: String,
    private val description: String?,
) : AsyncTask<String, Void, Boolean>() {
    private var dialog: ProgressDialog? = null


    // The below maps indexes of issues in the drop-down to indexes of the corresponding issue type
    // as understood by internalsdk.SendIssueReport
    private val issueTypeIndexes = hashMapOf(
        0 to 3, // NO_ACCESS
        1 to 0, // PAYMENT_FAIL
        2 to 1, // CANNOT_LOGIN
        3 to 2, // ALWAYS_SPINNING
        4 to 4, // SLOW
        5 to 7, // CHAT_NOT_WORKING,
        6 to 8, // DISCOVER_NOT_WORKING,
        7 to 5, // CANNOT LINK DEVICE
        8 to 6, // CRASHES
        9 to 9, // OTHER
    )

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
            val issueType = issueTypeIndexes[issues().indexOf(issue)] ?: 9 // default to OTHER
            internalsdk.Internalsdk.sendIssueReport(
                session,
                issueType.toString(),
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

    private fun issues() = arrayOf(
        context.resources.getString(R.string.common_issue_list_0),
        context.resources.getString(R.string.common_issue_list_1),
        context.resources.getString(R.string.common_issue_list_2),
        context.resources.getString(R.string.common_issue_list_3),
        context.resources.getString(R.string.common_issue_list_4),
        context.resources.getString(R.string.common_issue_list_5),
        context.resources.getString(R.string.common_issue_list_6),
        context.resources.getString(R.string.common_issue_list_7),
        context.resources.getString(R.string.common_issue_list_8),
        context.resources.getString(R.string.common_issue_list_9),
    )

    companion object {
        private val TAG = IssueReporter::class.java.name
    }

    init {
        dialog = ProgressDialog(context)
        dialog!!.setCancelable(false)
        dialog!!.setCanceledOnTouchOutside(false)
    }
}
