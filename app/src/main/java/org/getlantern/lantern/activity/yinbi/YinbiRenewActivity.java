package org.getlantern.lantern.activity.yinbi;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItemAdapter;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItems;
import com.ogaclejapan.smarttablayout.SmartTabLayout;

import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.PlansActivity;
import org.getlantern.lantern.model.DynamicViewPager;
import org.getlantern.lantern.model.ProPlan;

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
