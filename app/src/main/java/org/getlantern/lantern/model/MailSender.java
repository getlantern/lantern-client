package org.getlantern.lantern.model;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;

import org.getlantern.mobilesdk.Logger;

import android.EmailMessage;
import android.EmailResponseHandler;

public class MailSender extends AsyncTask<String, Void, Boolean> implements EmailResponseHandler {
    private static final String TAG = MailSender.class.getName();
    private ProgressDialog dialog;
    private String template;
    private SessionManager session;
    private Context context;
    private String userEmail;
    private String appVersion;
    private boolean sendLogs;
    private boolean showProgress;

    private Map<String, String> mergeValues = new HashMap<String, String>();

    public MailSender(@NonNull Context context, @NonNull String template, boolean showProgress) {
        this.context = context;
        this.template = template;
        this.session = LanternApp.getSession();
        this.showProgress = showProgress;
        this.appVersion = Utils.appVersion(context);
        this.userEmail = session.email();

        this.sendLogs = template != null && template.equals("user-send-logs");

        if (showProgress) {
            dialog = new ProgressDialog(context);
            dialog.setCancelable(false);
            dialog.setCanceledOnTouchOutside(false);
        }
    }

    public void addMergeVar(String name, String value) {
      this.mergeValues.put(name, value);
    }

    @Override
    public void onError(final String message) {
        try {
            Utils.showUIErrorDialog((Activity)context, message);
        } catch (Exception e) {
            Logger.error(TAG, "Unable to show error message sending email: ", e);
        }
    }

    @Override
    protected void onPreExecute() {
        if (dialog != null) {
            dialog.setMessage(context.getResources().getString(R.string.sending_request));
            dialog.show();
        }
    }

    @Override
    protected Boolean doInBackground(String... params) {
        EmailMessage msg = new EmailMessage();
        msg.setTemplate(template);
        if (sendLogs) {
            msg.setSubject(params[0]);
            msg.setFrom(this.userEmail);
            msg.setMaxLogSize("10MB");
            msg.putInt("userid", session.getUserID());
            msg.putString("protoken", session.getToken());
            msg.putString("deviceid", session.getDeviceID());
            msg.putString("emailaddress", this.userEmail);
            msg.putString("appversion", this.appVersion);
            msg.putString("prouser", String.valueOf(session.isProUser()));
            msg.putString("androiddevice", android.os.Build.DEVICE);
            msg.putString("androidmodel", android.os.Build.MODEL);
            msg.putString("androidversion", "" + android.os.Build.VERSION.SDK_INT + " (" + android.os.Build.VERSION.RELEASE + ")");
        } else {
            msg.setTo(params[0]);
            if (this.template.equals("manual-recover-account")) {
                msg.putInt("userid", session.getUserID());
                msg.putString("usertoken", session.getToken());
                msg.putString("deviceid", session.getDeviceID());
                msg.putString("deviceName", session.deviceName());
                msg.putString("email", this.userEmail);
                msg.putString("referralCode", session.code());
            }
        }
        for (Map.Entry<String, String> entry : this.mergeValues.entrySet()) {
            msg.putString(entry.getKey(), entry.getValue());
        }

        try {
            msg.send(this);
        } catch (Exception e) {
            Logger.error(TAG, "Error trying to send mail: ", e);
            return false;
        }

        return true;
    }

    private String getResponseMessage(boolean success) {
        int msg;
        if (success) {
            Logger.debug(TAG, "Successfully called send mail");
            msg = sendLogs ? R.string.success_log_email : R.string.success_email;
        } else {
            msg = sendLogs ? R.string.error_log_email : R.string.error_email;
        }
        return context.getResources().getString(msg);
    }

    @Override
    protected void onPostExecute(Boolean success) {
        super.onPostExecute(success);

        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
        if (showProgress) {
            Utils.showAlertDialog((Activity)context, "Lantern", getResponseMessage(success), false);
        }
    }
}
