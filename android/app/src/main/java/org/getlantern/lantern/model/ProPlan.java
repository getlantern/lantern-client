package org.getlantern.lantern.model;

import android.content.Context;
import android.text.TextUtils;

import com.google.gson.annotations.SerializedName;

import org.getlantern.lantern.R;
import org.getlantern.mobilesdk.Logger;

import java.util.ArrayList;
import java.util.Currency;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ProPlan {
    private static final String TAG = ProPlan.class.getName();

    @SerializedName("id")
    private String id;
    @SerializedName("description")
    private String description;
    @SerializedName("bestValue")
    private boolean bestValue;
    @SerializedName("duration")
    private Map<String, Integer> duration;
    @SerializedName("price")
    private Map<String, Long> price;
    private Map<String, Long> priceWithoutTax;
    private Map<String, Long> tax;
    @SerializedName("usdPrice")
    private Long usdEquivalentPrice;
    @SerializedName("renewalBonusExpected")
    private Map<String, Integer> renewalBonusExpected;
    @SerializedName("expectedMonthlyPrice")
    private Map<String, Long> expectedMonthlyPrice;
    @SerializedName("discount")
    private float discount;
    @SerializedName("level")
    private String level;

    private String currencyCode;
    private String costStr;
    private String costWithoutTaxStr;
    private String taxStr;
    private Locale locale = Locale.getDefault();
    private String renewalText;
    private String totalCost;
    private String totalCostBilledOneTime;
    private String formattedBonus;
    private String oneMonthCost;
    private String formattedDiscount;

    private static final String PLAN_COST = "%1$s%2$s";
    private static final String defaultCurrencyCode = "usd";

    public ProPlan() {
        // default constructor
    }

    public ProPlan(String id, Map<String, Long> price, Map<String, Long> priceWithoutTax,
                   boolean bestValue, Map<String, Integer> duration) {
        this.id = id;
        this.price = price;
        this.priceWithoutTax = priceWithoutTax;
        this.tax = new HashMap<>();
        this.renewalBonusExpected = new HashMap<>();
        this.bestValue = bestValue;
        this.duration = duration;
        for (Map.Entry<String, Long> entry : this.price.entrySet()) {
            String currency = entry.getKey();
            Long priceWithTax = entry.getValue();
            Long specificPriceWithoutTax = priceWithoutTax.get(currency);
            if (specificPriceWithoutTax == null) {
                specificPriceWithoutTax = priceWithTax;
            }
            long tax = priceWithTax - specificPriceWithoutTax;
            if (tax > 0) {
                this.tax.put(currency, tax);
            }
        }
        calculateExpectedMonthlyPrice();
        this.formatCost(); // this will set the currency code for us
    }

    public void updateRenewalBonusExpected(Map<String, Integer> renewalBonusExpected) {
        this.renewalBonusExpected = renewalBonusExpected;
        calculateExpectedMonthlyPrice();
    }

    public Map<String, Integer> getRenewalBonusExpected() {
        return renewalBonusExpected;
    }

    /**
     * The formula in here matches the calculation in the pro-servers /plans endpoint
     */
    private void calculateExpectedMonthlyPrice() {
        this.expectedMonthlyPrice = new HashMap<>();
        final Integer monthsPerYear = 12;
        final Integer daysPerMonth = 30;
        Integer bonusMonths = renewalBonusExpected.get("months");
        Integer bonusDays = renewalBonusExpected.get("days");
        if (bonusMonths == null) {
            bonusMonths = 0;
        }
        if (bonusDays == null) {
            bonusDays = 0;
        }
        Double expectedMonths = (numYears() * monthsPerYear) + bonusMonths + (bonusDays.doubleValue() / daysPerMonth.doubleValue());
        for (Map.Entry<String, Long> entry : this.price.entrySet()) {
            String currency = entry.getKey();
            Long priceWithTax = entry.getValue();
            this.expectedMonthlyPrice.put(currency, Double.valueOf(priceWithTax / expectedMonths).longValue());
        }
    }

    public Integer numYears() {
        return duration.get("years");
    }

    public String formatRenewalBonusExpected(Context context) {
        Integer bonusMonths = renewalBonusExpected.get("months");
        Integer bonusDays = renewalBonusExpected.get("days");
        List<String> bonusParts = new ArrayList<>();
        if (bonusMonths != null && bonusMonths > 0) {
            bonusParts.add(context.getResources().getQuantityString(R.plurals.month, bonusMonths, bonusMonths));
        }
        if (bonusDays != null && bonusDays > 0) {
            bonusParts.add(context.getResources().getQuantityString(R.plurals.day, bonusDays, bonusDays));
        }
        return TextUtils.join(" ", bonusParts);
    }

    @SerializedName("renewalText")
    public void setRenewalText(final String renewalText) {
        this.renewalText = renewalText;
    }

    public String getRenewalText() {
        return renewalText;
    }

    @SerializedName("totalCost")
    public void setTotalCost(final String totalCost) {
        this.totalCost = totalCost;
    }

    public String getTotalCost() {
        return totalCost;
    }

    @SerializedName("totalCost")
    public void setTotalCostBilledOneTime(final String totalCostBilledOneTime) {
        this.totalCostBilledOneTime = totalCostBilledOneTime;
    }

    public String getTotalCostBilledOneTime() {
        return totalCostBilledOneTime;
    }

    @SerializedName("formattedBonus")
    public void setFormattedBonus(final String formattedBonus) {
        this.formattedBonus = formattedBonus;
    }

    public String getFormattedBonus() {
        return formattedBonus;
    }

    @SerializedName("oneMonthCost")
    public void setOneMonthCost(final String oneMonthCost) {
        this.oneMonthCost = oneMonthCost;
    }

    public String getOneMonthCost() {
        return oneMonthCost;
    }

    @SerializedName("formattedDiscount")
    public void setFormattedDiscount(final String formattedDiscount) {
        this.formattedDiscount = formattedDiscount;
    }

    public Map<String, Long> getPrice() {
        return price;
    }

    public Map<String, Integer> getDuration() {
        return duration;
    }

    public Long getCurrencyPrice() {
        return price.get(currencyCode);
    }

    public Long getUSDEquivalentPrice() {
        return usdEquivalentPrice;
    }

    @SerializedName("price")
    public void setPrice(final Map<String, Long> price) {
        this.price = price;
    }

    @SerializedName("duration")
    public void setDuration(final Map<String, Integer> duration) {
        this.duration = duration;
    }

    public String toString() {
        return String.format("Plan: %s Description: %s Num Years %d",
                id, description, numYears());
    }

    public void setLocale(Locale locale) {
        this.locale = locale;
    }

    public Boolean getBestValue() {
        return bestValue;
    }

    public Locale getLocale() {
        return locale;
    }

    public String getId() {
        return id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String desc) {
        description = desc;
    }

    public String getCostStr() {
        return costStr;
    }

    public String getCostWithoutTaxStr() {
        return costWithoutTaxStr;
    }

    public String getTaxStr() {
        return taxStr;
    }

    public String getCurrency() {
        return currencyCode;
    }

    public Currency getCurrencyObj() {
        Currency currency = null;
        try {
            currency = currencyForCode(currencyCode);
        } catch (IllegalArgumentException iae) {
            Logger.error(TAG, "Possibly invalid currency code: " + currencyCode + ": " + iae.getMessage());
        }
        if (currency == null) {
            currency = currencyForCode(defaultCurrencyCode);
        }
        return currency;
    }

    private Currency currencyForCode(String currencyCode) {
        try {
            if (currencyCode != null) {
                // It seems that older Android versions require this to be upper case
                currencyCode = currencyCode.toUpperCase();
            }
            return Currency.getInstance(currencyCode);
        } catch (IllegalArgumentException iae) {
            throw new IllegalArgumentException("Unable to get currency for " + currencyCode + ": " + iae.getMessage(), iae.getCause());
        }
    }

    public String getFormattedPrice() {
        return getFormattedPrice(price);
    }

    public String getFormattedPriceOneMonth() {
        return getFormattedPrice(expectedMonthlyPrice, true);
    }

    public String getFormattedPrice(Map<String, Long> price) {
        return getFormattedPrice(price, false);
    }

    private String getFormattedPrice(Map<String, Long> price, boolean formatFloat) {
        final String formattedPrice;
        Long currencyPrice = price.get(currencyCode);
        if (currencyPrice == null) {
            return "";
        }
        if (currencyCode.equalsIgnoreCase("irr")) {
            if (formatFloat) {
                formattedPrice = Utils.convertEasternArabicToDecimalFloat(currencyPrice / 100f);
            } else {
                formattedPrice = Utils.convertEasternArabicToDecimal(currencyPrice / 100);
            }
        } else {
            if (formatFloat) {
                formattedPrice = String.format(Locale.getDefault(), "%.2f", currencyPrice / 100f);
            } else {
                formattedPrice = String.valueOf(currencyPrice / 100);
            }
        }
        return String.format(PLAN_COST, getSymbol(), formattedPrice);
    }

    public String getSymbol() {
        final Currency currency = getCurrencyObj();
        return currency.getSymbol();
    }

    public void formatCost() {
        if (price == null || price.entrySet() == null) {
            return;
        }
        Map.Entry<String, Long> entry = price.entrySet().iterator().next();
        this.currencyCode = entry.getKey();
        this.costStr = getFormattedPrice(price);
        if (priceWithoutTax != null) {
            this.costWithoutTaxStr = getFormattedPrice(priceWithoutTax);
            this.taxStr = getFormattedPrice(tax);
        } else {
            this.costWithoutTaxStr = this.costStr;
        }
    }

    public String getFormatPriceWithBonus(Context context, boolean useNumber) {
        String durationFormat;
        if (useNumber) {
            durationFormat = context.getString(R.string.plan_duration, numYears());
        } else {
            if (numYears() == 1) {
                durationFormat = context.getString(R.string.one_year_lantern_pro);
            } else {
                durationFormat = context.getString(R.string.two_years_lantern_pro);
            }
        }

        String bonus = formatRenewalBonusExpected(context);
        if (!bonus.isEmpty()) {
            durationFormat += " + " + formatRenewalBonusExpected(context);
        }
        return durationFormat;
    }

    public boolean isBestValue() {
        return bestValue;
    }

    public float getDiscount() {
        return discount;
    }
}
