package org.getlantern.lantern.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ImageView;
import android.widget.TextView;

import org.getlantern.lantern.R;

public class FeatureUi extends LinearLayout {

    private ImageView checkmark;
    public TextView text;

    public FeatureUi(final Context context, final int layout) {
        super(context);

        LayoutInflater layoutInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = layoutInflater.inflate(layout, this);
        text = (TextView)view.findViewById(R.id.feature_text);
        checkmark = (ImageView)view.findViewById(R.id.checkmark);
    }
}
