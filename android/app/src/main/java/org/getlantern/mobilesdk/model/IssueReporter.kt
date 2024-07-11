//package org.getlantern.mobilesdk.model
//
//import android.content.Context
//import android.os.Build
//import io.flutter.plugin.common.MethodChannel
//import kotlinx.coroutines.CoroutineScope
//import kotlinx.coroutines.Dispatchers
//import kotlinx.coroutines.launch
//import org.getlantern.lantern.LanternApp
//import org.getlantern.lantern.R
//import org.getlantern.mobilesdk.Logger
//
//// IssueReporter calls Go's `internalsdk/issue.go:SendIssueReport` method to
//// submit issue reports. If successful, onSuccess() callback would trigger,
//// else onError().
//class IssueReporter(
//    private val context: Context,
//    private val issue: String,
//    private val description: String?,
//    private val methodCallResult: MethodChannel.Result
//) {
//    companion object {
//        private val TAG = IssueReporter::class.java.name
//    }
//
//    // The below maps indexes of issues in the drop-down to indexes of the corresponding issue type
//    // as understood by internalsdk.SendIssueReport
//    private val issueTypeIndexes = hashMapOf(
//        0 to 3, // NO_ACCESS
//        1 to 0, // PAYMENT_FAIL
//        2 to 1, // CANNOT_LOGIN
//        3 to 2, // ALWAYS_SPINNING
//        4 to 4, // SLOW
//        5 to 7, // CHAT_NOT_WORKING,
//        6 to 8, // DISCOVER_NOT_WORKING,
//        7 to 5, // CANNOT LINK DEVICE
//        8 to 6, // CRASHES
//        9 to 9, // OTHER
//    )
//
//    private fun issues() = arrayOf(
//        context.resources.getString(R.string.common_issue_list_0),
//        context.resources.getString(R.string.common_issue_list_1),
//        context.resources.getString(R.string.common_issue_list_2),
//        context.resources.getString(R.string.common_issue_list_3),
//        context.resources.getString(R.string.common_issue_list_4),
//        context.resources.getString(R.string.common_issue_list_5),
//        context.resources.getString(R.string.common_issue_list_6),
//        context.resources.getString(R.string.common_issue_list_7),
//        context.resources.getString(R.string.common_issue_list_8),
//        context.resources.getString(R.string.common_issue_list_9),
//    )
//
//
//    fun reportIssue() {
//        CoroutineScope(Dispatchers.IO).launch {
//            try {
//                sendIssueReport()
//                methodCallResult.success("Report sent successfully")
//            } catch (e: Exception) {
//                Logger.e(TAG, "Error while sending report issue :$e")
//                methodCallResult.error("report_issue_fail", "Error while report issue :$e", e)
//            }
//        }
//    }
//
//    private fun sendIssueReport() {
//        val session = LanternApp.getSession()
//        val issueType = issueTypeIndexes[issues().indexOf(issue)] ?: 9 // default to OTHER
//        internalsdk.Internalsdk.sendIssueReport(
//            session,
//            issueType.toString(),
//            description,
//            if (session.isProUser) "pro" else "free",
//            session.email(),
//            Build.DEVICE,
//            Build.MODEL,
//            Build.VERSION.SDK_INT.toString() + " (" + Build.VERSION.RELEASE + ")"
//        )
//    }
//}
