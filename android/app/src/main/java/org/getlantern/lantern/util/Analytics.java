package org.getlantern.lantern.util;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.Nullable;

import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.model.ProPlan;
import org.getlantern.lantern.model.Utils;
import org.matomo.sdk.QueryParams;
import org.matomo.sdk.TrackMe;
import org.matomo.sdk.Tracker;
import org.matomo.sdk.TrackerBuilder;
import org.matomo.sdk.extra.EcommerceItems;
import org.matomo.sdk.extra.TrackHelper;

import java.util.Map;

import internalsdk.GeoCallback;
import internalsdk.Internalsdk;

/**
 * Provides a facility for tracking activity in Matomo.
 */
public class Analytics {
    public static final String CATEGORY_PURCHASING = "purchasing";
    public static final String CATEGORY_SESSION = "session";

    /**
     * The below custom dimensions are defined in Matomo and the IDs have to match what's defined there.
     **/
    public static final int DIMENSION_PLAN_ID = 1;
    public static final int DIMENSION_PROVIDER = 2;
    public static final int DIMENSION_COUNTRY = 3;
    public static final int DIMENSION_APP_VERSION = 4;

    private static org.matomo.sdk.Tracker tracker;

    synchronized private static org.matomo.sdk.Tracker getTracker(Context context) {
        if (tracker == null) {
            tracker = TrackerBuilder
                    .createDefault("https://matomo.128.network/matomo.php", 1)
                    .build(org.matomo.sdk.Matomo.getInstance(context));
            tracker.addTrackingCallback(new Tracker.Callback() {
                @Nullable
                @Override
                public TrackMe onTrack(TrackMe trackMe) {
                    // Use Lantern userID as Matomo userId
                    trackMe.set(QueryParams.USER_ID, Long.toString(LanternApp.getSession().userId()));
                    // Use Lantern deviceID as Matomo visitorId (it's 16 digit hexadecimal as required by Matomo)
                    trackMe.set(QueryParams.VISITOR_ID, LanternApp.getSession().getDeviceID());

                    // Format language as for Accept-Language header
                    String lang = LanternApp.getSession().getLanguage().replace("_", "-");
                    // Explicitly set language to help with geolocation
                    trackMe.set(QueryParams.LANGUAGE, lang);

                    // Set token_auth so that we can pass country
                    trackMe.set("token_auth", BuildConfig.MATOMO_AUTH_TOKEN);
                    // Explicitly set geolocation info
                    Internalsdk.setGeoInfo(new GeoCallback() {
                        @Override
                        public void setIP(String s) {
                            // we don't report IP
                        }

                        @Override
                        public void setCountry(String country) {
                            trackMe.set("country", country);
                        }

                        @Override
                        public void setRegion(String region) {
                            trackMe.set("region", region);
                        }

                        @Override
                        public void setCity(String city) {
                            trackMe.set("city", city);
                        }

                        @Override
                        public void setLatitude(double latitude) {
                            trackMe.set("lat", Double.toString(latitude));
                        }

                        @Override
                        public void setLongitude(double longitude) {
                            trackMe.set("long", Double.toString(longitude));
                        }
                    });
                    return trackMe;
                }
            });
            track(context).download().with(tracker);
        }

        tracker.setOptOut(!LanternApp.getSession().matomoEnabled());
        return tracker;
    }

    public static void screen(
            final Context context,
            final Activity activity) {
        track(context).screen(activity).with(getTracker(context));
    }

    public static void screen(
            final Context context,
            final String path) {
        track(context).screen(path).with(getTracker(context));
    }

    /**
     * Sends a custom matomo event
     *
     * @param context    application context
     * @param category   the event category
     * @param name       the event type
     * @param dimensions dimensions to associate with event
     */
    public static void event(
            final Context context,
            final String category,
            final String name,
            Map<Integer, String> dimensions) {
        TrackHelper helper = track(context);
        if (dimensions != null) {
            for (Map.Entry<Integer, String> dimension : dimensions.entrySet()) {
                helper.dimension(dimension.getKey(), dimension.getValue());
            }
        }
        Tracker tracker = getTracker(context);
        helper.event(category, name).with(tracker);
        tracker.dispatch(); // immediately dispatch
    }

    public static void event(
            final Context context,
            final String category,
            final String name) {
        event(context, category, name, null);
    }

    public static void purchase(
            final Context context,
            final String provider,
            ProPlan plan) {
        TrackHelper helper = track(context);
        EcommerceItems items = new EcommerceItems();
        EcommerceItems.Item item =
                new EcommerceItems.Item(plan.getId()).price(plan.getCurrencyPrice().intValue());
        items.addItem(item);
        helper.cartUpdate(plan.getUSDEquivalentPrice().intValue()).items(items);
        helper.dimension(DIMENSION_PROVIDER, provider);
        Tracker tracker = getTracker(context);
        helper.event(CATEGORY_PURCHASING, "purchase").with(tracker);
        tracker.dispatch(); // immediately dispatch
    }

    private static TrackHelper track(Context context) {
        TrackHelper helper = TrackHelper.track();
        helper.dimension(DIMENSION_COUNTRY, LanternApp.getSession().getCountryCode());
        helper.dimension(DIMENSION_APP_VERSION, Utils.appVersion(context));
        return helper;
    }
}
