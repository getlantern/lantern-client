package org.getlantern.lantern.activity;

import android.content.Intent;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.androidannotations.annotations.ViewById;

import org.getlantern.lantern.MainActivity;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.R;

@EActivity(R.layout.pro_welcome)
public class WelcomeActivity extends BaseFragmentActivity {

    private static final String TAG = WelcomeActivity.class.getName();

    @ViewById
    CoordinatorLayout coordinatorLayout;

    @ViewById
    LinearLayout container;

    @ViewById
    TextView header;

    @Extra
    String provider;

    @Extra
    String snackbarMsg;

    @AfterViews
    void afterViews() {
        // we re-use the titlebar component here
        // but center the label since there is no
        // back button on this screen
        header.setPadding(0, 0, 0, 0);
        if (container != null) {
            container.setGravity(Gravity.CENTER);
        }

        Utils.showPlainSnackbar(coordinatorLayout, snackbarMsg);
    }

    public void continueToPro(View view) {
        Logger.debug(TAG, "Continue to Pro button clicked!");
        startActivity(new Intent(this, MainActivity.class));
    }
}
