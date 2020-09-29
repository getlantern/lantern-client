package org.lantern.app.model;

import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.material.textfield.TextInputLayout;

import org.lantern.app.R;
import org.lantern.app.fragment.ClickSpan;

/**
 * MaterialUtil provides UI utils for the new material design UI conventions.
 */
public class MaterialUtil {
    public static void clickify(TextView view, final String clickableText, final ClickSpan.OnClickListener listener) {
        Utils.clickify(view, clickableText, view.getContext().getResources().getColor(R.color.material_link), listener);
    }

    public static void setError(TextInputLayout layout, EditText input, int error) {
        if (!input.hasFocus() && input.getText().toString().trim().length() > 0) {
            layout.setError(layout.getResources().getString(error));
            if (true) {
                return;
            }
            View child = layout.findViewById(R.id.textinput_error);
            FrameLayout parent = (FrameLayout) child.getParent();
            // Pin height
            int height = (int) child.getMeasuredHeight();
            ((LinearLayout.LayoutParams) parent.getLayoutParams()).height = height;
            ((FrameLayout.LayoutParams) child.getLayoutParams()).height = height;

            View.OnLayoutChangeListener listener = new View.OnLayoutChangeListener() {
                @Override
                public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                    int[] childLocation = new int[2];
                    int[] parentLocation = new int[2];
                    child.getLocationOnScreen(childLocation);
                    parent.getLocationOnScreen(parentLocation);
                    FrameLayout.LayoutParams layoutParams = ((FrameLayout.LayoutParams) child.getLayoutParams());
                    float margin = parentLocation[1] - childLocation[1] + layoutParams.topMargin;
                    layoutParams.topMargin = (int) margin;
                    parent.removeOnLayoutChangeListener(this);
                    parent.invalidate();
                }
            };

            child.addOnLayoutChangeListener(listener);
            child.requestLayout();
        }
    }
}
