package org.getlantern.lantern.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.getlantern.lantern.R;


public class DeviceView extends LinearLayout {
    public Button unauthorize;
    public TextView name;

    private void inflateLayout(Context context) {
        LayoutInflater layoutInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = layoutInflater.inflate(R.layout.device_item, this);
        this.unauthorize = (Button)view.findViewById(R.id.unauthorize);
        this.name = (TextView)view.findViewById(R.id.deviceName);
    }

    public DeviceView(Context context) {
        super(context);
        inflateLayout(context);
    }
}
