package org.lantern.app.activity.yinbi;

import android.content.res.Resources;
import android.os.Bundle;
import androidx.viewpager.widget.ViewPager;
import android.view.LayoutInflater;

import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItemAdapter;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItems;
import com.ogaclejapan.smarttablayout.SmartTabLayout;

import org.lantern.app.LanternApp;
import org.lantern.app.R;
import org.lantern.app.activity.PlansActivity;
import org.lantern.app.model.DynamicViewPager;
import org.lantern.app.model.ProPlan;
import org.lantern.app.model.SessionManager;

import java.util.concurrent.ConcurrentHashMap;

public class YinbiPlansActivity extends PlansActivity {

    private static final String TAG = YinbiPlansActivity.class.getName();
    private static final SessionManager session = LanternApp.getSession();

    private ConcurrentHashMap<String, ProPlan> plans = new ConcurrentHashMap<String, ProPlan>();

    private SmartTabLayout viewPagerTab;

    private DynamicViewPager viewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initViews();
        setupCards();
    }

    private void initViews() {
        viewPagerTab = (SmartTabLayout)findViewById(R.id.viewPagerTab);
        viewPager = (DynamicViewPager)findViewById(R.id.viewPager);

    }

    private void setupCards() {
        final LayoutInflater inflater = LayoutInflater.from(this);
        final Resources res = getResources();
        FragmentPagerItems pages = new FragmentPagerItems(this);
        pages.add(createCard(R.layout.plans_card, R.array.pro_features_new, true));
        pages.add(createCard(R.layout.plans_card_yinbi, null, false));
        FragmentPagerItemAdapter adapter = new FragmentPagerItemAdapter(
                getSupportFragmentManager(), pages);
        viewPager.setAdapter(adapter);
        viewPagerTab.setViewPager(viewPager);
        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                viewPager.reMeasureCurrentPage(viewPager.getCurrentItem());
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
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
        return R.layout.yinbi_pro_plans;
    }
}
