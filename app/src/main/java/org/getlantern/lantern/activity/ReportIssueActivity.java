package org.getlantern.lantern.activity;

import android.os.AsyncTask;
import android.os.Build;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ItemClick;
import org.androidannotations.annotations.ViewById;
import org.androidannotations.annotations.res.StringArrayRes;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.SessionManager;
import org.getlantern.lantern.model.MailSender;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Logger;

@EActivity(R.layout.activity_report_issue)
public class ReportIssueActivity extends FragmentActivity {

    private static final String TAG = ReportIssueActivity.class.getName();
    private final SessionManager session = LanternApp.getSession();

    private ArrayAdapter<String> issueAdapter;
    private String selectedIssue;

    @ViewById
    Button sendBtn;

    @ViewById
    ListView list;

    @StringArrayRes(R.array.common_issue_list)
    String[] issueList;

    @ViewById
    EditText emailInput, issue, description;

    @ViewById
    View separator;

    @AfterViews
    void afterViews() {
        final String email = session.email();
        if (email != null && !"".equals(email)) {
            emailInput.setText(email);
        }

        issueAdapter = new ArrayAdapter<String>(this, R.layout.issue_row, issueList);
        list.setAdapter(issueAdapter);
    }

    @Click(R.id.issue)
    public void showIssueList() {
        if (list.isShown()) {
            list.setVisibility(View.GONE);
            selectedIssue = null;
            issue.setText("");
        }
        else {
            list.setVisibility(View.VISIBLE);
        }
    }

    @ItemClick(R.id.list)
    void issueClicked(final String issueText) {
        Logger.debug(TAG, "Selected issue is " + issueText);
        selectedIssue = issueText;
        issue.setText(issueText);
        list.setVisibility(View.GONE);
    }


    public void sendReport(final View view) {
        final String email = emailInput.getText().toString();
        final String issue = selectedIssue;

        if (!Utils.isNetworkAvailable(this)) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.no_internet_connection));
            return;
        }

        if (issue == null) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.no_issue_selected));
            return;
        }

        if (!Utils.isEmailValid(email)) {
            Utils.showErrorDialog(this,
                    getResources().getString(R.string.invalid_email));
            return;
        }

        Logger.debug(TAG, "Reporting " + issue + " issue on behalf of " + email);

        session.setEmail(email);

        final MailSender mailSender = new MailSender(this, "user-send-logs", true);
        String report = description.getText().toString();
        mailSender.addMergeVar("issue", issue);
        mailSender.addMergeVar("report", report);

        final String subject = report.isEmpty() ? issue : report;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            mailSender.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, subject);
        }
        else {
            mailSender.execute(subject);
        }
    }
}
