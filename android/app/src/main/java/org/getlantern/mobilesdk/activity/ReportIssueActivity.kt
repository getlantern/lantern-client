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
import org.getlantern.mobilesdk.model.IssueReporter
import org.getlantern.mobilesdk.model.MailSender

open class ReportIssueActivity : FragmentActivity() {
    private lateinit var binding: ActivityReportIssueBinding
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityReportIssueBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val email = LanternApp.getSession().email()
        if ("" != email) {
            binding.emailInput.setText(email)
        }

        val issueAdapter = ArrayAdapter(this, R.layout.issue_row, issues())
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

        val issueType = issueTypeIndexes[issues().indexOf(issue)] ?: 9 // default to OTHER
        val description = binding.description.text.toString()

        Logger.debug(TAG, "Reporting '$issueType - $issue' on behalf of $email")
        LanternApp.getSession().setEmail(email)

        val issueReporter = IssueReporter(
            this,
            issueType.toString(),
            description,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            issueReporter.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR)
        } else {
            issueReporter.execute()
        }
    }

    private fun issues(): Array<String> = resources.getStringArray(R.array.common_issue_list)

    companion object {
        private val TAG = ReportIssueActivity::class.java.name
    }
}
