package org.lantern.app.fragment;

import android.graphics.Color;
import android.text.TextPaint;
import android.text.style.ClickableSpan;
import android.view.View;


public class ClickSpan extends ClickableSpan {

    private OnClickListener listener;
    private int color;

    public ClickSpan(OnClickListener listener) {
        this.listener = listener;
    }

    public ClickSpan(OnClickListener listener, final int color) {
        this.listener = listener;
        this.color = color;
    }

    @Override
    public void onClick(View widget) {
        if (listener != null) {
            listener.onClick();
        }
    }

    public interface OnClickListener {
        void onClick();
    }

    public void updateDrawState(TextPaint ds) {
        super.updateDrawState(ds);
        if (color != -1) {
            ds.setColor(color);
        }
        ds.setUnderlineText(false); // set to false to remove underline
    }
}

