package org.getlantern.lantern.test;

import android.app.Activity;
import android.content.Context;
import android.view.View;

import androidx.test.InstrumentationRegistry;
import androidx.test.espresso.Espresso;
import androidx.test.espresso.FailureHandler;
import androidx.test.espresso.base.DefaultFailureHandler;
import androidx.test.rule.ActivityTestRule;
import androidx.test.uiautomator.UiDevice;

import org.hamcrest.Matcher;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;


public class MyActivityTestRule<T extends Activity> extends ActivityTestRule<T> {

    UiDevice mDevice;

    public MyActivityTestRule(java.lang.Class<T> cls, boolean initialTouchMode, boolean launchActivity) {
        super(cls, initialTouchMode, launchActivity);
        mDevice = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    }

    public MyActivityTestRule(java.lang.Class<T> cls) {
        this(cls, false, true);
    }

    @Override
    public Statement apply(Statement base, Description description) {
        final String testClassName = description.getClassName();
        final String testMethodName = description.getMethodName();
        final Context context = InstrumentationRegistry.getTargetContext();
        Espresso.setFailureHandler(new FailureHandler() {
            @Override
            public void handle(Throwable throwable, Matcher<View> matcher) {
                seq++;
                new DefaultFailureHandler(context).handle(throwable, matcher);
            }
        });
        return super.apply(base, description);
    }

    private static int seq;
}
