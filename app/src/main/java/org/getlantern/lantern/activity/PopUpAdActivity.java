package org.getlantern.lantern.activity;

import android.content.Intent;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.lantern.model.PopUpAd;
import org.getlantern.lantern.model.SessionManager;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.R;

import com.google.gson.Gson;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.androidannotations.annotations.ViewById;

import com.bumptech.glide.Glide;

@EActivity(R.layout.popupad_layout)
public class PopUpAdActivity extends FragmentActivity {
    private static final String TAG = PopUpAdActivity.class.getName();
    private static final SessionManager session = LanternApp.getSession();

    @Extra
    String popUpAdStr;

    @ViewById
    TextView details;

    @ViewById
    TextView moreInfo;

    @ViewById
    TextView findOutMore;

    @ViewById
    LinearLayout helpSection;

    @ViewById
    TextView desc;

    @ViewById
    ImageView openDetailsIcon;

    @ViewById
    TextView currencyGiveaway;

    @ViewById
    TextView specialOffer;

    @ViewById
    ImageView leftLogo, rightLogo;

    @ViewById
    Button renewProNow;

    private ClickSpan.OnClickListener clickSpan;

    private void openWebView(final String url) {
        final Intent intent = new Intent(PopUpAdActivity.this,
                WebViewActivity_.class);
        intent.putExtra("url", url);
        startActivity(intent);
    }

    /**
     * updateImage replaces the ImageView image with a
     * given image resource or an image from a URL
     */
    private void updateImage(final ImageView imageView,
            final String imageResource, final String imageUrl) {
        if (imageResource == null && imageUrl == null) {
            Logger.debug(TAG, "No image resource or url found; not replacing image");
            return;
        }
        if (!TextUtils.isEmpty(imageResource)) {
            final int resId = Utils.getResId(imageResource, R.drawable.class);
            if (resId != -1) {
                Logger.debug(TAG, "Replacing image with resource ID " + resId);
                imageView.setImageResource(resId);
            }
        } else if (!TextUtils.isEmpty(imageUrl)) {
            Logger.debug(TAG, "Loading image from url " + imageUrl +
                    " into imageView");
            Glide.with(this).load(imageUrl).into(imageView);
        }
    }

    /**
     * updateLayout updates the current layout to match
     * the corresponding popup ad found in loconf
     */
    private void updateLayout(final PopUpAd popUpAd) {
        if (session.isProUser()) {
            renewProNow.setText(popUpAd.getRenewalButtonText());
            desc.setText(popUpAd.getContentMainScreenPro());
            details.setText(popUpAd.getContentMainScreenProDetails());
            moreInfo.setText(popUpAd.getContentSecondaryScreenPro());
            findOutMore.setText(popUpAd.getContentButtonPro());
        } else {
            renewProNow.setText(popUpAd.getBuyLanternProText());
            desc.setText(popUpAd.getContentMainScreenFree());
            details.setText(popUpAd.getContentMainScreenFreeDetails());
            moreInfo.setText(popUpAd.getContentSecondaryScreenFree());
            findOutMore.setText(popUpAd.getContentButtonFree());
        }

        updateImage(leftLogo, popUpAd.getLeftImageResource(),
                popUpAd.getLeftImageUrl());
        updateImage(rightLogo, popUpAd.getRightImageResource(),
                popUpAd.getRightImageUrl());

        specialOffer.setText(popUpAd.getContentHeader());
        currencyGiveaway.setText(popUpAd.getContentSubHeader());

        final String renewalButtonUrl = popUpAd.getRenewalButtonUrl();
        if (renewalButtonUrl != null && !renewalButtonUrl.equals("")) {
            renewProNow.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    openWebView(renewalButtonUrl);
                }
            });
        }

        clickSpan = new ClickSpan.OnClickListener() {
                @Override
                public void onClick() {
                    openWebView(popUpAd.getUrl());
                }
            };
    }

    @AfterViews
    void afterViews() {
        try {
            final PopUpAd popUpAd = new Gson().fromJson(popUpAdStr, PopUpAd.class);
            if (popUpAd == null) {
                Logger.error(TAG, "No popup ad to show user");
                return;
            }
            updateLayout(popUpAd);
            final String website = popUpAd.getContentWebsite();
            if (clickSpan != null && website != null) {
                final int color = ContextCompat.getColor(this, R.color.pink);
                Utils.clickify(findOutMore, website, color, clickSpan);
            }
        } catch (Exception e) {
            Logger.error(TAG, "Unable to parse dynamic loconf content", e);
        }
    }

    @Click(R.id.close)
    void close(View view) {
        finish();
    }

    @Click(R.id.openDetailsIcon)
    void openDetails(View view) {
        helpSection.setVisibility(View.GONE);
        moreInfo.setVisibility(View.VISIBLE);
        findOutMore.setVisibility(View.VISIBLE);
    }

    @Click(R.id.renewProNow)
    void renewProNow(View view) {
        startActivity(new Intent(this, session.plansActivity()));
    }
}
