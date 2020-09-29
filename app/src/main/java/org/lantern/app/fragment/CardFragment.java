package org.lantern.app.fragment;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.lantern.app.R;

public class CardFragment extends Fragment {

    private Integer featuresId;
    private boolean colorLastLine;

    private class FeatureUi extends LinearLayout {
        public TextView text;
        public FeatureUi(final LayoutInflater inflater,
                final Context context, final int layout) {
            super(context);
            View view = inflater.inflate(layout, this);
            text = (TextView)view.findViewById(R.id.featureText);
        }
    }


    private void addFeatures(LayoutInflater inflater, Context context,
            View view) {
        final LinearLayout layout = (LinearLayout)view.findViewById(R.id.featuresSection);
        if (layout == null || featuresId == null) {
            return;
        }
        final String[] featuresList = getResources().getStringArray(featuresId);
        for (int i = 0; i < featuresList.length; i++) {
            final String proFeature = featuresList[i];
            final FeatureUi feature;
            if (i == featuresList.length - 1) {
                feature = new FeatureUi(inflater, context,
                        R.layout.pro_feature_yinbi_purchase);
                final TextView freeYinbi = feature.text;
                if (colorLastLine) {
                    freeYinbi.setTextColor(Color.parseColor("#ff4081"));
                    freeYinbi.setTypeface(null, Typeface.ITALIC);
                }
                freeYinbi.setText(proFeature);
            } else {
                feature = new FeatureUi(inflater, context,
                        R.layout.pro_feature_new);
                feature.text.setText(proFeature);
            }
            layout.addView(feature);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
            @Nullable Bundle savedInstanceState) {

            final Bundle bundle = getArguments();
            if (bundle == null) {
                return null;
            }
            final int layoutId = bundle.getInt("layoutId");
            featuresId = bundle.getInt("featuresId");
            colorLastLine = bundle.getBoolean("colorLastItem");
            final View view = (View)inflater.inflate(layoutId, container, false);
            addFeatures(inflater, getActivity(), view);
            return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle bundle) {
        super.onViewCreated(view, bundle);
    }
}

