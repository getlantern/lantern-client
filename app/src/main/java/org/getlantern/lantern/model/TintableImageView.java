package org.getlantern.lantern.model;

import android.content.Context;
import android.content.res.ColorStateList;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.ImageView;

import org.getlantern.lantern.R;

/**
 * https://gist.github.com/tylerchesley/5d15d859be4f3ce31213
 */
public class TintableImageView extends ImageView {

  private ColorStateList tintColor;

  public TintableImageView(Context context) {
    super(context);
  }

  public TintableImageView(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context, attrs, 0);
  }

  public TintableImageView(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
    init(context, attrs, defStyle);
  }

  private void init(Context context, AttributeSet attrs, int defStyle) {
    TypedArray a = context.obtainStyledAttributes(
        attrs, R.styleable.TintableImageView, defStyle, 0);
    tintColor = a.getColorStateList(
        R.styleable.TintableImageView_tintColor);
    a.recycle();
  }

  @Override
  protected void drawableStateChanged() {
    super.drawableStateChanged();
    if (tintColor != null && tintColor.isStateful()) {
      updateTintColor();
    }
  }

  public void setColorFilter(ColorStateList tint) {
    this.tintColor = tint;
    super.setColorFilter(tintColor.getColorForState(getDrawableState(), 0));
  }

  private void updateTintColor() {
    int color = tintColor.getColorForState(getDrawableState(), 0);
    setColorFilter(color);
  }

}
