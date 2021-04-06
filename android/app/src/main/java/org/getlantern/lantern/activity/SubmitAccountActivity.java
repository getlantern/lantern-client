package org.getlantern.lantern.activity;

import android.content.Intent;
import android.content.res.Resources;
import android.os.AsyncTask;
import android.os.Build;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Spinner;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ItemClick;
import org.androidannotations.annotations.ViewById;
import org.androidannotations.annotations.res.StringArrayRes;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.model.MailSender;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

@EActivity(R.layout.activity_submit_account)
public class SubmitAccountActivity extends FragmentActivity {

    private static final String TAG = SubmitAccountActivity.class.getName();
    
    private ArrayAdapter<String> methodAdapter;
    private String selectedPaymentMethod;

    @ViewById
    ListView list;

    @StringArrayRes(R.array.payment_method_list)
    String[] paymentList;

    @ViewById
    EditText emailInput, paymentMethod, paymentAccount, description;

    @ViewById
    Spinner expMonth, expYear;

    @ViewById
    LinearLayout monthYear;

    @ViewById
    Button submit;

    @ViewById
    View paymentSeparator;

    @AfterViews
    void afterViews() {

        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);

        emailInput.setText(LanternApp.getSession().email());

        methodAdapter = new ArrayAdapter<String>(this, R.layout.issue_row, paymentList);
        list.setAdapter(methodAdapter);
    }

    @Click(R.id.submit)
    public void submitClicked(View view) {
        final String email = emailInput.getText().toString();

        Logger.debug(TAG, "Starting account recovery for email " + email);

        if (!Utils.isEmailValid(email)) {
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.invalid_email));
            return;
        }

        if (!Utils.isNetworkAvailable(this)) {
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.no_internet_connection));
            return;
        }

        if (selectedPaymentMethod == null) {
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.no_issue_selected));
            return;
        }

        if (expMonth.getSelectedItem() == null ||
            expYear.getSelectedItem() == null) {
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.no_purchase_date));
            return;
        }

        Calendar calendar = Calendar.getInstance();
        calendar.clear();
        calendar.set(Calendar.MONTH, getExpMonth());
        calendar.set(Calendar.YEAR, getExpYear());
        Date date = calendar.getTime();

        DateFormat df = new SimpleDateFormat("EEE MMM d yyyy");
        String purchaseDate = df.format(date);

        LanternApp.getSession().setEmail(email);
        MailSender mailSender = new MailSender(this, "manual-recover-account", false, false);
        mailSender.addMergeVar("paymentMethod", selectedPaymentMethod);
        mailSender.addMergeVar("paymentAccount", paymentAccount.getText().toString());
        mailSender.addMergeVar("note", description.getText().toString());
        mailSender.addMergeVar("purchaseDate", purchaseDate);
        String toEmail = "support@getlantern.org";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
            mailSender.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, toEmail);
        else
            mailSender.execute(toEmail);

        Intent intent = new Intent(this, LanternFreeActivity.class);
        intent.putExtra("snackbarMsg", getResources().getString(R.string.thanks_report));
        startActivity(intent);
        finish();
    }

    private Integer getExpMonth() {
        return getInteger(this.expMonth);
    }

    private Integer getExpYear() {
        return getInteger(this.expYear);
    }

    private Integer getInteger(Spinner spinner) {
        try {
            return Integer.parseInt(spinner.getSelectedItem().toString());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    @Click(R.id.paymentMethod)
    public void showPaymentList() {
        if (list.isShown()) {
            paymentSeparator.setVisibility(View.VISIBLE);
            list.setVisibility(View.GONE);
            selectedPaymentMethod = null;
            paymentMethod.setText("");
        }
        else {
            paymentSeparator.setVisibility(View.GONE);
            list.setVisibility(View.VISIBLE);
        }
    }

    @ItemClick(R.id.list)
    void methodClicked(String method) {
        Logger.debug(TAG, "Selected payment method is " + method);
        Resources res = getResources();
        selectedPaymentMethod = method;
        if (selectedPaymentMethod.equals(res.getString(R.string.Alipay))) {
            monthYear.setVisibility(View.VISIBLE);
            paymentAccount.setVisibility(View.VISIBLE);
            paymentAccount.setHint(res.getString(R.string.alipay_account));
        } else if (selectedPaymentMethod.equals(res.getString(R.string.by_referral))) {
            monthYear.setVisibility(View.GONE);
            paymentAccount.setVisibility(View.VISIBLE);
            paymentAccount.setHint(res.getString(R.string.your_referral_code));
        } else {
            monthYear.setVisibility(View.VISIBLE);
            paymentAccount.setVisibility(View.GONE);
        }
        paymentMethod.setText(method);
        list.setVisibility(View.GONE);
    }

}
