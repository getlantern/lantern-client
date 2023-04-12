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

    @ViewById
    @JvmField
    protected var tvOneMonthCostFirst:TextView

    @ViewById
    @JvmField
    protected var tvTwoMonthCostSecond:TextView

    @ViewById
    @JvmField
    protected var tvDurationFirst:TextView

    @ViewById
    @JvmField
    protected var tvDurationSecond:TextView

    @ViewById
    @JvmField
    protected var tvTotalCostFirst:TextView

    @ViewById
    @JvmField
    protected var tvTotalCostSecond:TextView

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
        var activateCodeContainer:View = findViewById(R.id.activateCodeContainer)
        activateCodeContainer.setVisibility(View.VISIBLE)
    }

    private fun sendScreenViewEvent() {
        Analytics.event(this, Analytics.CATEGORY_PURCHASING, "plans_view")
    }

    protected fun setPaymentGateway() {
        var params:Map<String, String> = HashMap<String, String>()
        params.put("appVersion", LanternApp.getSession().appVersion())
        params.put("country", LanternApp.getSession().getCountryCode())
        // send any payment provider we get back from Firebase to the pro
        // server
        params.put("remoteConfigPaymentProvider", LanternApp.getSession().getRemoteConfigPaymentProvider())
        params.put("deviceOS", LanternApp.getSession().deviceOS())
        var url:HttpUrl = LanternHttpClient.createProUrl("/user-payment-gateway", params)
        lanternClient.get(url, LanternHttpClient.ProCallback() {
            @Override
            public fun onFailure(var throwable:Throwable, var error:ProError) {
                if (error != null) {
                    Logger.error(TAG, "Unable to fetch user payment gateway:" + error)
                }
            }
            @Override
            public fun onSuccess(var response:Response, var result:JsonObject) {
                var params:Map<String, String> = HashMap<String, String>()

                try {
                    var provider: String = result.get("provider").getAsString()
                    if (provider != null) {
                        Logger.debug(TAG, "Payment provider is " + provider)
                        LanternApp.getSession().setPaymentProvider(provider)
                    }
                } catch (e:Exception) {
                    Logger.error(TAG, "Unable to fetch plans", e)
                    return
                }
            }
        })
    }

    protected fun updatePlans() {
        LanternApp.getPlans(LanternHttpClient.PlansCallback() {
            @Override
            public fun onFailure(var throwable:Throwable, var error:ProError) {
                if (error != null && error.getMessage() != null) {
                    ActivityExtKt.showErrorDialog(PlansActivity::class.java.name, error.getMessage())
                }
            }
            @Override
            public fun onSuccess(final proPlans:Map<String, ProPlan>) {
                if (proPlans == null) {
                    return
                }
                plans.clear()
                plans.putAll(proPlans)
                runOnUiThread(Runnable() {
                    @Override
                    public fun run() {
                    }
                })
            }
        })
    }

    protected fun updatePrice(plan: ProPlan) {
        content.setVisibility(View.VISIBLE)
        var bonus:String = plan.formatRenewalBonusExpected(this)
        var totalCost:CharSequence = getString(R.string.total_cost, plan.getCostWithoutTaxStr())
        if (plan.getDiscount() > 0) {
            totalCost += " - "
            var startForegroundPos:Int = totalCost.length()
            var discount:String = getString(R.string.discount, String.valueOf(Math.round(plan.getDiscount() * 100)))
            totalCost += discount
            var totalCostSpanned:SpannableString = new SpannableString(totalCost)
            totalCostSpanned.setSpan(new ForegroundColorSpan(ContextCompat.getColor(this, R.color.secondary_pink)), startForegroundPos, totalCost.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            totalCost = totalCostSpanned
        }
        var oneMonth:String = plan.getFormatterPriceOneMonth()
        var durationFormat:String = plan.getFormatPriceWithBonus(this, true)
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
                var localDateTime:LocalDateTime = LanternApp.getSession().getExpiration()
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
        var planId:String = view.getTag()
        Logger.debug(TAG, "Plan selected: " + planId)

        var params:Map<Integer, String> = HashMap<Integer, String>()
        params.put(Analytics.DIMENSION_PLAN_ID, planId)
        Analytics.event(
                this,
                Analytics.CATEGORY_PURCHASING,
                "plan_selected",
                params)

        LanternApp.getSession().setProPlan(plans.get(planId))
        startActivity(Intent(this, CheckoutActivity_::class.java.name))
    }

    companion object {
        private val TAG = PlansActivity::class.java.name
        private val lanternClient:LanternHttpClient = LanternApp.getLanternHttpClient()
    }
}
