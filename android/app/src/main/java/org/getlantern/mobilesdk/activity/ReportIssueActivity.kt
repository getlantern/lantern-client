package org.getlantern.mobilesdk.activity

import android.os.AsyncTask
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import androidx.fragment.app.FragmentActivity
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.databinding.ActivityReportIssueBinding
import org.getlantern.mobilesdk.model.Utils
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.MailSender

open class ReportIssueActivity : FragmentActivity() {
    private var issueAdapter: ArrayAdapter<String>? = null
    private var selectedIssue: String? = null

    private lateinit var binding: ActivityReportIssueBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityReportIssueBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val email = LanternApp.getSession().email()
        if (email != null && "" != email) {
            binding.emailInput.setText(email)
        }

        val issues = resources.getStringArray(R.array.common_issue_list)
        issueAdapter = ArrayAdapter(this, R.layout.issue_row, issues)
        binding.list.adapter = issueAdapter

        binding.issue.setOnClickListener { _ -> showIssueList() }
        binding.list.setOnItemClickListener { _, _, _, id  -> issueClicked(issues[id.toInt()]) }
    }

    fun showIssueList() {
        if (binding.list.isShown) {
            binding.list.visibility = View.GONE
            selectedIssue = null
            binding.issue.setText("")
        } else {
            binding.list.visibility = View.VISIBLE
        }
    }

    fun issueClicked(issueText: String) {
        Logger.debug(TAG, "Selected issue is $issueText")
        selectedIssue = issueText
        binding.issue.setText(issueText)
        binding.list.visibility = View.GONE
    }

    fun sendReport(view: View?) {
        val email = binding.emailInput.text.toString()
        val issue = selectedIssue
        if (!Utils.isNetworkAvailable(this)) {
            Utils.showErrorDialog(this,
                    resources.getString(R.string.no_internet_connection))
            return
        }
        if (issue == null) {
            Utils.showErrorDialog(this,
                    resources.getString(R.string.no_issue_selected))
            return
        }
        if (!Utils.isEmailValid(email)) {
            Utils.showErrorDialog(this,
                    resources.getString(R.string.invalid_email))
            return
        }
        Logger.debug(TAG, "Reporting $issue issue on behalf of $email")
        LanternApp.getSession().setEmail(email)
        val mailSender = MailSender(this, "user-send-logs", true, true)
        val report = binding.description.text.toString()
        mailSender.addMergeVar("issue", issue)
        mailSender.addMergeVar("report", report)
        val subject: String = if (report.isEmpty()) issue else report
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            mailSender.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, subject)
        } else {
            mailSender.execute(subject)
        }
    }

    companion object {
        private val TAG = ReportIssueActivity::class.java.name
    }
}
