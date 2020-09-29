package org.lantern.app.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.lantern.app.R;


public class DeviceView extends LinearLayout {
    public TextView unauthorize;
    public TextView name;

    private void inflateLayout(Context context) {
        LayoutInflater layoutInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = layoutInflater.inflate(R.layout.device_item, this);
        this.unauthorize = (TextView)view.findViewById(R.id.unauthorize);
        this.name = (TextView)view.findViewById(R.id.deviceName);
    }

    public DeviceView(Context context) {
        super(context);
        inflateLayout(context);
    }
}
