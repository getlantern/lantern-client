package org.lantern.app.test;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import android.content.Intent;
import android.os.SystemClock;
import androidx.test.InstrumentationRegistry;
import androidx.test.filters.SdkSuppress;
import androidx.test.rule.ActivityTestRule;
import androidx.test.runner.AndroidJUnit4;
import androidx.test.uiautomator.*;
import android.util.Log;
import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.joda.time.DateTimeZone;
import org.joda.time.LocalDateTime;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.swipeLeft;
import static androidx.test.espresso.action.ViewActions.swipeRight;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import androidx.test.espresso.NoMatchingViewException;

import org.lantern.app.R;
import org.lantern.app.LanternApp;
import org.lantern.app.activity.LanternFreeActivity;
import org.lantern.app.model.SessionManager;

@RunWith(AndroidJUnit4.class)
public class RenewalsTest {

    private static final String TAG = RenewalsTest.class.getName();
    private UiDevice device;

    private static final SessionManager session = LanternApp.getSession();
    private String minDatafile = "{\"groups\": [], \"projectId\": \"8504447126\", \"variables\": [{\"defaultValue\": \"true\", \"type\": \"boolean\", \"id\": \"8516291943\", \"key\": \"test_variable\"}], \"version\": \"3\", \"experiments\": [{\"status\": \"Running\", \"key\": \"android_experiment_key\", \"layerId\": \"8499056327\", \"trafficAllocation\": [{\"entityId\": \"8509854340\", \"endOfRange\": 5000}, {\"entityId\": \"8505434669\", \"endOfRange\": 10000}], \"audienceIds\": [], \"variations\": [{\"variables\": [], \"id\": \"8509854340\", \"key\": \"var_1\"}, {\"variables\": [], \"id\": \"8505434669\", \"key\": \"var_2\"}], \"forcedVariations\": {}, \"id\": \"8509139139\"}], \"audiences\": [], \"anonymizeIP\": true, \"attributes\": [], \"revision\": \"7\", \"events\": [{\"experimentIds\": [\"8509139139\"], \"id\": \"8505434668\", \"key\": \"test_event\"}], \"accountId\": \"8362480420\"}";

    @Rule
    public ActivityTestRule<LanternFreeActivity> mActivityRule = new MyActivityTestRule(LanternFreeActivity.class);

    @Before
    public void setUp() throws Exception {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    }

    private void checkTextDisplayed(final int id, final String text) {
        try {
            onView(withId(id)).check(matches(isDisplayed()));
            UiObject o = device.findObject(new UiSelector().text(text));
            Assert.assertTrue(o.exists());
        } catch (NoMatchingViewException e) {
            Log.e(TAG, "No matching view found", e);
        }
    }

    private void testRenewal(final LocalDateTime expires,
            final String text) {
        final boolean isProUser = true;
        final boolean expired = false;
        final DateTime utc = expires.toDateTime(DateTimeZone.UTC);
        final long expiration = utc.getMillis() / DateTimeConstants.MILLIS_PER_SECOND;
        mActivityRule.launchActivity(new Intent());
        SystemClock.sleep(5000);
        checkTextDisplayed(R.id.renewalHeader, text);
    }

    @Test
    public void testProExpiresTomorrowRenewal() {
        testRenewal(LocalDateTime.now().plusDays(1),
                "tomorrow");
    }

    @Test
    public void testProExpiresToday() {
        testRenewal(LocalDateTime.now(), "today");
    }

    @Test
    public void testProExpired() {
        testRenewal(LocalDateTime.now().minusDays(1),
                "Limited time offer");
    }
}
