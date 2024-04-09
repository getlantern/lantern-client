package org.getlantern.mobilesdk.embedded;

import android.content.Context;

import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.LanternNotRunningException;
import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.StartResult;

import internalsdk.Session;

public class EmbeddedLantern extends Lantern {
    private static final String TAG = "EmbeddedLantern";

    @Override
    protected StartResult start(final Context context, final String locale, final Settings settings,
                                final Session session) throws LanternNotRunningException {

        return start(configDirFor(context, ""), locale, settings, session);
    }

    public StartResult start(final String configDir, final String locale, final Settings settings, final Session session)
            throws LanternNotRunningException {

        try {
            internalsdk.StartResult result = internalsdk.Internalsdk.start(configDir, locale, settings, session);
            return new StartResult(result.getHTTPAddr(), result.getSOCKS5Addr(), result.getDNSGrabAddr());
        } catch (Exception e) {
            throw new LanternNotRunningException("Unable to start EmbeddedLantern: " + e.getMessage(), e);
        }
    }
}
