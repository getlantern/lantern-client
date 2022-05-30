package org.getlantern.lantern.util

import android.app.Activity
import android.text.TextUtils
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.util.DateUtil.isBefore
import org.getlantern.lantern.util.DateUtil.isToday

object PlansUtil {
    @JvmStatic
    fun updatePrice(activity: Activity, plan: ProPlan) {
        val formattedBonus = formatRenewalBonusExpected(activity, plan.renewalBonusExpected, true)
        val totalCost = plan.costWithoutTaxStr
        var totalCostBilledOneTime = activity.resources.getString(R.string.total_cost, totalCost)
        var formattedDiscount = ""
        if (plan.discount > 0) {
            formattedDiscount =
                activity.resources.getString(R.string.discount, Math.round(plan.discount * 100).toString())
        }
        val oneMonthCost = plan.formattedPriceOneMonth
        var renewalText = ""
        if (LanternApp.getSession().isProUser || LanternApp.getSession().isExpired()) {
            val localDateTime = LanternApp.getSession().getExpiration()
            renewalText = when {
                localDateTime.isToday() -> {
                    activity.resources.getString(R.string.membership_ends_today, formattedBonus)
                }
                // TODO: this is unreachable
                localDateTime.isBefore() -> {
                    activity.resources.getString(R.string.membership_has_expired, formattedBonus)
                }
                else -> {
                    activity.resources.getString(R.string.membership_end_soon, formattedBonus)
                }
            }
        }
        plan.setRenewalText(renewalText)
        plan.setTotalCostBilledOneTime(totalCostBilledOneTime)
        plan.setOneMonthCost(oneMonthCost)
        plan.setFormattedBonus(formattedBonus)
        plan.setFormattedDiscount(formattedDiscount)
        plan.setTotalCost(totalCost)
    }
    // TODO: we need to report this in only days
    // Formats the renewal bonus
    // longForm == false -> a day-only format (e.g. "45 days")
    // longForm==true -> month and day format (e.g. "1 month and 15 days"
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
        }
        return activity.resources.getQuantityString(R.plurals.day, (bonusMonths!! * 30 + bonusDays!!), bonusDays)
    }
}
