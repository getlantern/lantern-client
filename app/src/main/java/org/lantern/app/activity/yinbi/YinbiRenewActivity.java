package org.lantern.app.activity.yinbi;

import android.content.res.Resources;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;

import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItemAdapter;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItems;
import com.ogaclejapan.smarttablayout.SmartTabLayout;

import org.lantern.app.LanternApp;
import org.lantern.app.R;
import org.lantern.app.activity.PlansActivity;
import org.lantern.app.model.DynamicViewPager;
import org.lantern.app.model.LanternHttpClient;
import org.lantern.app.model.ProPlan;
import org.lantern.app.model.SessionManager;

public class YinbiRenewActivity extends PlansActivity {

    private static final String TAG = YinbiPlansActivity.class.getName();

    private ImageView close;

    private SmartTabLayout viewPagerTab;

    private DynamicViewPager viewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initViews();
        setupCards();
    }

    private void initViews() {
        close = (ImageView)findViewById(R.id.close);
        close.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                finish();
            }
        });

        viewPagerTab = (SmartTabLayout)findViewById(R.id.viewPagerTab);
        viewPager = (DynamicViewPager)findViewById(R.id.viewPager);
    }

    private void setupCards() {
        FragmentPagerItems pages = new FragmentPagerItems(this);
        pages.add(createCard(R.layout.plans_card_renew, R.array.yinbi_renew_features, false));
        pages.add(createCard(R.layout.plans_card_yinbi, null, false));
        FragmentPagerItemAdapter adapter = new FragmentPagerItemAdapter(
                getSupportFragmentManager(), pages);
        viewPager.setAdapter(adapter);
        viewPagerTab.setViewPager(viewPager);
    }

    @Override
    protected void updatePrice(ProPlan plan) {
        final String currencyCode = plan.getCurrencyObj()
            .getCurrencyCode().toUpperCase();
        final String cost = String.format(
                getResources().getString(R.string.yinbi_cost),
                plan.getSymbol(),
                plan.getFormattedPrice(),
                currencyCode);

        if (plan.numYears() == 1) {
            oneYearCost.setText(cost);
            oneYearBtn.setTag(plan.getId());
        } else {
            twoYearCost.setText(cost);
            twoYearBtn.setTag(plan.getId());
        }
    }

    @Override
    public int getLayoutId() {
        return R.layout.yinbi_renew_plans;
    }
}
