package org.getlantern.lantern.model;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningServiceInfo;
import android.app.DialogFragment;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.method.MovementMethod;
import android.text.style.UnderlineSpan;
import android.util.Patterns;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.content.ContextCompat;

import com.google.android.material.snackbar.Snackbar;

import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.WebViewActivity_;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

import java.lang.reflect.Field;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

public class Utils {
    private static final String TAG = Utils.class.getName();

    // isDebuggable checks the debuggable flag of the package
    // to determine if the current build is a debug build
    public static boolean isDebuggable(Context context) {
        try {
            return (context.getPackageManager().getPackageInfo(
                        context.getPackageName(), 0).applicationInfo.flags &
                    ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        } catch (PackageManager.NameNotFoundException e) {
            Logger.error(TAG, "Error fetching package information: " + e.getMessage());
        }
        return false;
    }

    public static void copyToClipboard(Context context, String label,
            String text) {
        ClipboardManager clipboard = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        clipboard.addPrimaryClipChangedListener(new ClipboardManager.OnPrimaryClipChangedListener() {
            @Override
            public void onPrimaryClipChanged() {
                // do nothing
            }
        });
        ClipData clip = ClipData.newPlainText(label, text);
        clipboard.setPrimaryClip(clip);
    }

    public static void clickify(TextView view, final String clickableText,
        final ClickSpan.OnClickListener listener) {
        clickify(view, clickableText, -1, listener);
    }

    public static void clickify(TextView view, final String clickableText, final int color,
        final ClickSpan.OnClickListener listener) {
        clickify(view, clickableText, color, false, listener);
    }

    public static void clickify(TextView view, final String clickableText, final int color, boolean hasUnderline,
                                final ClickSpan.OnClickListener listener) {
        if (view == null) {
            return;
        }

        CharSequence text = view.getText();
        String string = text.toString();
        ClickSpan span = new ClickSpan(listener, color);

        final int start = string.indexOf(clickableText);
        final int end = start + clickableText.length();
        if (start == -1) {
            return;
        }
        if (text instanceof Spannable) {
            ((Spannable)text).setSpan(span, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            if (hasUnderline) {
                ((Spannable)text).setSpan(new UnderlineSpan(), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
        } else {
            SpannableString s = SpannableString.valueOf(text);
            s.setSpan(span, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            if (hasUnderline) {
                s.setSpan(new UnderlineSpan(), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
            view.setText(s);
        }

        MovementMethod m = view.getMovementMethod();
        if ((m == null) || !(m instanceof LinkMovementMethod)) {
            view.setMovementMethod(LinkMovementMethod.getInstance());
        }
    }

    public static void setMargins (View view, int left, int top, int right, int bottom) {
        ViewGroup.MarginLayoutParams p = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
        p.setMargins(left, top, right, bottom);
        view.requestLayout();
    }

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

    public static void openPrivacyPolicy(Context context) {
        context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(BuildConfig.PRIVACY_POLICY_URL)));
    }

    public static void openTermsOfService(Context context) {
        context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(BuildConfig.TERMS_OF_SERVICE_URL)));
    }

    // getResId returns the corresponding resource ID given its name
    public static int getResId(String resName, Class<?> c) {

        try {
            Field idField = c.getDeclaredField(resName);
            return idField.getInt(idField);
        } catch (Exception e) {
            Logger.error(TAG, "Could not find corresponding drawable for " + resName, e);
            return -1;
        }
    }

    public static boolean isEmailValid(String email) {
        return !TextUtils.isEmpty(email) && Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }

    public static int convertDip2Pixels(final Context context, int dip) {
        return (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip,
                context.getResources().getDisplayMetrics());
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

    public static void configureEmailInput(final EditText emailInput, final View separator) {

        OnFocusChangeListener focusListener = new OnFocusChangeListener() {
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    separator.setBackgroundResource(R.color.blue_color);
                    emailInput.setCompoundDrawablesWithIntrinsicBounds(R.drawable.email_active, 0, 0, 0);
                } else {
                    separator.setBackgroundResource(R.color.edittext_color);
                    emailInput.setCompoundDrawablesWithIntrinsicBounds(R.drawable.email_inactive, 0, 0, 0);
                }
            }
        };
        emailInput.setOnFocusChangeListener(focusListener);
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

    public static void showPlainSnackbar(final CoordinatorLayout coordinatorLayout, String message) {
        if (message == null || message.equals("")) {
            return;
        }
        showSnackbar(coordinatorLayout, message, null, 0, null, null);
    }

    public static void showSnackbar(final CoordinatorLayout coordinatorLayout,
            String message, String action, int actionTextColor, Integer duration, View.OnClickListener onClick) {

        Snackbar snackBar = Snackbar
            .make(coordinatorLayout, message, Snackbar.LENGTH_LONG);
        // format snackbar
        snackBar = formatSnackbar(snackBar);
        if (action != null && onClick != null) {
            snackBar.setAction(action, onClick);
            snackBar.setActionTextColor(actionTextColor);
        }

        if (duration != null) {
            snackBar.setDuration(duration);
        }

        snackBar.show();
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
     *
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

    /**
     * getDaysSinceAppInstalled returns the number of days since the app has been installed
     *
     * @param context
     * @return
     */
    public static long getDaysSinceAppInstalled(final Context context) {
        final Date appInstalledDate = Utils.getDateAppInstalled(context);
        return Utils.daysSince(appInstalledDate);
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

    public static int getColor(Context context, int id) {
        return ContextCompat.getColor(context, id);
    }

    /**
     * Converts the given number from Eastern Arabic to Hindu-Arabic decimal
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

    public static ClickSpan.OnClickListener createClickSpan(final Context context, final String url) {
        return new ClickSpan.OnClickListener() {
            @Override
            public void onClick() {
                final Intent intent = new Intent(context,
                        WebViewActivity_.class);
                intent.putExtra("url", url);
                context.startActivity(intent);
            }
        };
    }

    // formatHeader formats an underscored key in HTTP header style.
    // eg lantern_x_foo_bar -> Lantern-X-Foo-Bar
    //
    // If the key contains "-"s already, they are preserved.
    // eg lantern-x-foo-bar -> Lantern-X-Foo-Bar
    //
    // This is necessary because certain configuration providers
    // (eg firebase) do not allow '-' in a configuration key name.
    public static String formatAsHeader(final String key) {
        StringBuilder s = new StringBuilder();
        for (final String part : key.split("_|-")) {
            if (part.isEmpty()) {
                continue;
            }
            if (s.length() > 0) {
                s.append("-");
            }
            s.append(Character.toUpperCase(part.charAt(0)));
            if (part.length() > 1) {
                s.append(part.substring(1));
            }
        }
        return s.toString();
    }

}
