package org.getlantern.lantern.test;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;

import android.content.Intent;
import android.os.SystemClock;

import androidx.test.InstrumentationRegistry;
import androidx.test.filters.LargeTest;
import androidx.test.filters.SdkSuppress;
import androidx.test.rule.ActivityTestRule;
import androidx.test.runner.AndroidJUnit4;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject;
import androidx.test.uiautomator.UiSelector;

import org.getlantern.lantern.MainActivity;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.UpdateActivity_;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
@SdkSuppress(minSdkVersion = 18)
@LargeTest
public class UpdateTest {
    @Rule
    public ActivityTestRule<MainActivity> mMainActivityRule = new MyActivityTestRule(MainActivity.class);
    @Rule
    public ActivityTestRule<UpdateActivity_> mUpdateActivityRule =
            new MyActivityTestRule(UpdateActivity_.class,
                    false /* initialTouchMode */,
                    false /* launchActivity */);

    UiDevice mDevice;
    UiWatchers mWatchers = new UiWatchers();
    String updateURL = "https://github.com/getlantern/lantern/releases/download/3.6.1/update_android_arm.bz2";

    @Before
    public void setUp() throws Exception {
        mDevice = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        TestUtils.clickButtonIfPresent(mDevice, "OK");
        mWatchers.registerAnrAndCrashWatchers();
    }

    @Test
    public void testUpdate() {
        Intent intent = new Intent();
        intent.putExtra("updateUrl", updateURL);
        mUpdateActivityRule.launchActivity(intent);
        SystemClock.sleep(1000); // leave some time for flashlight to run
        onView(withId(R.id.installUpdate)).perform(click());
        waitForDownloadingAPK();
        SystemClock.sleep(1000);
        TestUtils.clickButtonIfPresent(mDevice, "OK");
        TestUtils.clickButtonIfPresent(mDevice, "Install");
        SystemClock.sleep(5000);
    }

    private void waitForDownloadingAPK() {
        String text = mUpdateActivityRule.getActivity().
                getResources().getString(R.string.updating_lantern);
        UiObject dialog;
        do {
            SystemClock.sleep(1000);
            dialog = mDevice.findObject(new UiSelector().text(text));
        } while (dialog.exists());
    }
}
