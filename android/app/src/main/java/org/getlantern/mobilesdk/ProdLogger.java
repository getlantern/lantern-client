package org.getlantern.mobilesdk;

import android.content.Context;
import internalsdk.Internalsdk;
import android.util.Log;

public class ProdLogger extends Logger {
    protected ProdLogger() {
        super();
    }

    synchronized public static void enable(Context context) {
        Internalsdk.enableLogging(Lantern.configDirFor(context, ""));
        Logger.instance = new ProdLogger();
    }

    @Override
    protected void log(int level, String tag, String msg) {
        Internalsdk.debug(tag, msg);
    }

    @Override
    protected void logError(String tag, String msg, Throwable t) {
        Internalsdk.error(tag, msg);
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