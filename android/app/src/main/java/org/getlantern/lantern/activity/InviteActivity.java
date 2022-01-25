package org.getlantern.lantern.activity;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.fragment.ProgressDialogFragment;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.util.IntentUtil;
import org.getlantern.mobilesdk.Logger;

@EActivity(R.layout.invite_friends)
public class InviteActivity extends BaseFragmentActivity {

    private static final String TAG = InviteActivity.class.getName();

    private ProgressDialogFragment progressFragment;
    private Resources resources;
    private String code;

    @ViewById
    TextView referralCode;

    @ViewById
    ImageView imgvCopy;

    @ViewById
    ImageView imgvChecked;

    @ViewById
    View bgText;

    @ViewById
    TextView tvShare;

    private Handler handlerCopyAnim;

    @AfterViews
    void afterViews() {
        imgvChecked.setAlpha(0f);
        bgText.setAlpha(0f);
        resources = getResources();
        progressFragment = ProgressDialogFragment.newInstance(R.string.progressMessage2);
        if (LanternApp.getSession().isProUser()) {
            tvShare.setText(getString(R.string.referral_code_share_description_pro));
        } else {
            tvShare.setText(getString(R.string.referral_code_share_description_free));
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handlerCopyAnim = new Handler();
    }

    @Override
    protected void onResume() {
        super.onResume();
        this.code = LanternApp.getSession().code();
        Logger.debug(TAG, "referral code is " + this.code);
        referralCode.setText(this.code);
    }

    @Override
    protected void onDestroy() {
        handlerCopyAnim.removeCallbacksAndMessages(null);
        super.onDestroy();
    }

    private void startProgress() {
        progressFragment.show(getSupportFragmentManager(), "progress");
    }

    private void finishProgress() {
        progressFragment.dismiss();
    }

    @Click(R.id.imgvCopy)
    void referralCodeClicked() {
        handlerCopyAnim.removeCallbacksAndMessages(null);
        // animate when click the button
        long animDuration = 300L;
        long delayDuration = 1000L;
        imgvCopy.animate().alpha(0f).setDuration(animDuration).setListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                imgvCopy.setClickable(false);
            }
        }).start();
        bgText.animate().alpha(1f).setDuration(animDuration).start();
        imgvChecked.animate().alpha(1f).setDuration(animDuration).start();

        handlerCopyAnim.postDelayed(() -> {
            imgvCopy.animate().alpha(1f).setDuration(animDuration).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    imgvCopy.setClickable(true);
                }
            }).start();
            imgvChecked.animate().alpha(0f).setDuration(animDuration).start();
            bgText.animate().alpha(0f).setDuration(animDuration).start();
        }, delayDuration);

        final CharSequence referralText = referralCode.getText();

        if (referralText == null) {
            return;
        }

        Utils.copyToClipboard(this,
                getString(R.string.referral_code),
                referralText.toString());
    }

    @Click
    void btnShare() {
        IntentUtil.INSTANCE.sharePlainText(
                this,
                String.format(resources.getString(R.string.receive_free_month), this.code),
                getString(R.string.referral_code_share_title)
        );
    }
}
