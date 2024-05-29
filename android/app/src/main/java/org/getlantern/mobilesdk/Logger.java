package org.getlantern.mobilesdk;

import android.util.Log;

public class Logger {

    static volatile Logger instance = new Logger();

    protected Logger() {
    }

    public static void v(String tag, String msg, Object... msgParams) {
        instance.log(Log.VERBOSE, tag, msgFor(msg, msgParams));
    }

    public static void verbose(String tag, String msg, Object... msgParams) {
        v(tag, msg, msgParams);
    }

    public static void d(final String tag, String msg, Object... msgParams) {
        instance.log(Log.DEBUG, tag, msgFor(msg, msgParams));
    }

    public static void debug(String tag, String msg, Object... msgParams) {
        d(tag, msg, msgParams);
    }

    public static void i(String tag, String msg, Object... msgParams) {
        instance.log(Log.INFO, tag, msgFor(msg, msgParams));
    }

    public static void info(String tag, String msg, Object... msgParams) {
        i(tag, msg, msgParams);
    }

    public static void w(String tag, String msg, Object... msgParams) {
        instance.log(Log.WARN, tag, msgFor(msg, msgParams));
    }

    public static void warn(String tag, String msg, Object... msgParams) {
        w(tag, msg, msgParams);
    }

    public static void e(String tag, String msg, Object... msgParams) {
        instance.logError(tag, msgFor(msg, msgParams), throwableFor(msgParams));
    }

    public static void error(String tag, String msg, Object... msgParams) {
        e(tag, msg, msgParams);
    }

    protected void log(int level, String tag, String msg) {
        Log.println(level, tag, msg);
    }

    protected void logError(String tag, String msg, Throwable t) {
        Log.e(tag, msg, t);
    }

    private static String msgFor(String msg, Object... msgParams) {
        return msgParams.length == 0 ? msg : String.format(msg, msgParams);
    }

    private static Throwable throwableFor(Object... msgParams) {
        for (int i = 0; i < msgParams.length; i++) {
            Object param = msgParams[i];
            if (param instanceof Throwable) {
                return (Throwable) param;
            }
        }
        return null;
    }
}
