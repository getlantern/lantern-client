package org.getlantern.lantern.fragment;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.graphics.PorterDuff;
import android.os.Bundle;
import androidx.appcompat.widget.AppCompatDrawableManager;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import org.getlantern.lantern.MainActivity;
import org.getlantern.lantern.R;
import org.getlantern.mobilesdk.Logger;

import androidx.fragment.app.Fragment;

public class TitleBar extends Fragment {

    private static final String TAG = "TitleBar";

    private ImageView avatar;
    private String title;
    private Boolean disableBackButton;
    private TextView titleHeader;
    private ImageView imageHeader;
    private Drawable titleImage;
    private Drawable background;
    private Drawable backArrow;
    private Integer textColor = 0;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.titlebar, container, false);
        avatar = (ImageView)view.findViewById(R.id.avatar);

        if (disableBackButton == null || !disableBackButton.booleanValue()) {
            avatar.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Logger.debug(TAG, "Back button pressed");
                    Activity activity = getActivity();

                    final ComponentName name = activity.getComponentName();
                    if (name != null && name.toString().contains("PaymentActivity")) {
                        activity.startActivity(new Intent(activity,
                                    MainActivity.class));
                    }
                    activity.finish();
                }
            });
        }

        titleHeader = (TextView)view.findViewById(R.id.header);
        if (title != null) {
            titleHeader.setText(title);
            if (textColor != 0) {
                titleHeader.setTextColor(textColor);
            }
        }

        if (background != null) {
            view.setBackground(background);
        }

        if (titleImage != null) {
            titleHeader.setVisibility(View.GONE);
            imageHeader = (ImageView)view.findViewById(R.id.imageHeader);
            imageHeader.setImageDrawable(titleImage);
            imageHeader.setVisibility(View.VISIBLE);
        }

        backArrow = AppCompatDrawableManager.get().getDrawable(getActivity(), R.drawable.abc_ic_ab_back_material);
        if (backArrow != null) {
            backArrow.setColorFilter(getResources().getColor(R.color.black), PorterDuff.Mode.SRC_ATOP);
            avatar.setImageDrawable(backArrow);
        }

        return view;
    }

    @Override
    public void onInflate(Activity activity, AttributeSet attrs, Bundle savedInstanceState) {

        super.onInflate(activity, attrs, savedInstanceState);

        final TypedArray a = activity.obtainStyledAttributes(attrs, R.styleable.TitleBar);

        title = a.getString(R.styleable.TitleBar_titleText);
        disableBackButton = a.getBoolean(R.styleable.TitleBar_disableBackButton, false);
        background = a.getDrawable(R.styleable.TitleBar_titleBackgroundColor);
        titleImage = a.getDrawable(R.styleable.TitleBar_titleImage);
        textColor  = a.getColor(R.styleable.TitleBar_textColor, 0);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        avatar = null;
        background = null;
        backArrow = null;
        titleHeader = null;
        titleImage = null;
        background = null;
    }

    public void setTitle(String title) {
        if (titleHeader != null) {
            titleHeader.setText(title);
        } else {
            this.title = title;
        }
    }
}
