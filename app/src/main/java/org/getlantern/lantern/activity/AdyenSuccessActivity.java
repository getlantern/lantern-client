package org.getlantern.lantern.activity;

import android.app.ProgressDialog;

import androidx.fragment.app.FragmentActivity;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.PaymentHandler;
import org.getlantern.mobilesdk.Logger;

@EActivity(R.layout.adyen_success_layout)
public class AdyenSuccessActivity extends FragmentActivity {
    private static final String TAG = AdyenSuccessActivity.class.getSimpleName();
    private static final String PROVIDER = "Adyen";

    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

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
