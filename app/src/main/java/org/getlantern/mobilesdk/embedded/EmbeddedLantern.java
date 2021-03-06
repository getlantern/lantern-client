package org.getlantern.mobilesdk.embedded;

import android.content.Context;

import org.getlantern.mobilesdk.Settings;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.LanternNotRunningException;
import org.getlantern.mobilesdk.StartResult;

import android.Session;

public class EmbeddedLantern extends Lantern {
  private static final String TAG = "EmbeddedLantern";

  static {
    // Track extra info about Android for Logging to Loggly.
    EmbeddedLantern.addLoggingMetadata("androidDevice", android.os.Build.DEVICE);
    org.getlantern.mobilesdk.Lantern.addLoggingMetadata("androidModel", android.os.Build.MODEL);
    org.getlantern.mobilesdk.Lantern.addLoggingMetadata("androidSdkVersion",
        "" + android.os.Build.VERSION.SDK_INT + " (" + android.os.Build.VERSION.RELEASE + ")");
  }

  @Override
  protected StartResult start(final Context context, final String locale, final Settings settings,
      final Session session) throws LanternNotRunningException {

    return start(configDirFor(context, ""), locale, settings, session);
  }

  public StartResult start(final String configDir, final String locale, final Settings settings, final Session session)
      throws LanternNotRunningException {

    try {
      android.StartResult result = android.Android.start(configDir, locale, settings, session);
      return new StartResult(result.getHTTPAddr(), result.getSOCKS5Addr(), result.getDNSGrabAddr());
    } catch (Exception e) {
      throw new LanternNotRunningException("Unable to start EmbeddedLantern: " + e.getMessage(), e);
    }
  }
}
