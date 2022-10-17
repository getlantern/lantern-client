package org.getlantern.lantern.util

import android.app.Activity
import android.text.TextUtils
import com.google.gson.JsonObject
import io.flutter.plugin.common.MethodChannel
import okhttp3.Response
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.CheckoutActivity
import org.getlantern.lantern.model.LanternHttpClient
import org.getlantern.lantern.model.LanternHttpClient.ProCallback
import org.getlantern.lantern.model.ProError
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.util.DateUtil.isBefore
import org.getlantern.lantern.util.DateUtil.isToday
import org.getlantern.mobilesdk.Logger

object PlansUtil {
    private val lanternClient = LanternApp.getLanternHttpClient()

    @JvmStatic
    fun updatePrice(activity: Activity, plan: ProPlan) {
        val totalCost = plan.costWithoutTaxStr
        var totalCostBilledOneTime = activity.resources.getString(R.string.total_cost, totalCost)
        var formattedDiscount = ""
        if (plan.discount > 0) {
            formattedDiscount =
                activity.resources.getString(R.string.discount, Math.round(plan.discount * 100).toString())
        }
        val oneMonthCost = plan.formattedPriceOneMonth
        plan.setTotalCostBilledOneTime(totalCostBilledOneTime)
        plan.setOneMonthCost(oneMonthCost)
        plan.setFormattedDiscount(formattedDiscount)
        plan.setTotalCost(totalCost)
    }

    @JvmStatic
    fun checkEmailExistence(email: String, result: MethodChannel.Result) {
        val params: MutableMap<String, String> = HashMap()
        params["email"] = email
        // TODO: not sure this is working correctly
        lanternClient.get(LanternHttpClient.createProUrl(
            "/email-exists",
            params
        ), object : ProCallback {
            override fun onFailure(throwable: Throwable?, error: ProError?) {
                Logger.debug(
                    "checkEmailExistence",
                    "Email $email already exists"
                )
                result.error(
                    "unknownError",
                    LanternApp.getAppContext().resources.getString(R.string.email_in_use),
                    null,
                )
                return
            }

            override fun onSuccess(response: Response, result: JsonObject) {
                Logger.debug(
                    "checkEmailExistence",
                    "Email successfully validated $email"
                )
                LanternApp.getSession().setEmail(email)
            }
        })
    }

    @JvmStatic
    // Returns the days/months string that we display in the renewal text for Pro or Platinum
    fun calculateRenewalText(activity: Activity, plan: ProPlan) {
        var renewalText = ""
        val formattedBonus = formatRenewalBonusExpected(activity, plan.renewalBonusExpected, false)
        if (LanternApp.getSession().isProUser || LanternApp.getSession().isExpired()) {
            val localDateTime = LanternApp.getSession().getExpiration()
            renewalText = when {
                localDateTime.isToday() -> {
                    activity.resources.getString(R.string.membership_ends_today, formattedBonus)
                }
                localDateTime.isBefore() -> {
                    activity.resources.getString(R.string.membership_has_expired, formattedBonus)
                }
                else -> {
                    activity.resources.getString(R.string.membership_end_soon, formattedBonus)
                }
            }
        }
        plan.setFormattedBonus(formattedBonus)
        // We are only saving the renewalText from the bestValue == true plan
        if (plan.isBestValue) LanternApp.getSession().setRenewalText(renewalText)
    }

    @JvmStatic
    fun getRenewalOrUpgrade(incomingLevel: String) {
        // Flag Renewal or Upgrade
        val currentLevel = LanternApp.getSession().getUserLevel()
        var renewalOrUpgrade = ""
        if (currentLevel.toString() == incomingLevel) {
            renewalOrUpgrade = "renewal"
        }
        LanternApp.getSession().setUpgradeOrRenewal(renewalOrUpgrade!!)
    }

    // Formats the renewal bonus
    // longForm == false -> a day-only format (e.g. "45 days")
    // longForm == true -> month and day format (e.g. "1 month and 15 days"
    private fun formatRenewalBonusExpected(activity: Activity, planBonus: MutableMap<String, Int>, longForm: Boolean): String? {
        val bonusMonths: Int? = planBonus["months"]
        val bonusDays: Int? = planBonus["days"]
        val bonusParts: MutableList<String?> = java.util.ArrayList()
        if (bonusMonths == null && bonusDays == null) return null
        if (longForm) {
            // "1 month and 15 days"
            if (bonusMonths != null && bonusMonths > 0) {
                bonusParts.add(
                    activity.resources.getQuantityString(
                        R.plurals.month,
                        bonusMonths.toInt(),
                        bonusMonths
                    )
                )
            }
            if (bonusDays != null && bonusDays > 0) {
                bonusParts.add(activity.resources.getQuantityString(R.plurals.day, bonusDays.toInt(), bonusDays))
            }
            return TextUtils.join(" ", bonusParts)
        } else {
            return activity.resources.getQuantityString(R.plurals.day, (bonusMonths!! * 30 + bonusDays!!), (bonusMonths!! * 30 + bonusDays!!))
        }
    }
}
