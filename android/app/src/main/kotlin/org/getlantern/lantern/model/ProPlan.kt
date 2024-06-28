package org.getlantern.lantern.model

import java.util.Currency

data class ProPlanNew(
    val id: String,
    val description: String,
    val bestValue: Boolean,
    val duration: Map<String, Int>,
    val price: Map<String, Long>,
    val discount: Float,
    val renewalBonusExpected: MutableMap<String, Int>,
    var oneMonthCost: String,
    var renewalText: String,
    var totalCost: String,
) {

    val currencyCode: String? = null
    var formattedDiscount: String? = null
    var formattedBonus: String = ""

    private val currency: Currency? = null
    var costStr: String? = null
    var costWithoutTaxStr: String? = null
    var totalCostBilledOneTime: String? = null

    private fun formattedCost():String {
        if (currencyCode == null || price.get(currencyCode) == null) return ""
        val currencyPrice:Long = price.get(currencyCode)!!
        var formattedPrice = ""
        formattedPrice = when (currencyCode.lowercase()) {
            "irr" -> Utils.convertEasternArabicToDecimalFloat(currencyPrice / 100f)
            else -> "%d".format(currencyPrice / 100)
        }
        return "%s%s".format(symbol(), formattedPrice)
    }

    private fun currency(): Currency? {
        return currencyCode?.let { 
            Currency.getInstance(currencyCode)
        } ?: null
    }

    private fun symbol(): String {
        return currency()?.let {
            return it.symbol
        } ?: ""
    }

    fun formatCost() {
        if (currencyCode == null) return
        costStr = formattedCost()
    }
}
