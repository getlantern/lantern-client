package org.getlantern.lantern.util

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.text.TextUtils
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.model.ProPlan
import org.getlantern.lantern.util.DateUtil.isBefore
import org.getlantern.lantern.util.DateUtil.isToday
import org.joda.time.LocalDateTime

object PlansUtil {
    @JvmStatic
    fun updatePrice(activity: Context, plan: ProPlan) {
        val formattedBonus = formatRenewalBonusExpected(activity, plan.renewalBonusExpected, false)
        val totalCost = plan.costWithoutTaxStr
        var totalCostBilledOneTime = activity.resources.getString(R.string.total_cost, totalCost)
        var formattedDiscount = ""
        if (plan.discount > 0) {
            formattedDiscount =
                activity.resources.getString(
                    R.string.discount,
                    Math.round(plan.discount * 100).toString()
                )
        }
        val oneMonthCost = plan.formattedPriceOneMonth
        plan.renewalText = proRenewalText(activity.resources, formattedBonus)
        plan.totalCostBilledOneTime = totalCostBilledOneTime
        plan.oneMonthCost = oneMonthCost
        plan.formattedBonus = formattedBonus
        plan.setFormattedDiscount(formattedDiscount)
        plan.totalCost = totalCost
    }

    private fun proRenewalText(resources: Resources, formattedBonus: String): String {
        if (!LanternApp.getSession().isProUser) return ""
        val proExpiration = LanternApp.getSession().getExpiration()
        if (proExpiration == null) return ""
        return when {
            proExpiration.isBefore() -> {
                resources.getString(R.string.membership_has_expired, formattedBonus)
            }

            proExpiration.isToday() -> {
                resources.getString(R.string.membership_ends_today, formattedBonus)
            }

            proExpiration.isBefore(LocalDateTime.now().plusMonths(3)) -> {
                resources.getString(R.string.membership_end_soon, formattedBonus)
            }

            else -> ""
        }
    }

    // Formats the renewal bonus
    // longForm == false -> a day-only format (e.g. "45 days")
    // longForm == true -> month and day format (e.g. "1 month and 15 days"
    private fun formatRenewalBonusExpected(
        activity: Context, planBonus: MutableMap<String, Int>,
        longForm: Boolean
    ): String {
        val bonusMonths: Int? = planBonus["months"]
        val bonusDays: Int? = planBonus["days"]
        val bonusParts: MutableList<String?> = java.util.ArrayList()
        if (bonusMonths == null && bonusDays == null) return ""
        if (longForm) {
            // "1 month and 15 days"
            if (bonusMonths != null && bonusMonths > 0) {
                bonusParts.add(
                    activity.resources.getQuantityString(
                        R.plurals.month,
                        bonusMonths.toInt(),
                        bonusMonths,
                    ),
                )
            }
            if (bonusDays != null && bonusDays > 0) {
                bonusParts.add(
                    activity.resources.getQuantityString(
                        R.plurals.day,
                        bonusDays.toInt(),
                        bonusDays
                    )
                )
            }
            return TextUtils.join(" ", bonusParts)
        } else {
            return activity.resources.getQuantityString(
                R.plurals.day,
                (bonusMonths!! * 30 + bonusDays!!),
                (bonusMonths * 30 + bonusDays)
            )
        }
    }
}
