package org.getlantern.lantern.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Paint;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.google.android.material.textfield.TextInputLayout;
import com.google.gson.JsonObject;
import com.stripe.android.ApiResultCallback;
import com.stripe.android.Stripe;
import com.stripe.android.model.CardParams;
import com.stripe.android.model.ExpirationDate;
import com.stripe.android.model.Token;
import com.stripe.android.view.CardNumberEditText;
import com.stripe.android.view.ExpiryDateEditText;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.MaterialUtil;
import org.getlantern.lantern.model.PaymentHandler;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProPlan;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.FormBody;
import okhttp3.Response;

@EActivity(R.layout.checkout)
public class CheckoutActivity extends BaseFragmentActivity implements PurchasesUpdatedListener {

    public static final String TERMS_OF_SERVICE_URL = "https://s3.amazonaws.com/lantern/Lantern-TOS.html";
    private static final String TAG = CheckoutActivity.class.getName();
    private static final String STRIPE_TAG = TAG + ".stripe";
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    protected final ClickSpan.OnClickListener clickSpan = new ClickSpan.OnClickListener() {
        @Override
        public void onClick() {
            final Intent intent = new Intent(CheckoutActivity.this, WebViewActivity_.class);
            intent.putExtra("url", TERMS_OF_SERVICE_URL);
            startActivity(intent);
        }
    };
    @ViewById
    EditText emailInput, referralCodeInput, cvcInput;

    @ViewById
    CardNumberEditText cardInput;

    @ViewById
    ExpiryDateEditText expirationInput;

    @ViewById
    TextInputLayout emailLayout, cardLayout, expirationLayout, cvcLayout, referralCodeLayout;

    @ViewById
    TextView header, price, priceWithoutTax, tax, productText, togglePaymentMethod, termsOfServiceText;

    @ViewById
    View stripeSection, taxLabel;

    @ViewById
    Button continueBtn;

    @ViewById
    TextView tvStepDescription;

    @Extra
    String headerText;

    String forcedPaymentProvider;
    private ProgressDialog dialog;
    private boolean useStripe;

    private void closeDialog() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    @AfterViews
    void afterViews() {
        boolean isPlayVersion = LanternApp.getSession().isPlayVersion();
        useStripe = !isPlayVersion && !LanternApp.getSession().defaultToAlipay();
        ProPlan plan = LanternApp.getSession().getSelectedPlan();
        price.setText(plan.getCostStr());
        String taxString = plan.getTaxStr();
        if (!TextUtils.isEmpty(taxString)) {
            tax.setText(taxString);
            priceWithoutTax.setText(plan.getCostWithoutTaxStr());
        } else {
            tax.setVisibility(View.GONE);
            priceWithoutTax.setVisibility(View.GONE);
            taxLabel.setVisibility(View.GONE);
        }
        productText.setText(plan.getFormatPriceWithBonus(this, false));

        if (isPlayVersion) {
            continueBtn.setEnabled(false);
        }

        // XXX <25-12-2022, soltzen> As of today, RU users default to Freekassa.
        // We just need the email from this form (to check for duplicate
        // emails) and nothing else.
        // See here for more info: https://github.com/getlantern/lantern-internal/issues/5863
        if (LanternApp.getSession().isRussianUser()) {
            Logger.d(TAG, "Detected RU: Forcing Freekassa payment provider");
            forcedPaymentProvider = "freekassa";
            useStripe = false;
            cardLayout.setVisibility(View.GONE);
            expirationLayout.setVisibility(View.GONE);
            cvcLayout.setVisibility(View.GONE);
            referralCodeLayout.setVisibility(View.GONE);
            togglePaymentMethod.setVisibility(View.GONE);
        }

        // update the screen title with a custom headerText
        if (headerText != null && !headerText.equals("")) {
            header.setText(headerText);
        }

        TextWatcher validator = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                validate();
            }
        };

        View.OnFocusChangeListener focusListener = new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                validate();
            }
        };

        EditText.OnEditorActionListener submitForm = new EditText.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE && continueBtn.isEnabled()) {
                    continueBtn.performClick();
                    return true;
                }
                return false;
            }
        };

        String email = LanternApp.getSession().email();
        if (!"".equals(email)) {
            emailInput.setText(email);
        } else {
            emailInput.requestFocus();
        }

        boolean isRenewal = LanternApp.getSession().isProUser();
        if (isRenewal) {
            // Don't allow changing email of existing pro user
            emailInput.setEnabled(false);
        } else {
            emailInput.addTextChangedListener(validator);
            emailInput.setOnFocusChangeListener(focusListener);
        }

        cardInput.addTextChangedListener(validator);
        cardInput.setOnFocusChangeListener(focusListener);
        expirationInput.addTextChangedListener(validator);
        expirationInput.setOnFocusChangeListener(focusListener);
        cvcInput.addTextChangedListener(validator);
        cvcInput.setOnFocusChangeListener(focusListener);
        cvcInput.setOnEditorActionListener(submitForm);
        togglePaymentMethod.setPaintFlags(togglePaymentMethod.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        togglePaymentMethod.setOnClickListener(v -> {
            useStripe = !useStripe;
            displayStripeOrFreekassa();
        });

        referralCodeInput.setOnEditorActionListener(submitForm);

        if (isPlayVersion) {
            togglePaymentMethod.setVisibility(View.GONE);
        }
        displayStripeOrFreekassa();
    }

    private void displayStripeOrFreekassa() {
        int tosText = R.string.terms_of_service_text;
        int continueText = R.string.continue_to_payment;
        if (useStripe) {
            tosText = R.string.terms_of_service_text_complete_purchase;
            continueText = R.string.complete_purchase;
        }
        termsOfServiceText.setText(getResources().getText(tosText));
        continueBtn.setText(getResources().getText(continueText));
        MaterialUtil.clickify(termsOfServiceText, getString(R.string.terms_of_service), clickSpan);

        // hide the buttons and move the referral code
        if (useStripe) {
            stripeSection.setVisibility(View.VISIBLE);
            togglePaymentMethod.setVisibility(View.GONE);
            tvStepDescription.setText(R.string.enter_payment_details);
            referralCodeLayout.setTranslationY(0);
        } else {
            stripeSection.setVisibility((View.INVISIBLE));
            togglePaymentMethod.setText(getText(R.string.switch_to_credit_card));
            tvStepDescription.setText(R.string.enter_email_short);
            float referralCodeTranslateY = cardLayout.getBottom() - referralCodeLayout.getBottom();
            referralCodeLayout.setTranslationY(referralCodeTranslateY);
        }

        // immediately run validation to enable button if we can
        validate();
    }

    private void validate() {
        if (useStripe) {
            validateWithStripe();
        } else {
            validateWithoutStripe();
        }
    }

    private boolean validateCommon() {
        final String email = emailInput.getText().toString().trim();

        if (!Utils.isEmailValid(email)) {
            if (!emailInput.hasFocus() && email.length() > 0) {
                MaterialUtil.setError(emailLayout, emailInput, R.string.invalid_email);
            }
            return false;
        }

        emailLayout.setError(null);
        return true;
    }

    private void validateWithoutStripe() {
        continueBtn.setEnabled(validateCommon());
    }

    private void validateWithStripe() {
        final String card = cardInput.getText().toString().trim();
        final String cvc = cvcInput.getText().toString().trim();

        boolean hasError = !validateCommon();

        if (!cardInput.isCardNumberValid()) {
            hasError = true;
            if (!cardInput.hasFocus() && card.length() > 0) {
                MaterialUtil.setError(cardLayout, cardInput, R.string.invalid_card);
            }
        } else {
            cardLayout.setError(null);
        }

        if (!expirationInput.isDateValid()) {
            hasError = true;
            MaterialUtil.setError(expirationLayout, expirationInput, R.string.invalid_expiration);
        } else {
            expirationLayout.setError(null);
        }

        if (cvc.length() < 3) {
            hasError = true;
            MaterialUtil.setError(cvcLayout, cvcInput, R.string.invalid_cvc);
        } else {
            cvcLayout.setError(null);
        }

        continueBtn.setEnabled(!hasError);
    }

    @Click(R.id.continueBtn)
    public void continueClicked(View view) {
        final String email = emailInput.getText().toString().trim();
        final String referral = referralCodeInput.getText().toString().trim().toUpperCase();

        if (referral.equals("") || referral.equals(LanternApp.getSession().referral())) {
            if (!email.equals(LanternApp.getSession().email())) {
                checkEmailExistence(email);
            } else {
                submit(email);
            }
        } else {
            handleReferral(referral, email);
        }
    }

    private void handleReferral(final String referral, final String email) {
        dialog = ProgressDialog.show(this,
                getResources().getString(R.string.applying_referral_code),
                "",
                true, false);
        final FormBody formBody = new FormBody.Builder()
                .add("code", referral).build();
        final CheckoutActivity activity = this;
        lanternClient.post(LanternHttpClient.createProUrl("/referral-attach"), formBody,
                new LanternHttpClient.ProCallback() {
                    @Override
                    public void onFailure(final Throwable throwable, final ProError error) {
                        closeDialog();
                        Logger.error(TAG, "Error retrieving referral code: " + error);
                        if (error != null && error.getMessage() != null) {
                            ActivityExtKt.showErrorDialog(activity, error.getMessage());
                        }
                    }

                    @Override
                    public void onSuccess(final Response response, final JsonObject result) {
                        Logger.debug(TAG, "Successfully redeemed referral code" + referral);
                        LanternApp.getSession().setReferral(referral);
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                checkEmailExistence(email);
                            }
                        });
                    }
                });
    }

    private void checkEmailExistence(final String email) {
        closeDialog();
        dialog = ProgressDialog.show(this,
                getResources().getString(R.string.confirming_email),
                "",
                true, false);

        final Map<String, String> params = new HashMap<String, String>();
        final Resources res = getResources();
        params.put("email", email);
        lanternClient.get(LanternHttpClient.createProUrl("/email-exists", params),
                new LanternHttpClient.ProCallback() {
                    @Override
                    public void onFailure(final Throwable throwable, final ProError error) {
                        closeDialog();
                        confirmEmailError(error);
                    }

                    @Override
                    public void onSuccess(final Response response, final JsonObject result) {
                        Logger.debug(TAG, "Email successfully validated " + email);
                        closeDialog();
                        LanternApp.getSession().setEmail(email);
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                submit(email);
                            }
                        });
                    }
                });
    }

    private void submit(String email) {
        if (useStripe) {
            submitStripe();
        } else {
            continueToPayment(email);
        }
    }

    private void submitStripe() {
        try {
            ExpirationDate.Validated date = expirationInput.getValidatedDate();
            String cardNumber = cardInput.getText().toString().replaceAll("\\s", "");
            CardParams card = new CardParams(
                    cardNumber,
                    date.getMonth(),
                    date.getYear(),
                    cvcInput.getText().toString().trim());
            dialog = ProgressDialog.show(this,
                    getResources().getString(R.string.processing_payment),
                    "",
                    true, false);
            Logger.debug(STRIPE_TAG, "Stripe publishable key is '%s'", LanternApp.getSession().stripePubKey());
            final Stripe stripe = new Stripe(
                    this,
                    LanternApp.getSession().stripePubKey()
            );
            stripe.createCardToken(
                    card,
                    new ApiResultCallback<Token>() {
                        public void onSuccess(@NonNull Token token) {
                            LanternApp.getSession().setStripeToken(token.getId());
                            closeDialog();
                            PaymentHandler paymentHandler = new PaymentHandler(CheckoutActivity.this, "stripe");
                            paymentHandler.sendPurchaseRequest();
                        }

                        public void onError(@NonNull Exception error) {
                            closeDialog();
                            ActivityExtKt.showErrorDialog(CheckoutActivity.this, error.getLocalizedMessage());
                        }
                    }
            );
        } catch (Throwable t) {
            Logger.error(STRIPE_TAG, "Error submitting to stripe", t);
            closeDialog();
            ActivityExtKt.showErrorDialog(CheckoutActivity.this, getResources().getString(R.string.error_making_purchase));
        }
    }

    private void continueToPayment(final String email) {
        closeDialog();
        openPaymentProvider(email);
    }

    private void confirmEmailError(final ProError error) {
        if (error == null) {
            return;
        }
        final String errorId = error.getId();
        if (errorId != null && errorId.equals("existing-email")) {
            ActivityExtKt.showErrorDialog(this,
                    getResources().getString(R.string.email_in_use));
        } else if (error.getMessage() != null) {
            ActivityExtKt.showErrorDialog(this, error.getMessage());
        }
    }

    /**
     * Opens a payment provider
     *
     * @param email the email address is to use when configuring the payment
     *              gateway
     */
    private void openPaymentProvider(final String email) {
        // TODO <23-12-2022, soltzen> Make this selectable from the backend
        // if/when the UI can support multiple different providers.
        // The ideal path for this is:
        // - PlansActivity.java (which is the only activity that can call this
        //   activity) calls pro-server-neu's `/user-payment-gateway` endpoint
        //   - Which returns a payment provider based on the user's params
        // - We'll be allowed to force a provider client-side *only* for
        //   testing purposes
        // For now, the payment provider selection logic is a bit all over the
        // place (server and client-side) since payment provider selection is
        // quite voltatile in our company.
        //
        // By default, always use paymentwall unless something else is forced.
        //
        // String provider = LanternApp.getSession().getPaymentProvider();
        String provider = "paymentwall";

        // Debug providers take precedence
        //
        // Then, forcedPaymentProvider (which is usually controlled client-side
        // depending on the country)
        //
        // Finally, if we didn't force a provider, try to see if this is coming
        // from Google Play. If it is, it has it's own workflow which can short
        // circuit the rest of the function.
        if (!BuildConfig.PAYMENT_PROVIDER.equals("")) {
            // for debug builds, allow overriding default payment provider
            provider = BuildConfig.PAYMENT_PROVIDER;
            Logger.debug(TAG, "Overriding default payment provider to " + provider);
        } else if (forcedPaymentProvider != "") {
            provider = forcedPaymentProvider;
            Logger.debug(TAG, "Overriding default payment provider to " + provider);
        } else if (LanternApp.getSession().isPlayVersion()) {
            if (!LanternApp.getInAppBilling().startPurchase(this, LanternApp.getSession().getSelectedPlan().getId(), this)) {
                ActivityExtKt.showErrorDialog(this, getResources().getString(R.string.error_making_purchase));
            }
            return;
        }

        Logger.debug(TAG, "Attempting to use payment provider: " + provider);

        Class<? extends Activity> activityClass = null;
        switch (provider.toLowerCase()) {
//            case "adyen":
//                activityClass = AdyenActivity_.class;
//                break;
            case "freekassa":
                activityClass = FreeKassaActivity_.class;
                break;
            case "paymentwall":
                activityClass = PaymentWallActivity_.class;
                break;
            default:
                Logger.error(TAG, "Unknown payment provider " + provider.toLowerCase());
                return;
        }
        if (activityClass != null) {
            final Intent intent = new Intent(this, activityClass);
            intent.putExtra("userEmail", email);
            startActivity(intent);
        }
    }

    public void onPurchasesUpdated(BillingResult billingResult, List<Purchase> purchases) {
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            ActivityExtKt.showErrorDialog(this, getResources().getString(R.string.error_making_purchase));
            return;
        }

        List<String> tokens = new ArrayList<String>();
        for (Purchase purchase : purchases) {
            if (!purchase.isAcknowledged()) {
                Logger.debug(TAG, "Order Token: " + purchase.getPurchaseToken());
                tokens.add(purchase.getPurchaseToken());
            }
        }

        if (tokens.size() != 1) {
            Logger.error(TAG, "Unexpected number of purchased products, not proceeding with purchase: " + tokens.size());
            ActivityExtKt.showErrorDialog(this, getResources().getString(R.string.error_making_purchase));
            return;
        }

        PaymentHandler paymentHandler = new PaymentHandler(CheckoutActivity.this, "googleplay", tokens.get(0));
        paymentHandler.sendPurchaseRequest();
    }
}
