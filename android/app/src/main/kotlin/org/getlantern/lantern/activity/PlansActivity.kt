package org.getlantern.lantern.activity

import android.content.Intent
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat

import com.google.gson.JsonObject
import okhttp3.HttpUrl
import okhttp3.Response
import org.androidannotations.annotations.AfterViews
import org.androidannotations.annotations.Click
import org.androidannotations.annotations.EActivity
import org.androidannotations.annotations.ViewById
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.NavigatorKt
import org.getlantern.lantern.R
import org.getlantern.lantern.model.*
import org.getlantern.lantern.util.ActivityExtKt
import org.getlantern.lantern.util.DateUtil
import org.getlantern.lantern.util.Analytics
import org.getlantern.mobilesdk.Logger
import org.joda.time.LocalDateTime

import java.util.HashMap
import java.util.Map
import java.util.concurrent.ConcurrentHashMap

@EActivity(R.layout.activity_plan)
open class PlansActivity : BaseFragmentActivity() {

    private var plans: ConcurrentHashMap<String, ProPlan> = ConcurrentHashMap<String, ProPlan>()

    @ViewById
    @JvmField
    protected var itemPlanYear1:View 

    @ViewById
    @JvmField
    protected var itemPlanYear2:View

    @ViewById
    @JvmField
    protected var tvRenew:TextView

    @ViewById
    @JvmField
    protected var mostPopularYear1:View

    @ViewById
    @JvmField
    protected var mostPopularYear2:View

    @ViewById
    @JvmField
    protected var content:View

    protected var tvOneMonthCostFirst, tvTwoMonthCostSecond, tvDurationFirst, tvDurationSecond, tvTotalCostFirst, tvTotalCostSecond: TextView

    @AfterViews
    fun afterViews() {
        initViews()
        updatePlans()
        setPaymentGateway()
        sendScreenViewEvent()
    }

    @Click
    fun itemPlanYear1() {
        selectPlan(itemPlanYear1)
    }

    @Click
    fun itemPlanYear2() {
        selectPlan(itemPlanYear2)
    }

    @Click
    fun imgvClose() {
        onBackPressed()
    }

    private fun initViews() {
        tvOneMonthCostFirst = (TextView) itemPlanYear1.findViewById(R.id.tvCost)
        tvTwoMonthCostSecond = (TextView) itemPlanYear2.findViewById(R.id.tvCost)
        tvTotalCostFirst = (TextView) itemPlanYear1.findViewById(R.id.tvTotalCost)
        tvTotalCostSecond = (TextView) itemPlanYear2.findViewById(R.id.tvTotalCost)
        tvDurationFirst = (TextView) itemPlanYear1.findViewById(R.id.tvDuration)
        tvDurationSecond = (TextView) itemPlanYear2.findViewById(R.id.tvDuration)
        View activateCodeContainer = findViewById(R.id.activateCodeContainer)
        activateCodeContainer.setVisibility(View.VISIBLE)
        activateCodeContainer.setOnClickListener(v -> NavigatorKt.openCheckOutReseller(this))
    }

    private fun sendScreenViewEvent() {
        Analytics.event(this, Analytics.CATEGORY_PURCHASING, "plans_view")
    }

    protected fun setPaymentGateway() {
        final Map<String, String> params = new HashMap<String, String>()
        params.put("appVersion", LanternApp.getSession().appVersion())
        params.put("country", LanternApp.getSession().getCountryCode())
        // send any payment provider we get back from Firebase to the pro
        // server
        params.put("remoteConfigPaymentProvider", LanternApp.getSession().getRemoteConfigPaymentProvider())
        params.put("deviceOS", LanternApp.getSession().deviceOS())
        final HttpUrl url = LanternHttpClient.createProUrl("/user-payment-gateway", params)
        lanternClient.get(url, new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                if (error != null) {
                    Logger.error(TAG, "Unable to fetch user payment gateway:" + error)
                }
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                final Map<String, String> params = new HashMap<String, String>()

                try {
                    var provider: String = result.get("provider").getAsString()
                    if (provider != null) {
                        Logger.debug(TAG, "Payment provider is " + provider)
                        LanternApp.getSession().setPaymentProvider(provider)
                    }
                } catch (Exception e) {
                    Logger.error(TAG, "Unable to fetch plans", e)
                    return
                }
            }
        })
    }

    protected fun updatePlans() {
        LanternApp.getPlans(new LanternHttpClient.PlansCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                if (error != null && error.getMessage() != null) {
                    ActivityExtKt.showErrorDialog(PlansActivity.this, error.getMessage())
                }
            }
            @Override
            public void onSuccess(final Map<String, ProPlan> proPlans) {
                if (proPlans == null) {
                    return
                }
                plans.clear()
                plans.putAll(proPlans)
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        for (String planId : proPlans.keySet()) {
                            updatePrice(proPlans.get(planId))
                        }
                    }
                })
            }
        })
    }

    protected fun updatePrice(plan: ProPlan) {
        content.setVisibility(View.VISIBLE)
        String bonus = plan.formatRenewalBonusExpected(this)
        CharSequence totalCost = getString(R.string.total_cost, plan.getCostWithoutTaxStr())
        if (plan.getDiscount() > 0) {
            totalCost += " - "
            int startForegroundPos = totalCost.length()
            String discount = getString(R.string.discount, String.valueOf(Math.round(plan.getDiscount() * 100)))
            totalCost += discount
            SpannableString totalCostSpanned = new SpannableString(totalCost)
            totalCostSpanned.setSpan(new ForegroundColorSpan(ContextCompat.getColor(this, R.color.secondary_pink)), startForegroundPos, totalCost.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            totalCost = totalCostSpanned
        }
        String oneMonth = plan.getFormatterPriceOneMonth()
        String durationFormat = plan.getFormatPriceWithBonus(this, true)
        if (plan.numYears() == 1) {
            itemPlanYear1.setVisibility(View.VISIBLE)
            tvOneMonthCostFirst.setText(oneMonth)
            tvTotalCostFirst.setText(totalCost)
            itemPlanYear1.setTag(plan.getId())
            tvDurationFirst.setText(durationFormat)
            if (plan.isBestValue()) {
                mostPopularYear1.setVisibility(View.VISIBLE)
                itemPlanYear1.setSelected(true)
            }
        } else {
            itemPlanYear2.setVisibility(View.VISIBLE)
            tvTwoMonthCostSecond.setText(oneMonth)
            tvTotalCostSecond.setText(totalCost)
            itemPlanYear2.setTag(plan.getId())
            if (LanternApp.getSession().isProUser()) {
                tvRenew.setVisibility(View.VISIBLE)
                LocalDateTime localDateTime = LanternApp.getSession().getExpiration()
                if (DateUtil.INSTANCE.isToday(localDateTime)) {
                    tvRenew.setText(getString(R.string.membership_ends_today, bonus))
                } else if (DateUtil.INSTANCE.isBefore(localDateTime)) {
                    tvRenew.setText(getString(R.string.membership_has_expired, bonus))
                } else {
                    tvRenew.setText(getString(R.string.membership_end_soon, bonus))
                }
            } else {
                tvRenew.setVisibility(View.GONE)
            }
            if (plan.isBestValue()) {
                mostPopularYear2.setVisibility(View.VISIBLE)
                itemPlanYear2.setSelected(true)
            }
            tvDurationSecond.setText(durationFormat)
        }
    }

    private fun selectPlan(view: View) {
        if (view.getTag() == null) {
            return
        }
        final String planId = (String) view.getTag()
        Logger.debug(TAG, "Plan selected: " + planId)

        final Map<Integer, String> params = new HashMap<>()
        params.put(Analytics.DIMENSION_PLAN_ID, planId)
        Analytics.event(
                this,
                Analytics.CATEGORY_PURCHASING,
                "plan_selected",
                params)

        LanternApp.getSession().setProPlan(plans.get(planId))
        startActivity(new Intent(this, CheckoutActivity_.class))
    }

    companion object {
        private val TAG = PlansActivity::class.java.name
        private lanternClient:LanternHttpClient = LanternApp.getLanternHttpClient()
    }
}
