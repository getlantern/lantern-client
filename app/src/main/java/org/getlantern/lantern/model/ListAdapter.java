package org.getlantern.lantern.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

import org.getlantern.lantern.R;

public class ListAdapter extends BaseAdapter {

    private Context context;
    private ArrayList<NavItem> navItems;

    public ListAdapter(Context context, ArrayList<NavItem> navItems) {
        this.context = context;
        this.navItems = navItems;
    }

    @Override
    public int getCount() {
        return navItems.size();
    }

    @Override
    public Object getItem(int position) {
        return navItems.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;

        if (convertView == null) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            view = inflater.inflate(R.layout.drawer_item, null);
        }
        else {
            view = convertView;
        }

        TextView titleView = (TextView) view.findViewById(R.id.title);
        ImageView iconView = (ImageView) view.findViewById(R.id.icon);

        titleView.setText( navItems.get(position).getTitle() );
        iconView.setImageResource(navItems.get(position).getIcon());

        return view;
    }
}
