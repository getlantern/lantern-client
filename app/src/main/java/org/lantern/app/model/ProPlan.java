package org.lantern.app.model;

import com.google.gson.annotations.SerializedName;

import org.lantern.mobilesdk.Logger;

import java.util.Currency;
import java.util.HashMap;
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

    private String currencyCode;
    private String tag;
    private String costStr;
    private String costWithoutTaxStr;
    private String taxStr;
    private Locale locale = Locale.getDefault();

    private static final String PLAN_COST = "%1$s %2$s";
    private static final String defaultCurrencyCode = "usd";

    public ProPlan() {
        // default constructor
    }

    public ProPlan(String id, Map<String, Long> price, Map<String, Long> priceWithoutTax, boolean bestValue, Map<String, Integer> duration) {
        this.id = id;
        this.price = price;
        this.priceWithoutTax = priceWithoutTax;
        this.tax = new HashMap<String, Long>();
        for (Map.Entry<String, Long> entry : this.price.entrySet()) {
            String currency = entry.getKey();
            Long priceWithTax = entry.getValue();
            Long specificPriceWithoutTax = priceWithoutTax.get(currency);
            if (specificPriceWithoutTax == null) {
                specificPriceWithoutTax = priceWithTax;
            }
            this.tax.put(currency, priceWithTax - specificPriceWithoutTax);
        }
        this.bestValue = bestValue;
        this.duration = duration;
        this.formatCost(); // this will set the currency code for us
    }

    public Integer numYears() {
        return duration.get("years");
    }

    public Map<String, Long> getPrice() {
        return price;
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

    public Locale getLocale() {
        return locale;
    }

    public String getId() {
        return id;
    }

    public String getDescription() {
        return description;
    }

    public String getCostStr() {
        return costStr;
    }

    public String getCostWithoutTaxStr() { return costWithoutTaxStr; }

    public String getTaxStr() { return taxStr; }

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

    public String getFormattedPrice(Map<String, Long> price) {
        final String formattedPrice;
        Long currencyPrice = price.get(currencyCode);
        if (currencyCode.equalsIgnoreCase("irr")) {
            formattedPrice = Utils.convertEasternArabicToDecimal(currencyPrice/100);
        } else {
            formattedPrice = String.valueOf(currencyPrice/100);
        }
        return formattedPrice;
    }

    public String getSymbol() {
        final Currency currency = getCurrencyObj();
        return currency.getSymbol();
    }

    public void formatCost() {
        if (price == null || price.entrySet() == null) {
            return;
        }
        Map.Entry<String,Long> entry = price.entrySet().iterator().next();
        this.currencyCode = entry.getKey();
        final Currency currency = getCurrencyObj();
        final String symbol = getSymbol();
        this.costStr = String.format(PLAN_COST, symbol, getFormattedPrice(price));
        if (priceWithoutTax != null) {
            this.costWithoutTaxStr = String.format(PLAN_COST, symbol, getFormattedPrice(priceWithoutTax));
            this.taxStr = String.format(PLAN_COST, symbol, getFormattedPrice(tax));
        } else {
            this.costWithoutTaxStr = this.costStr;
        }
    }
}
