package org.lantern.app.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.TextView;

import org.lantern.app.R;

public class TextInputLayout extends com.google.android.material.textfield.TextInputLayout {
    private static final String TAG = "TextInputLayout";

    public TextInputLayout(Context context) {
        super(context);
    }

    public TextInputLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public TextInputLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        if (isErrorEnabled()) {
            // This is a workaround to a weird layout issue where sometimes the error text is misaligned
            TextView errorView = getErrorView();
            errorView.setY(0);
        }
    }

    private TextView getErrorView() {
        return (TextView) findViewById(R.id.textinput_error);
    }

}