package org.getlantern.lantern.activity;

import android.content.Intent;
import android.content.res.Resources;
import android.net.Uri;
import androidx.fragment.app.FragmentActivity;

import android.view.View;
import android.widget.TextView;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.fragment.ProgressDialogFragment;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.model.SessionManager;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.R;

@EActivity(R.layout.invite_friends)
public class InviteActivity extends FragmentActivity {

    private static final String TAG = InviteActivity.class.getName();
    private final SessionManager session = LanternApp.getSession();

    private ProgressDialogFragment progressFragment;
    private Resources resources;
    private String code;

    @ViewById
    TextView referralCode;

    @ViewById(R.id.referral_code_view)
    View referralView;

    @AfterViews
    void afterViews() {
        resources = getResources();
        progressFragment = ProgressDialogFragment.newInstance(R.string.progressMessage2);
    }

    @Override
    protected void onResume() {
        super.onResume();
        this.code = session.code();
        Logger.debug(TAG, "referral code is " + this.code);
        referralCode.setText(this.code);
    }

    private void startProgress() {
        progressFragment.show(getSupportFragmentManager(), "progress");
    }

    private void finishProgress() {
        progressFragment.dismiss();
    }

    @Click(R.id.referralCode)
    void referralCodeClicked() {
        final CharSequence referralText = referralCode.getText();

        if (referralText == null) {
            return;
        }

        final String shareReferralText = String.format(
                resources.getString(R.string.share_referral_text),
                referralText.toString());
        Utils.copyToClipboard(this,
                "Referral Code",
                shareReferralText);
        Utils.showToastMessage(getLayoutInflater(),
                this,
                this,
                resources.getString(R.string.copied_to_clipboard));
    }

    public void textInvite(View view) {
        Logger.debug(TAG, "Invite friends button clicked!");

        try {
            final Intent sendIntent = new Intent(Intent.ACTION_VIEW);
            sendIntent.setData(Uri.parse("sms:"));
            sendIntent.putExtra("sms_body",
                    String.format(
                        resources.getString(R.string.receive_free_month),
                        this.code));
            startActivity(sendIntent);
        } catch (Exception e) {
            Logger.error(TAG, "Error trying to start SMS Intent", e);
        }
    }

    public void emailInvite(View view) {
        Logger.debug(TAG, "Continue to Pro button clicked!");

        try {
            final Intent emailIntent = new Intent(Intent.ACTION_SENDTO,
                    Uri.fromParts("mailto","", null));
            emailIntent.putExtra(Intent.EXTRA_SUBJECT,
                    resources.getString(R.string.pro_invitation_subject));
            emailIntent.putExtra(Intent.EXTRA_TEXT,
                    String.format(
                        resources.getString(R.string.receive_free_month),
                        this.code));

            startActivity(Intent.createChooser(emailIntent, "Send email..."));
        } catch (Exception e) {
            Logger.error(TAG, "Error trying to start email Intent", e);
        }
    }
}
