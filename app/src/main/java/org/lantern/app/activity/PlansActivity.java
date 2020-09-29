package org.lantern.app.activity;

import android.content.Intent;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import org.lantern.app.LanternApp;
import org.lantern.app.R;
import org.lantern.app.fragment.CardFragment;
import org.lantern.mobilesdk.Logger;
import org.lantern.app.model.LanternHttpClient;
import org.lantern.app.model.ProError;
import org.lantern.app.model.ProPlan;
import org.lantern.app.model.SessionManager;
import org.lantern.app.model.Utils;

import com.google.gson.JsonObject;

import okhttp3.HttpUrl;
import okhttp3.Response;

import java.util.concurrent.ConcurrentHashMap;
import java.util.HashMap;
import java.util.Map;

import org.lantern.mobilesdk.Lantern;

import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItem;

public abstract class PlansActivity extends FragmentActivity {

    private static final String TAG = PlansActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    protected static final SessionManager session = LanternApp.getSession();

    private static final String RESELLER_PORTAL = "https://reseller.lantern.io";

    private ConcurrentHashMap<String, ProPlan> plans = new ConcurrentHashMap<String, ProPlan>();

    protected TextView oneYearCost, twoYearCost, resellerText;

    protected Button oneYearBtn, twoYearBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(getLayoutId());

        initViews();
        updatePlans();
        setPaymentGateway();
        sendScreenViewEvent();
    }

    private void initViews() {
        oneYearBtn = (Button)findViewById(R.id.oneYearBtn);
        twoYearBtn = (Button)findViewById(R.id.twoYearBtn);
        oneYearCost = (TextView)findViewById(R.id.oneYearCost);
        twoYearCost = (TextView)findViewById(R.id.twoYearCost);
        resellerText = (TextView)findViewById(R.id.resellerText);
        oneYearBtn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                selectPlan(v);
            }
        });
        twoYearBtn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                selectPlan(v);
            }
        });
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            twoYearBtn.setStateListAnimator(null);
        }

        if (Utils.isPlayVersion(this)) {
            resellerText.setVisibility(View.GONE);
        } else {
            resellerText.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    resellerButtonClicked(v);
                }
            });
        }
    }

    private void sendScreenViewEvent() {
        final String screenType;
        if (getLayoutId() == R.layout.yinbi_pro_plans) {
            screenType = "yinbi_plans_view";
        } else {
            screenType = "plans_view";
        }
        Lantern.sendEvent(this, screenType);
    }

    protected void setPaymentGateway() {
        final Map<String, String> params = new HashMap<String, String>();
        params.put("appVersion", session.appVersion());
        params.put("country", session.getCountryCode());
        // send any payment provider we get back from Firebase to the pro
        // server
        params.put("remoteConfigPaymentProvider", session.getRemoteConfigPaymentProvider());
        params.put("deviceOS", session.deviceOS());
        final HttpUrl url = LanternHttpClient.createProUrl("/user-payment-gateway", params);
        lanternClient.get(url, new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                if (error != null) {
                    Logger.error(TAG, "Unable to fetch user payment gateway:" + error);
                }
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                final Map<String, String> params = new HashMap<String, String>();

                try {
                    final String provider = result.get("provider").getAsString();
                    if (provider != null) {
                        Logger.debug(TAG, "Payment provider is " + provider);
                        session.setPaymentProvider(provider);
                    }
                } catch (Exception e) {
                    Logger.error(TAG, "Unable to fetch plans", e);
                    return;
                }
            }
        });
    }

    protected FragmentPagerItem createCard(@NonNull final int layoutId, final Integer featuresId, final boolean colorLastItem) {
        final Bundle bundle = new Bundle();
        bundle.putInt("layoutId", layoutId);
        if (featuresId != null) {
            bundle.putInt("featuresId", featuresId);
        }
        bundle.putBoolean("colorLastItem", colorLastItem);
        return FragmentPagerItem.of(getString(R.string.no_title),
                CardFragment.class, bundle);
    }

    protected void updatePlans() {
        final Resources res = getResources();
        LanternApp.getPlans(new LanternHttpClient.PlansCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                if (error != null && error.getMessage() != null) {
                    Utils.showUIErrorDialog(PlansActivity.this, error.getMessage());
                }
            }
            @Override
            public void onSuccess(final Map<String, ProPlan> proPlans) {
                if (proPlans == null) {
                    return;
                }
                plans.clear();
                plans.putAll(proPlans);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        for (String planId : proPlans.keySet()) {
                            updatePrice(proPlans.get(planId));
                        }
                    }
                });
            }
        });
    }

    protected abstract void updatePrice(ProPlan plan);

    private void selectPlan(View view) {
        if (view.getTag() == null) {
            return;
        }
        final String planId = (String)view.getTag();
        Logger.debug(TAG, "Plan selected: " + planId);

        final Bundle params = new Bundle();
        params.putString("plan_id", planId);
        params.putString("app_version", Utils.appVersion(this));
        Lantern.sendEvent(this, "plan_selected", params);

        session.setProPlan(plans.get(planId));
        startActivity(new Intent(this, CheckoutActivity_.class));
    }

    private void resellerButtonClicked(final View v) {
        final Intent intent = new Intent(this,
                RegisterProActivity_.class);
        startActivity(intent);
    }

    protected abstract int getLayoutId();
}
