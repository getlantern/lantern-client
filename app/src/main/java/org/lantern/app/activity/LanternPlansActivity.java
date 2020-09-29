package org.lantern.app.activity;

import android.os.Bundle;
import android.widget.LinearLayout;

import org.lantern.app.R;
import org.lantern.app.model.FeatureUi;
import org.lantern.app.model.ProPlan;

public class LanternPlansActivity extends PlansActivity {

    private LinearLayout leftFeatures, rightFeatures;

    private String[] proFeaturesList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initViews();
        addProFeaturesUi();
    }

    private void initViews() {
        proFeaturesList = getResources().getStringArray(R.array.pro_features);
        leftFeatures = (LinearLayout)findViewById(R.id.leftFeatures);
        rightFeatures = (LinearLayout)findViewById(R.id.rightFeatures);
    }

    private void addProFeaturesUi() {
        int i = 0;
        for (String proFeature : proFeaturesList) {
            final FeatureUi feature = new FeatureUi(this, R.layout.pro_feature);
            feature.text.setText(proFeature);

            if ((i % 2) == 0) {
                leftFeatures.addView(feature);
            }
            else {
                rightFeatures.addView(feature);
            }

            i++;
        }
    }

    @Override
    public int getLayoutId() {
        return R.layout.pro_plans;
    }

    @Override
    protected void updatePrice(ProPlan plan) {
        if (plan.numYears() == 1) {
            oneYearCost.setText(plan.getCostWithoutTaxStr());
            oneYearBtn.setTag(plan.getId());
        } else {
            twoYearCost.setText(plan.getCostWithoutTaxStr());
            twoYearBtn.setTag(plan.getId());
        }
    }
}
