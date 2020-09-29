package org.getlantern.lantern.model;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.widget.AppCompatRadioButton;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.Window;
import android.view.WindowManager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.activity.CheckoutActivity_;
import org.getlantern.lantern.R;

;

import java.util.HashMap;
import java.util.Map;

import com.google.common.collect.ImmutableMap;

import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EFragment;
import org.androidannotations.annotations.FragmentArg;
import org.androidannotations.annotations.res.StringArrayRes;
import org.androidannotations.annotations.ViewById;
import androidx.annotation.NonNull;

import org.getlantern.mobilesdk.Logger;

@EFragment
public class WelcomeDialog extends DialogFragment {

    private static final String TAG = WelcomeDialog.class.getName();
    private static final int ENTER_EMAIL_REQUEST = 1;
    private static final SessionManager session = LanternApp.getSession();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

    @FragmentArg("layout")
    String layout;

    @ViewById
    Button oneYearBtn, twoYearBtn, upgradeNow, startUsingBtn;

    @ViewById
    TextView continueBasic, lanternPro, renewalHeader, renewalSubHeader,
             oneYearCost, twoYearCost, oneYearDetail, twoYearDetail;

    @ViewById
    ImageView close;

    @ViewById
    AppCompatRadioButton radioFree, radioPro;

    @StringArrayRes(R.array.renewal_confirm)
    String[] renewalConfirm;

    public static final String LAYOUT_SOFT = "soft";
    public static final String LAYOUT_MEDIUM = "medium";
    public static final String LAYOUT_HARD = "hard";
    public static final String LAYOUT_RENEWAL = "renewal";
    public static final String LAYOUT_DEFAULT = "default";

    private static final Map<String, Integer> layouts = ImmutableMap.of(
        LAYOUT_SOFT, R.layout.welcome_soft,
        LAYOUT_MEDIUM, R.layout.welcome_medium,
        LAYOUT_HARD, R.layout.welcome_hard,
        LAYOUT_RENEWAL, R.layout.renewal,
        LAYOUT_DEFAULT, R.layout.welcome
    );

    private Map<String, ProPlan> plans = new HashMap<String, ProPlan>();

    public static final boolean isSupportedLayout(final String layout) {
        return layouts.containsKey(layout);
    }

    private void setRenewalText() {
        if (renewalHeader == null || renewalSubHeader == null) {
            return;
        }
        String subText = "";
        String headerText = null;
        final Integer daysLeft = session.getProDaysLeft();
        if (daysLeft == null || daysLeft < 0) {
            // after expiration
            subText = getString(R.string.limited_time_offer);
            headerText = getString(R.string.renew_after);
        } else if (daysLeft == 1) {
            subText = getString(R.string.offer_ends_tomorrow);
            headerText = getString(R.string.renew_ends_tomorrow);
        } else if (daysLeft == 0) {
            subText = getString(R.string.offer_ends_today);
            headerText = getString(R.string.renew_ends_today);
        }

        if (headerText != null) {
            renewalHeader.setText(headerText);
        }

        renewalSubHeader.setText(String.format("%s %s", getString(R.string.renew_sub), subText));
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {

        final Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCanceledOnTouchOutside(true);
        dialog.setCancelable(true);

        return dialog;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (layout != null && !layout.equals(LAYOUT_DEFAULT)) {
            setStyle(DialogFragment.STYLE_NORMAL, android.R.style.Theme_Black_NoTitleBar_Fullscreen);
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        final Dialog dialog = getDialog();
        if (layout != null && !layout.equals(LAYOUT_DEFAULT) && dialog != null) {
            dialog.getWindow().setLayout(WindowManager.LayoutParams.FILL_PARENT,
                    WindowManager.LayoutParams.FILL_PARENT);
        }

        addFeatures(dialog, R.id.proFeatures, R.array.pro_features_welcome);
        addFeatures(dialog, R.id.basicFeatures, R.array.basic_features);
        setRenewalText();
        if (oneYearCost != null) {
            // only fetch prices for hard variation of welcome screen
            updatePrices();
        }
    }

    @Override
    public View onCreateView (LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Integer welcomeLayout = R.layout.welcome;
        if (layout != null) {
            welcomeLayout = layouts.get(layout);
        }
        View v = inflater.inflate(welcomeLayout, container, false);
        return v;
    }

    private void addFeatures(final Dialog dialog, final int layoutId, final int arrayId) {
        final LinearLayout featuresView = (LinearLayout)dialog.findViewById(layoutId);
        if (featuresView == null) {
            return;
        }

        // in case back button is pressed, remove all previously added
        // feature views
        featuresView.removeAllViews();
        if (lanternPro != null) {
            // add Lantern Pro header
            featuresView.addView(lanternPro);
        }

        final String[] features = getActivity().getResources().getStringArray(arrayId);
        Integer featureLayout = R.layout.pro_feature;

        for (String featureText : features) {
            final TextView feature = (TextView)LayoutInflater.from(getActivity()).inflate(R.layout.pro_feature_soft_welcome, null);
            feature.setText(Html.fromHtml(String.format("&#8226; %s",
                            featureText)));
            featuresView.addView(feature);
        }
    }

    private void updatePrices() {
        LanternApp.getPlans(new LanternHttpClient.PlansCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Unable to fetch prices", throwable);
            }
            @Override
            public void onSuccess(final Map<String, ProPlan> proPlans) {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        for (String planId : proPlans.keySet()) {
                            setPrice(proPlans.get(planId));
                        }
                    }
                });
            }
        });
    }

    private void setPriceDetail(final TextView detail, final long numYears) {
        final Integer timeFree;
        final String subText;
        final Integer daysLeft = session.getProDaysLeft();
        if (daysLeft == null || daysLeft < 0) {
            timeFree = numYears == 1 ? 15 : 45;
            subText = getString(R.string.days_free);
        } else {
            timeFree = numYears == 1 ? 1 : 3;
            subText = numYears == 1 ? getString(R.string.month_free) :
                getString(R.string.months_free);
        }

        detail.setText(String.format("%s + %d %s",
                    (numYears == 1 ?
                    getString(R.string.one_year) :
                    getString(R.string.two_years)),
                    timeFree,
                    subText));
    }

    private void setPrice(final ProPlan plan) {
        final TextView cost, detail;
        final Button btn;
        final long numYears = plan.numYears();

        if (numYears == 1) {
            cost = oneYearCost;
            detail = oneYearDetail;
            btn = oneYearBtn;
        } else {
            cost = twoYearCost;
            detail = twoYearDetail;
            btn = twoYearBtn;
        }
        cost.setText(plan.getCostStr());
        btn.setTag(plan.getId());

        if (!session.isProUser()) {
            return;
        }

        setPriceDetail(detail, numYears);
    }

    @Click({R.id.upgradeNow})
    public void upgradeNow() {
        if (radioFree != null && radioFree.isChecked()) {
            Logger.debug(TAG, "User chose to continue with basic version of Lantern, dismissing welcome screen");
            dismiss();
            return;
        }

        startActivity(new Intent(getActivity(),
                    session.plansActivity()));
        return;
    }

    @Click({R.id.continueBasic, R.id.startUsingBtn})
    public void continueBasic() {
        dismiss();
    }

    @Click({R.id.oneYearBtn, R.id.twoYearBtn})
    public void selectPlan(final View view) {
        final String planId = (String)view.getTag();
        if (planId == null) {
            return;
        }

        session.setProPlan(plans.get(planId));
        final Intent emailIntent = new Intent(getActivity(),
                CheckoutActivity_.class);
        getActivity().startActivityForResult(emailIntent, ENTER_EMAIL_REQUEST);
    }

    @Click({R.id.close})
    public void close() {
        Logger.debug(TAG, "Close button clicked");
        if (session.isProUser() || session.isExpired()) {
            showConfirmDialog();
        } else {
            dismiss();
        }
    }

    private void showConfirmDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        //builder.setIcon(R.drawable.icon);
        builder.setTitle(getString(R.string.decline_offer));
        builder.setSingleChoiceItems(renewalConfirm, -1, new DialogInterface
                .OnClickListener() {
                    public void onClick(DialogInterface dialog, int item) {

                        session.setRenewalPref(item == 0);
                        dialog.dismiss();
                        dismiss();
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();
    }

}
