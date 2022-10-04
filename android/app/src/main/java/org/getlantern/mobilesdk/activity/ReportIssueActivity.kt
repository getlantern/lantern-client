package org.getlantern.mobilesdk.activity

import android.os.AsyncTask
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.FragmentActivity
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.databinding.ActivityReportIssueBinding
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.util.showErrorDialog
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.MailSender

open class ReportIssueActivity : FragmentActivity() {
    private lateinit var binding: ActivityReportIssueBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityReportIssueBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val email = LanternApp.getSession().email()
        if ("" != email) {
            binding.emailInput.setText(email)
        }

        val issues = resources.getStringArray(R.array.common_issue_list)
        val issueAdapter = ArrayAdapter(this, R.layout.issue_row, issues)
        binding.issue.setAdapter(issueAdapter)

        binding.sendBtn.setOnClickListener {
            sendReport(it)
        }
        binding.issue.addTextChangedListener {
            checkValidField()
        }
        binding.emailInput.addTextChangedListener {
            checkValidField()
        }
    }

    private fun checkValidField() {
        when {
            binding.issue.text?.toString()?.isEmpty() == true -> {
                binding.sendBtn.isEnabled = false
            }
            binding.emailInput.text?.toString()?.isEmpty() == true -> {
                binding.sendBtn.isEnabled = false
            }
            else -> {
                binding.sendBtn.isEnabled = true
            }
        }
    }

    fun sendReport(view: View?) {
        val email = binding.emailInput.text.toString()
        val issue = binding.issue.text?.toString()
        if (!Utils.isNetworkAvailable(this)) {
            showErrorDialog(resources.getString(R.string.no_internet_connection))
            return
        }
        if (issue.isNullOrEmpty()) {
            showErrorDialog(resources.getString(R.string.no_issue_selected))
            return
        }
        if (!Utils.isEmailValid(email)) {
            showErrorDialog(resources.getString(R.string.invalid_email))
            return
        }
        Logger.debug(TAG, "Reporting $issue issue on behalf of $email")
        LanternApp.getSession().setEmail(email)
        val mailSender = MailSender(
            this, "user-send-logs", getString(R.string.report_sent),
            getString(R.string.thank_you_for_reporting_your_issue)
        )
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
