package org.lantern.app.test;

import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject;
import androidx.test.uiautomator.UiSelector;
import androidx.test.uiautomator.UiObjectNotFoundException;
import android.util.Log;

public class TestUtils {
  private static final String TAG = "TestUtils";

  public static void clickButtonIfPresent(UiDevice device, String text)  {
    UiObject btn = device.findObject(new UiSelector().text(text));
    if (btn.exists()) {
      try {
        btn.click();
      } catch (UiObjectNotFoundException e) {
        Log.e(TAG, "There is no button to interact with", e);
      }
    }
  }
}
