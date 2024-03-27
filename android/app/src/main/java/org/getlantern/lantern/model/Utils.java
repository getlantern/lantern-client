package org.getlantern.lantern.model;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningServiceInfo;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;

import com.google.android.material.snackbar.Snackbar;

import org.getlantern.mobilesdk.Logger;

import java.text.NumberFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

public class Utils {
    private static final String TAG = Utils.class.getName();


    // openPlayStore opens Lantern's app details page in the Google Play store.
    // - if we can't open the page in Play itself, resort to opening it in the browser
    public static void openPlayStore(Context context) {
        final String appPackageName = context.getPackageName();
        try {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
        } catch (android.content.ActivityNotFoundException anfe) {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appPackageName)));
        }
    }


    public static String appVersion(final Context context) {
        try {
            PackageInfo pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            return pInfo.versionName;
        } catch (android.content.pm.PackageManager.NameNotFoundException nne) {
            Logger.error(TAG, "Could not find package: " + nne.getMessage());
        }
        return "unknown";
    }

    public static void showAlertDialog(final Activity activity,
                                       CharSequence title, CharSequence msg,
                                       final boolean finish) {
        Utils.showAlertDialog(activity, title, msg, "OK", finish, null, true);
    }

    public static void showAlertDialog(final Activity activity,
                                       CharSequence title, CharSequence msg,
                                       final boolean finish, Boolean cancelable) {
        Utils.showAlertDialog(activity, title, msg, "OK", finish, null, cancelable);
    }

    public static void showAlertDialog(final Activity activity,
                                       CharSequence title,
                                       CharSequence msg,
                                       CharSequence okLabel,
                                       final boolean finish,
                                       Runnable onClick,
                                       Boolean cancelable) {
        Logger.debug(TAG, "Showing alert dialog...");

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog alertDialog = new AlertDialog.Builder(activity).create();
                alertDialog.setTitle(title);
                alertDialog.setMessage(msg);
                alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, okLabel,
                        (dialog, which) -> {
                            dialog.dismiss();
                            if (onClick != null) {
                                onClick.run();
                            }
                            if (finish) {
                                activity.finish();
                            }
                        });
                if (!activity.isFinishing()) {
                    alertDialog.show();
                    // Make the message clickable in case it has embedded links
                    ((TextView) alertDialog.findViewById(android.R.id.message)).setMovementMethod(LinkMovementMethod.getInstance());
                }
                alertDialog.setCancelable(cancelable);
            }
        });
    }

    public static Snackbar formatSnackbar(Snackbar snackbar) {
        View snackView = snackbar.getView();
        snackView.setBackgroundColor(Color.BLACK);
        TextView tv = (TextView) snackView.findViewById(com.google.android.material.R.id.snackbar_text);
        tv.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL));
        tv.setTextColor(Color.WHITE);
        tv.setTextSize(14);
        tv.setMaxLines(4);
        return snackbar;
    }


    /**
     * daysSince is a utility method to get the number of days
     * between the current date and a particular date
     */
    public static long daysSince(final Date date) {
        return TimeUnit.MILLISECONDS.toDays(Calendar.getInstance().getTimeInMillis() - date.getTime());
    }

    /**
     * getDateAppInstalled gets the date the app was installed on.
     */
    public static Date getDateAppInstalled(final Context context) {
        try {
            final PackageInfo packageInfo = context.getPackageManager()
                    .getPackageInfo(context.getPackageName(), 0);
            return new Date(packageInfo.firstInstallTime);
        } catch (NameNotFoundException e) {
            Logger.error(TAG, "Could not get info about app:", e);
        }
        // it is highly unlikely we'd ever get here, but just
        // return the current date in that case
        return new Date();
    }


    // isNetworkAvailable checks whether or not we are connected to
    // the Internet; if no connection is available, the toggle
    // switch is inactive
    public static boolean isNetworkAvailable(final Context context) {
        final ConnectivityManager connectivityManager =
                ((ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE));
        return connectivityManager.getActiveNetworkInfo() != null &&
                connectivityManager.getActiveNetworkInfo().isConnectedOrConnecting();
    }

    public static boolean isServiceRunning(final Context context,
                                           Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return service.started;
            }
        }
        return false;
    }

    /**
     * Converts the given number from Eastern Arabic to Hindu-Arabic decimal
     *
     * @param number the number to convert
     * @return the converted number
     */
    public static String convertEasternArabicToDecimal(final long number) {
        // format the number to English locale
        final NumberFormat nf = NumberFormat.getInstance(Locale.ENGLISH);
        return nf.format(number);
    }

    public static String convertEasternArabicToDecimalFloat(final float number) {
        // format the number to English locale
        final NumberFormat nf = NumberFormat.getInstance(Locale.ENGLISH);
        return nf.format(number);
    }

}
