package org.getlantern.lantern.activity.yinbi;

import android.content.Intent;
import android.view.View;
import android.widget.TextView;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.MainActivity;
import org.getlantern.lantern.R;

@EActivity(R.layout.welcome_yinbi)
public class YinbiWelcomeActivity extends FragmentActivity {
    private static final String TAG = YinbiWelcomeActivity.class.getName();

    @ViewById
    TextView header;

    @ViewById
    TextView thanksMessage;

    @AfterViews
    void afterViews() {
        if (LanternApp.getSession().isProUser()) {
            header.setText(getResources().getString(R.string.renewal_success));
            thanksMessage.setText(getResources().getString(R.string.thank_you_for_renewing));
        }
    }

    @Click(R.id.yinbiMenu)
    void openYinbiMenu(View view) {
        startActivity(new Intent(this, YinbiLauncher.class));
    }

    @Click(R.id.continueToLanternPro)
    void continueToPro(View view) {
        startActivity(new Intent(this, MainActivity.class));
    }
}
