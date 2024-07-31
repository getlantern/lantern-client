package org.getlantern.lantern.model

import java.util.Currency
import java.util.Locale
import kotlinx.serialization.Serializable
import org.getlantern.mobilesdk.Logger

@Serializable
data class ProPlan(
    val id: String,
    var description: String,
    var price: MutableMap<String, Long> = mutableMapOf<String, Long>(),
    var priceWithoutTax: MutableMap<String, Long> = mutableMapOf<String, Long>(),
    var bestValue: Boolean = false,
    var duration: MutableMap<String, Int> = mutableMapOf<String, Int>(),
    var discount: Double = 0.0,
    var renewalBonusExpected: MutableMap<String, Int> = mutableMapOf<String, Int>(),
    var expectedMonthlyPrice: MutableMap<String, Long> = mutableMapOf<String, Long>(),
    var renewalText: String = "",
    var totalCost: String = "",
    var currencyCode: String = "",
    var oneMonthCost: String = ""
) {
    var currency = currencyCode
    var formattedBonus: String = ""
    var formattedDiscount: String = ""
    var costStr: String = ""
    var costWithoutTaxStr: String? = null
    var totalCostBilledOneTime: String = ""

    fun formattedCost(costs: MutableMap<String, Long>, formatFloat:Boolean = false):String {
        if (currencyCode == "" || costs.get(currencyCode) == null) return ""
        val currencyPrice:Long = costs.get(currencyCode)!!
        var formattedPrice = ""
        formattedPrice = when (currencyCode.lowercase()) {
            "irr" -> if (formatFloat) Utils.convertEasternArabicToDecimalFloat(currencyPrice / 100f) else Utils.convertEasternArabicToDecimal(currencyPrice / 100)
            else -> if (formatFloat) String.format(Locale.getDefault(), "%.2f", currencyPrice / 100f) else (currencyPrice / 100).toString()
        }
        return String.format("%s%s", symbol(), formattedPrice)
    }

    fun formattedPrice() = formattedCost(price)

    fun formattedPriceOneMonth() = formattedCost(expectedMonthlyPrice, true)

    fun formatCost() {
        if (currencyCode.isNullOrEmpty() && price.size > 0) this.currencyCode = price.keys.first()
        this.costStr = formattedCost(price)
        if (priceWithoutTax.size > 0) {
            this.costWithoutTaxStr = formattedCost(priceWithoutTax)
        } else {
            this.costWithoutTaxStr = costStr
        }
    }

    private fun currencyObject(): Currency? {
        return if (currencyCode.isNullOrEmpty()) null else Currency.getInstance(currencyCode)
    }

    private fun symbol(): String {
        return currencyObject()?.let {
            return it.symbol
        } ?: ""
    }
}
