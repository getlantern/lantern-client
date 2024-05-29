package org.getlantern.lantern.test;

import android.util.Log;

import androidx.test.InstrumentationRegistry;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject;
import androidx.test.uiautomator.UiObjectNotFoundException;
import androidx.test.uiautomator.UiSelector;
import androidx.test.uiautomator.UiWatcher;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class UiWatchers {
    private static final String LOG_TAG = UiWatchers.class.getSimpleName();
    private final List<String> mErrors = new ArrayList<String>();

    public void registerAnrAndCrashWatchers() {
        UiDevice device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        device.registerWatcher("ANR", new UiWatcher() {
            @Override
            public boolean checkForCondition() {
                Log.d(LOG_TAG, "Checking if there's an AppNotRespondingDialog");
                UiObject window = new UiObject(new UiSelector()
                        .className("com.android.server.am.AppNotRespondingDialog"));
                String errorText = null;
                if (window.exists()) {
                    Log.d(LOG_TAG, "There's an AppNotRespondingDialog");
                    try {
                        errorText = window.getText();
                    } catch (UiObjectNotFoundException e) {
                        Log.e(LOG_TAG, "dialog gone?", e);
                    }
                    onAnrDetected(errorText);
                    postHandler();
                    return true; // triggered
                }
                return false; // no trigger
            }
        });

        device.registerWatcher("ANR2", new UiWatcher() {
            @Override
            public boolean checkForCondition() {
                Log.d(LOG_TAG, "Checking if there's an 'app isn't responding' dialog");
                UiObject window = new UiObject(new UiSelector().packageName("android")
                        .textContains("isn't responding."));
                if (window.exists()) {
                    Log.d(LOG_TAG, "There's an 'app isn't responding' dialog");
                    String errorText = null;
                    try {
                        errorText = window.getText();
                    } catch (UiObjectNotFoundException e) {
                        Log.e(LOG_TAG, "dialog gone?", e);
                    }
                    onAnrDetected(errorText);
                    postHandler();
                    return true; // triggered
                }
                return false; // no trigger
            }
        });

        device.registerWatcher("CRASH", new UiWatcher() {
            @Override
            public boolean checkForCondition() {
                Log.d(LOG_TAG, "Checking if there's an AppErrorDialog");
                UiObject window = new UiObject(new UiSelector()
                        .className("com.android.server.am.AppErrorDialog"));
                if (window.exists()) {
                    String errorText = null;
                    Log.d(LOG_TAG, "There's an AppErrorDialog");
                    try {
                        errorText = window.getText();
                    } catch (UiObjectNotFoundException e) {
                        Log.e(LOG_TAG, "dialog gone?", e);
                    }
                    onCrashDetected(errorText);
                    postHandler();
                    return true; // triggered
                }
                return false; // no trigger
            }
        });

        device.registerWatcher("CRASH2", new UiWatcher() {
            @Override
            public boolean checkForCondition() {
                Log.d(LOG_TAG, "Checking if there's an 'app has stopped' dialog");
                UiObject window = new UiObject(new UiSelector().packageName("android")
                        .textContains("has stopped"));
                if (window.exists()) {
                    Log.d(LOG_TAG, "There's an 'app has stopped' dialog");
                    String errorText = null;
                    try {
                        errorText = window.getText();
                    } catch (UiObjectNotFoundException e) {
                        Log.e(LOG_TAG, "dialog gone?", e);
                    }
                    onCrashDetected(errorText);
                    postHandler();
                    return true; // triggered
                }
                return false; // no trigger
            }
        });

        Log.i(LOG_TAG, "Registered GUI Exception watchers");
    }

    public void registerAcceptSSLCertWatcher() {
        UiDevice device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        device.registerWatcher("SSLCERTERROR", new UiWatcher() {
            @Override
            public boolean checkForCondition() {
                UiObject continueButton = new UiObject(new UiSelector()
                        .className("android.widget.Button").packageName("com.android.browser").text("Continue"));
                if (continueButton.exists()) {
                    try {
                        continueButton.click();
                        return true; // triggered
                    } catch (UiObjectNotFoundException e) {
                        Log.e(LOG_TAG, "Exception", e);
                    }
                }
                return false; // no trigger
            }
        });

        Log.i(LOG_TAG, "Registered SSL Certificate Error Watchers");
    }

    public void onAnrDetected(String errorText) {
        mErrors.add(errorText);
    }

    public void onCrashDetected(String errorText) {
        mErrors.add(errorText);
    }

    public void reset() {
        mErrors.clear();
    }

    public List<String> getErrors() {
        return Collections.unmodifiableList(mErrors);
    }

    public void postHandler() {
        String formatedOutput = String.format("UI Exception Message: %-20s\n",
                UiDevice.getInstance().getCurrentPackageName());
        Log.e(LOG_TAG, formatedOutput);

        UiObject buttonOK = new UiObject(new UiSelector().text("OK").enabled(true));
        // sometimes it takes a while for the OK button to become enabled
        buttonOK.waitForExists(5000);
        try {
            buttonOK.click();
        } catch (UiObjectNotFoundException e) {
            Log.e(LOG_TAG, "Exception", e);
        }
    }
}
