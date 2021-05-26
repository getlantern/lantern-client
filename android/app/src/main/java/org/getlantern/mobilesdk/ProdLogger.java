package org.getlantern.mobilesdk;

import android.content.Context;
import android.Android;
import android.util.Log;
import com.google.firebase.crashlytics.FirebaseCrashlytics;

public class ProdLogger extends Logger {
    private FirebaseCrashlytics crashlytics = FirebaseCrashlytics.getInstance();

    protected ProdLogger() {
        super();
    }

    synchronized public static void enable(Context context) {
        android.Android.enableLogging(Lantern.configDirFor(context, ""));
        Logger.instance = new ProdLogger();
    }

    @Override
    protected void log(int level, String tag, String msg) {
        android.Android.debug(tag, msg);
        logToCrashlytics(level, tag, msg);
    }

    @Override
    protected void logError(String tag, String msg, Throwable t) {
        android.Android.error(tag, msg);
        logToCrashlytics(Log.ERROR, tag, msg);
        if (t != null) {
            FirebaseCrashlytics.getInstance().recordException(t);
        }
    }

    private void logToCrashlytics(int level, String tag, String msg) {
        crashlytics.log(String.format("%s %s: %s", levelToString(level), tag, msg));
    }

    private static String levelToString(int level) {
        switch (level) {
            case Log.ASSERT:
                return "A";
            case Log.DEBUG:
                return "D";
            case Log.ERROR:
                return "E";
            case Log.INFO:
                return "I";
            case Log.VERBOSE:
                return "V";
            case Log.WARN:
                return "W";
        }

        return "";
    }
}