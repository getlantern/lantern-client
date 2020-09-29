package org.lantern.app.activity;

import android.app.ProgressDialog;
import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;

import org.lantern.app.LanternApp;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.PaymentHandler;
import org.lantern.app.model.LanternHttpClient;
import org.lantern.app.model.SessionManager;
import org.lantern.app.R;

@EActivity(R.layout.adyen_success_layout)
public class AdyenSuccessActivity extends FragmentActivity {
    private static final String TAG = AdyenSuccessActivity.class.getSimpleName();
    private static final String PROVIDER = "Adyen";

    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    private static final SessionManager session = LanternApp.getSession();

    private PaymentHandler paymentHandler;

    private ProgressDialog dialog;

    @AfterViews
    void afterViews() {
        paymentHandler = new PaymentHandler(this, PROVIDER);
        dialog = ProgressDialog.show(this,
                getResources().getString(R.string.successful_purchase),
                getResources().getString(R.string.now_converting_to_pro),
                true, false);

        Logger.debug(TAG, "Adyen payment successful");
        paymentHandler.checkProUser(false);
    }

    @Override
    protected void onPause() {
        if (dialog != null) {
            dialog.dismiss();
        }
        super.onPause();
    }
}
