package org.getlantern.lantern.model

import java.util.Currency

data class ProPlan(
    val id: String,
    var description: String,
    var price: Map<String, Long> = mutableMapOf<String, Long>(),
    var priceWithoutTax: Map<String, Long> = mutableMapOf<String, Long>(),
    var bestValue: Boolean = false,
    var duration: Map<String, Int> = mutableMapOf<String, Int>(),
    var discount: Double = 0.0,
    var renewalBonusExpected: MutableMap<String, Int> = mutableMapOf<String, Int>(),
    var expectedMonthlyPrice: MutableMap<String, Int> = mutableMapOf<String, Int>(),
    var renewalText: String = "",
    var totalCost: String = "",
    var currencyCode: String = "",
    var oneMonthCost: String = ""
) {
    private val currency: Currency? = null
    var formattedBonus: String = ""
    var formattedDiscount: String = ""
    var costStr: String = ""
    var costWithoutTaxStr: String? = null
    var totalCostBilledOneTime: String = ""

    fun formattedCost():String {
        if (currencyCode == "" || price.get(currencyCode) == null) return ""
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
}
