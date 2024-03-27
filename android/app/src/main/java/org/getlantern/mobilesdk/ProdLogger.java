package org.getlantern.mobilesdk;

import android.content.Context;

import internalsdk.Internalsdk;

public class ProdLogger extends Logger {
    protected ProdLogger() {
        super();
    }

    synchronized public static void enable(Context context) {
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
}