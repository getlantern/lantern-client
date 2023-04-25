package org.getlantern.lantern.model;

import android.content.Context
import android.text.TextUtils

import com.google.gson.annotations.SerializedName

import org.getlantern.lantern.R
import org.getlantern.mobilesdk.Logger
import java.util.Currency
import java.util.Locale

data class ProPlan(
    @SerializedName("id") val id: String,
    @SerializedName("description") val description:String,
    @SerializedName("bestValue") val bestValue:Boolean,
    @SerializedName("duration") var duration:Map<String, Int>,
    @SerializedName("price") var price:Map<String, Long>,
    @SerializedName("priceWithoutTax") val priceWithoutTax:Map<String, Long>,
    @SerializedName("usdPrice")  val usdEquivalentPrice:Long,
    @SerializedName("renewalBonusExpected") var renewalBonusExpected:MutableMap<String, Int>,
    @SerializedName("expectedMonthlyPrice") var expectedMonthlyPrice:MutableMap<String, Long>,
    @SerializedName("discount") val discount:Float
) {

    private lateinit var tax: Map<String, Long>
    private lateinit var currencyCode: String
    private lateinit var costStr: String
    private lateinit var costWithoutTaxStr: String
    private lateinit var taxStr: String
    private var locale: Locale = Locale.getDefault()
    private lateinit var renewalText: String
    private lateinit var totalCost: String
    private lateinit var totalCostBilledOneTime: String
    private lateinit var formattedBonus: String
    private lateinit var oneMonthCost: String
    private lateinit var formattedDiscount: String

    init {
        calculateExpectedMonthlyPrice()
        formatCost()
    }

    fun updateRenewalBonusExpected(renewalBonusExpected: MutableMap<String, Int>) {
        this.renewalBonusExpected = renewalBonusExpected
        calculateExpectedMonthlyPrice()
    }

    fun getRenewalBonusExpected():MutableMap<String, Int> {
        return renewalBonusExpected
    }

    /**
     * The formula in here matches the calculation in the pro-servers /plans endpoint
     */
    private fun calculateExpectedMonthlyPrice() {
        this.expectedMonthlyPrice = mutableMapOf<String, Long>()
        val monthsPerYear:Int = 12
        val daysPerMonth:Int = 30
        var bonusMonths:Int? = renewalBonusExpected.get("months")
        var bonusDays:Int? = renewalBonusExpected.get("days")
        if (bonusMonths == null) {
            bonusMonths = 0
        }
        if (bonusDays == null) {
            bonusDays = 0
        }
        val expectedMonths:Double = (numYears() * monthsPerYear) + bonusMonths + (bonusDays.toDouble() / daysPerMonth.toDouble())
        for ((currency, priceWithTax) in this.price) {
            this.expectedMonthlyPrice.put(currency, priceWithTax / expectedMonths.toLong())
        }
    }

    fun numYears():Int? {
        return duration.get("years")
    }

    fun formatRenewalBonusExpected(context: Context):String {
        val bonusMonths = renewalBonusExpected.get("months")
        val bonusDays = renewalBonusExpected.get("days")
        var bonusParts:List<String> = listOf<String>()
        if (bonusMonths != null && bonusMonths > 0) {
            bonusParts += context.getResources().getQuantityString(R.plurals.month, bonusMonths, bonusMonths)
        }
        if (bonusDays != null && bonusDays > 0) {
            bonusParts += context.getResources().getQuantityString(R.plurals.day, bonusDays, bonusDays)
        }
        return TextUtils.join(" ", bonusParts)
    }

    fun getPrice():Map<String, Long> {
        return price
    }

    fun getCurrencyPrice():Long? {
        return price.get(currencyCode)
    }

    fun getUSDEquivalentPrice():Long {
        return usdEquivalentPrice
    }

    @SerializedName("price")
    fun setPrice(price: Map<String, Long>) {
        this.price = price
    }

    @SerializedName("duration")
    fun setDuration(duration: Map<String, Int>) {
        this.duration = duration
    }

    @SerializedName("renewalText")
    fun setRenewalText(renewalText:String) {
        this.renewalText = renewalText
    }

    @SerializedName("totalCost")
    fun setTotalCost(totalCost:String) {
        this.totalCost = totalCost
    }

    @SerializedName("totalCost")
    fun setTotalCostBilledOneTime(totalCostBilledOneTime: String) {
        this.totalCostBilledOneTime = totalCostBilledOneTime
    }

    @SerializedName("formattedBonus")
    fun setFormattedBonus(formattedBonus: String) {
        this.formattedBonus = formattedBonus
    }

    @SerializedName("oneMonthCost")
    fun setOneMonthCost(oneMonthCost: String) {
        this.oneMonthCost = oneMonthCost
    }

    @SerializedName("formattedDiscount")
    fun setFormattedDiscount(formattedDiscount: String) {
        this.formattedDiscount = formattedDiscount
    }

    fun setLocale(locale: Locale) {
        this.locale = locale
    }

    fun getLocale():Locale {
        return locale
    }

    fun getId():String {
        return id
    }

    fun getDescription():String {
        return description
    }

    fun getCostStr():String {
        return costStr;
    }

    fun getCostWithoutTaxStr():String {
        return costWithoutTaxStr;
    }

    fun getTaxStr():String {
        return taxStr
    }

    fun getCurrency():String {
        return currencyCode
    }

    fun getCurrencyObj():Currency {
        var currency:Currency? = null
        try {
            currency = currencyForCode(currencyCode)
        } catch (iae:IllegalArgumentException) {
            Logger.error(TAG, "Possibly invalid currency code: " + currencyCode + ": " + iae.message)
        }
        if (currency == null) {
            currency = currencyForCode(defaultCurrencyCode)
        }
        return currency
    }

    private fun currencyForCode(currencyCode: String):Currency {
        try {
            if (currencyCode != null) {
                // It seems that older Android versions require this to be upper case
                this.currencyCode = currencyCode.toUpperCase()
            }
            return Currency.getInstance(currencyCode)
        } catch (iae:IllegalArgumentException) {
            throw IllegalArgumentException("Unable to get currency for " + currencyCode + ": " + iae.message, iae.cause)
        }
    }

    fun getFormattedPrice():String {
        return getFormattedPrice(price)
    }

    fun getFormattedPriceOneMonth():String {
        return getFormattedPrice(expectedMonthlyPrice, true)
    }

    fun getFormattedPrice(price: MutableMap<String, Long>):String {
        return getFormattedPrice(price, false)
    }

    fun getFormattedPrice(price: MutableMap<String, Long>, formatFloat:Boolean):String {
        var formattedPrice:String
        val currencyPrice:Long = price.get(currencyCode)
        if (currencyPrice == null) {
            return ""
        }
        if (currencyCode.equals("irr", ignoreCase = true)) {
            if (formatFloat) {
                formattedPrice = Utils.convertEasternArabicToDecimalFloat(currencyPrice / 100f)
            } else {
                formattedPrice = Utils.convertEasternArabicToDecimal(currencyPrice / 100)
            }
        } else {
            if (formatFloat) {
                formattedPrice = String.format(Locale.getDefault(), "%.2f", currencyPrice / 100f)
            } else {
                formattedPrice = String.valueOf(currencyPrice / 100)
            }
        }
        return String.format(PLAN_COST, getSymbol(), formattedPrice)
    }

    fun getSymbol():String {
        val currency:Currency = getCurrencyObj()
        return currency.getSymbol()
    }

    fun formatCost() {
        if (price == null || price.entrySet() == null) {
            return
        }
        val entry:Map.Entry<String, Long> = price.entrySet().iterator().next()
        this.currencyCode = entry.getKey()
        this.costStr = getFormattedPrice(price)
        if (priceWithoutTax != null) {
            this.costWithoutTaxStr = getFormattedPrice(priceWithoutTax)
            this.taxStr = getFormattedPrice(tax)
        } else {
            this.costWithoutTaxStr = this.costStr
        }
    }

    fun getFormatPriceWithBonus(context: Context, useNumber: Boolean):String {
        var durationFormat:String
        if (useNumber) {
            durationFormat = context.getString(R.string.plan_duration, numYears())
        } else {
            if (numYears() == 1) {
                durationFormat = context.getString(R.string.one_year_lantern_pro)
            } else {
                durationFormat = context.getString(R.string.two_years_lantern_pro)
            }
        }

        val bonus:String = formatRenewalBonusExpected(context)
        if (!bonus.isEmpty()) {
            durationFormat += " + " + formatRenewalBonusExpected(context)
        }
        return durationFormat
    }

    fun isBestValue():Boolean {
        return bestValue
    }

    fun getDiscount():Float {
        return discount
    }

    companion object {
        private val TAG: String = ProPlan::class.java.simpleName
        const val PLAN_COST = "%1%s%2%s"
        const val defaultCurrencyCode = "usd"
    }
}
