package org.getlantern.mobilesdk.activity;

import android.Android;
import android.Manifest;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.content.pm.PermissionInfo;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.net.VpnService;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.text.Html;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;

import com.google.android.material.snackbar.Snackbar;
import com.google.gson.Gson;
import com.thefinestartist.finestwebview.FinestWebView;

import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.CheckUpdate;
import org.getlantern.lantern.model.Constants;
import org.getlantern.lantern.model.ListAdapter;
import org.getlantern.lantern.model.NavItem;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.model.Utils;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.lantern.vpn.LanternVpnService;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.model.LoConf;
import org.getlantern.mobilesdk.model.LoConfCallback;
import org.getlantern.mobilesdk.model.PopUpAd;
import org.getlantern.mobilesdk.model.Survey;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public abstract class BaseActivity extends AppCompatActivity {

    private static final String TAG = BaseActivity.class.getName();
    private static final String SURVEY_TAG = TAG + ".survey";
    private static final String PERMISSIONS_TAG = TAG + ".permissions";

    private static final int REQUEST_VPN = 7777;

    private static final int FULL_PERMISSIONS_REQUEST = 8888;

    private String appVersion;

    private DrawerLayout drawerLayout;
    private ListView drawerList;

    protected CoordinatorLayout coordinatorLayout;

    private RelativeLayout drawerPane;

    protected ImageView menuIcon;

    protected ImageView headerLogo;

    private TextView versionNum;

    private TextView privacyPolicyLink;
    private TextView termsOfServiceLink;

    private ActionBarDrawerToggle drawerToggle;

    protected int white, cardBlueColor, proBlueColor, black, customTabColor;

    private final ServiceConnection lanternServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceDisconnected(ComponentName name) {
            Logger.e(TAG, "LanternService disconnected, closing app");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                finishAndRemoveTask();
            }
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
        }
    };

    protected void initViews() {

        final Resources res = getResources();
        white = res.getColor(R.color.accent_white);
        cardBlueColor = res.getColor(R.color.card_blue_color);
        proBlueColor = res.getColor(R.color.pro_blue_color);
        black = res.getColor(R.color.black);
        customTabColor = res.getColor(R.color.custom_tab_icon);

        headerLogo = (ImageView) findViewById(R.id.headerLogo);
        menuIcon = (ImageView) findViewById(R.id.menuIcon);
        drawerPane = (RelativeLayout) findViewById(R.id.drawerPane);
        drawerLayout = (DrawerLayout) findViewById(R.id.drawerLayout);
        drawerList = (ListView) findViewById(R.id.drawerList);

        coordinatorLayout = (CoordinatorLayout) findViewById(R.id.coordinatorLayout);

        versionNum = (TextView) findViewById(R.id.versionNum);
        menuIcon.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                drawerLayout.openDrawer(GravityCompat.START);
            }
        });

        privacyPolicyLink = (TextView) findViewById(R.id.privacyPolicyLink);
        termsOfServiceLink = (TextView) findViewById(R.id.termsOfServiceLink);

        privacyPolicyLink.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Utils.openPrivacyPolicy(BaseActivity.this);
            }
        });

        termsOfServiceLink.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Utils.openTermsOfService(BaseActivity.this);
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Logger.debug(TAG, "Default Locale is %1$s", Locale.getDefault());
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this);
        }

        setContentView(getLayoutId());

        initViews();

        final Intent intent = new Intent(this, org.getlantern.lantern.service.LanternService_.class);
        bindService(intent, lanternServiceConnection, Context.BIND_AUTO_CREATE);

        // we want to use the ActionBar from the AppCompat
        // support library, but with our custom design
        // we hide the default action bar
        if (getSupportActionBar() != null) {
            getSupportActionBar().hide();
        }

        // make sure to show status bar
        if (getWindow() != null) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }

        setVersionNum();
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (LanternApp.getSession().lanternDidStart()) {
            fetchLoConf();
        }
        setupSideMenu();

        if (Utils.isPlayVersion(this)) {
            if (!LanternApp.getSession().hasAcceptedTerms()) {
                startActivity(new Intent(this, org.getlantern.lantern.activity.PrivacyDisclosureActivity_.class));
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
        try {
            unbindService(lanternServiceConnection);
        } catch (Throwable t) {
            Logger.e(TAG, "Unable to unbind LanternService", t);
        }
    }

    // override onKeyDown and onBackPressed default
    // behavior to prevent back button from interfering
    // with on/off switch
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (Integer.parseInt(Build.VERSION.SDK) > 5 && keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
            Logger.debug(TAG, "onKeyDown Called");
            onBackPressed();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onBackPressed() {
        Logger.debug(TAG, "onBackPressed Called");
        try {
            Intent setIntent = new Intent(Intent.ACTION_MAIN);
            setIntent.addCategory(Intent.CATEGORY_HOME);
            setIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(setIntent);
        } catch (Exception e) {
            Logger.error(TAG, "Unable to resume main activity", e);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (drawerToggle.onOptionsItemSelected(item)) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void setupSideMenu() {
        final BaseActivity activity = this;
        final Resources resources = getResources();
        final ArrayList<NavItem> navItems = new ArrayList<NavItem>();
        final ListAdapter listAdapter = new ListAdapter(this, navItems);

        final TypedArray icons = resources.obtainTypedArray(getSideMenuIconIDs());
        final TypedArray ids = resources.obtainTypedArray(getSideMenuIDs());
        final String[] titles = resources.getStringArray(getSideMenuOptions());

        for (int i = 0; i < titles.length; i++) {
            final int id = ids.getResourceId(i, 0);
            final int icon = icons.getResourceId(i, 0);
            if (BuildConfig.PLAY_VERSION) {
                if (id == R.id.check_for_update || id == R.id.get_lantern_pro) {
                    continue;
                }
            }
            navItems.add(new NavItem(id, titles[i], icon));
        }

        // Populate the Navigtion Drawer with options
        drawerList.setAdapter(listAdapter);

        // remove ListView border
        drawerList.setDivider(null);

        // Drawer Item click listeners
        drawerList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                final NavItem navItem = (NavItem) parent.getAdapter().getItem(position);
                if (navItem != null) {
                    drawerItemClicked(navItem, position);
                }
            }
        });

        drawerToggle = new ActionBarDrawerToggle(this, drawerLayout, R.string.drawer_open, R.string.drawer_close) {
            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                invalidateOptionsMenu();
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                invalidateOptionsMenu();
            }
        };

        drawerLayout.setDrawerListener(drawerToggle);
    }

    protected int getSideMenuIDs() {
        return R.array.free_side_menu_ids;
    }

    protected int getSideMenuIconIDs() {
        return R.array.free_side_menu_icons;
    }

    protected int getSideMenuOptions() {
        return R.array.free_side_menu_options;
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void runCheckUpdate(final CheckUpdate checkUpdate) {
        final boolean userInitiated = checkUpdate.getUserInitiated();
        if (Utils.isPlayVersion(this)) {
            Logger.debug(TAG, "App installed via Play; not checking for update");
            if (userInitiated) {
                // If the user installed the app via Google Play,
                // we just open the Play store
                // because self-updating will not work:
                // "An app downloaded from Google Play may not modify,
                // replace, or update itself
                // using any method other than Google Play's update mechanism"
                // https://play.google.com/about/privacy-and-security.html#malicious-behavior
                Utils.openPlayStore(this);
            }
            return;
        }
        new UpdateTask(this, userInitiated).execute();
    }

    private void noUpdateAvailable(boolean showAlert) {
        if (!showAlert) {
            return;
        }

        String appName = getResources().getString(R.string.app_name);
        String noUpdateTitle = getResources().getString(R.string.no_update_available);
        String noUpdateMsg = String.format(getResources().getString(R.string.have_latest_version), appName, appVersion);
        ActivityExtKt.showAlertDialog(this, noUpdateTitle, noUpdateMsg);
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        if (drawerToggle != null) {
            drawerToggle.syncState();
        }
    }

    /**
     * drawerItemClicked is called whenever an item in the
     * navigation menu is clicked on
     *
     */
    protected void drawerItemClicked(final NavItem navItem, final int position) {
        Class itemClass = null;
        switch (navItem.getId()) {
            case R.id.check_for_update:
                runCheckUpdate(new CheckUpdate(true));
                break;
            case R.id.language:
                itemClass = LanguageActivity.class;
                break;
            case R.id.action_settings:
                itemClass = SettingsActivity.class;
                break;
            case R.id.report_an_issue:
                itemClass = ReportIssueActivity.class;
        }

        if (itemClass != null) {
            startActivity(new Intent(this, itemClass));
        }

        drawerList.setItemChecked(position, true);
        drawerLayout.closeDrawer(drawerPane);
    }

    public void showSurvey(final Survey survey) {

        final String url = survey.getUrl();
        if (url != null && !url.equals("")) {
            if (LanternApp.getSession().surveyLinkOpened(url)) {
                Logger.debug(TAG, "User already opened link to survey; not displaying snackbar");
                return;
            }
        }

        final View.OnClickListener surveyListener = new View.OnClickListener() {
            public void onClick(View v) {
                surveyClicked(survey);
            }
        };
        Logger.debug(TAG, "Showing user survey snackbar");
        Utils.showSnackbar(coordinatorLayout, survey.getMessage(), survey.getButton(),
                getResources().getColor(R.color.pink), Snackbar.LENGTH_INDEFINITE, surveyListener);
    }

    protected void surveyClicked(final Survey survey) {
        LanternApp.getSession().setSurveyLinkOpened(survey.getUrl());

        new FinestWebView.Builder(BaseActivity.this)
                .webViewLoadWithProxy(LanternApp.getSession().getHTTPAddr())
                .webViewSupportMultipleWindows(true)
                .webViewJavaScriptEnabled(true)
                .swipeRefreshColorRes(R.color.black)
                .webViewAllowFileAccessFromFileURLs(true)
                .webViewJavaScriptCanOpenWindowsAutomatically(true)
                .show(survey.getUrl());
    }

    /**
     * Fetch the latest loconf config and update the UI based on those
     * settings
     */
    protected void fetchLoConf() {
        LoConf.Companion.fetch(new LoConfCallback() {
            @Override
            public void onSuccess(final LoConf loconf) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        processLoconf(loconf);
                    }
                });
            }
        });
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void processLoconf(final LoConf loconf) {
        final String locale = LanternApp.getSession().getLanguage();
        final String countryCode = LanternApp.getSession().getCountryCode();
        Logger.debug(SURVEY_TAG, "Processing loconf; country code is " + countryCode);

        if (loconf.getPopUpAds() != null) {
            handlePopUpAd(loconf.getPopUpAds());
        }

        if (loconf.getSurveys() == null) {
            Logger.debug(SURVEY_TAG, "No survey config");
            return;
        }

        for (String key : loconf.getSurveys().keySet()) {
            Logger.debug(SURVEY_TAG, "Survey: " + loconf.getSurveys().get(key));
        }

        String key = countryCode;
        Survey survey = loconf.getSurveys().get(key);
        if (survey == null) {
            key = countryCode.toLowerCase();
            survey = loconf.getSurveys().get(key);
        }
        if (survey == null || !survey.getEnabled()) {
            key = locale;
            survey = loconf.getSurveys().get(key);
        }

        if (survey == null) {
            Logger.debug(SURVEY_TAG, "No survey found");
        } else if (!survey.getEnabled()) {
            Logger.debug(SURVEY_TAG, "Survey disabled");
        } else if (Math.random() > survey.getProbability()) {
            Logger.debug(SURVEY_TAG, "Not showing survey this time");
        } else {
            Logger.debug(SURVEY_TAG, "Deciding whether to show survey for '%s' at %s", key, survey.getUrl());
            final String userType = survey.getUserType();
            if (userType != null) {
                if (userType.equals("free") && LanternApp.getSession().isProUser()) {
                    Logger.debug(SURVEY_TAG, "Not showing messages targetted to free users to Pro users");
                    return;
                } else if (userType.equals("pro") && !LanternApp.getSession().isProUser()) {
                    Logger.debug(SURVEY_TAG, "Not showing messages targetted to free users to Pro users");
                    return;
                }
            }
            showSurvey(survey);
        }
    }

    /**
     * Check if a popup ad is enabled for the current region or language
     * and display the corresponding ad to the user if so
     * @param popUpAds the popUpAds as defined in loconf
     */
    private void handlePopUpAd(final Map<String, PopUpAd> popUpAds) {
        PopUpAd popUpAd = popUpAds.get(LanternApp.getSession().getCountryCode());
        if (popUpAd == null) {
            popUpAd = popUpAds.get(LanternApp.getSession().getLanguage());
        }
        if (popUpAd == null || !popUpAd.getEnabled()) {
            return;
        }
        if (!LanternApp.getSession().hasPrefExpired("popUpAd")) {
            Logger.debug(TAG, "Not showing popup ad: not enough time has elapsed since it was last shown to the user");
            return;
        }
        Logger.debug(TAG, "Displaying popup ad..");
        final Integer numSeconds = popUpAd.getDisplayFrequency();
        LanternApp.getSession().saveExpiringPref("popUpAd", numSeconds);
        final Intent intent = new Intent(this, org.getlantern.lantern.activity.PopUpAdActivity_.class);
        intent.putExtra("popUpAdStr", new Gson().toJson(popUpAd));
        startActivity(intent);
    }

    /**
     * Set the version number that appears in the bottom of the side menu
     */
    private void setVersionNum() {
        this.appVersion = Utils.appVersion(this);
        Logger.debug(TAG, "Currently running Lantern version: " + appVersion);
        if (versionNum != null) {
            versionNum.setText(appVersion);
        }
    }

    /**
     *   UpdateTask compares the current app version with the latest available
     *   If an update is available, we start the Update activity
     *   and prompt the user to download it
     *   - If no update is available, an alert dialog is displayed
     *   - userInitiated is a boolean used to indicate whether the udpate was
     *   triggered from the side-menu or is an automatic check
     */
    private class UpdateTask extends AsyncTask<Void, Void, String> {
        private Activity activity;
        private boolean userInitiated;

        public UpdateTask(final Activity activity, final boolean userInitiated) {
            this.activity = activity;
            this.userInitiated = userInitiated;
        }

        @Override
        protected String doInBackground(Void... v) {
            try {
                Logger.debug(TAG, "Checking for updates");
                return Android.checkForUpdates();
            } catch (Exception e) {
                Logger.error(TAG, "Error checking for update", e);
            }
            return null;
        }

        @Override
        protected void onPostExecute(final String url) {
            // No error occurred but the returned url is empty which
            // means no update is available
            if (url == null) {
                String appName = getResources().getString(R.string.app_name);
                String message = String.format(getResources().getString(R.string.error_checking_for_update), appName);
                ActivityExtKt.showAlertDialog(activity, appName, message);
                return;
            }
            if (url.equals("")) {
                noUpdateAvailable(userInitiated);
                Logger.debug(TAG, "No update available");
                return;
            }
            Logger.debug(TAG, "Update available at " + url);
            // an updated version of Lantern is available at the given url
            Intent intent = new Intent(activity, org.getlantern.lantern.activity.UpdateActivity_.class);
            intent.putExtra("updateUrl", url);
            startActivity(intent);
        }
    }

    public void switchLantern(final boolean on) throws Exception {
        Logger.d(TAG, "switchLantern to %1$s", on);

        // disable the on/off switch while the VpnService
        // is updating the connection

        if (on) {
            // Make sure we have the necessary permissions
            String[] neededPermissions = missingPermissions();
            if (neededPermissions.length > 0) {
                StringBuilder msg = new StringBuilder();
                for (String permission : neededPermissions) {
                    if (!hasPermission(permission)) {
                        msg.append("<p style='font-size: 0.5em;'><b>");
                        PackageManager pm = getPackageManager();
                        try {
                            PermissionInfo info = pm.getPermissionInfo(permission, PackageManager.GET_META_DATA);
                            CharSequence label = info.loadLabel(pm);
                            msg.append(label);
                        } catch (PackageManager.NameNotFoundException nmfe) {
                            Logger.error(PERMISSIONS_TAG, "Unexpected exception loading label for permission %s: %s", permission, nmfe);
                            msg.append(permission);
                        }
                        msg.append("</b>&nbsp;");
                        msg.append(getString(R.string.permission_for));
                        msg.append("&nbsp;");
                        String description = "...";
                        try {
                            description = getString(getResources().getIdentifier(permission, "string", "org.getlantern.lantern"));
                        } catch (Throwable t) {
                            Logger.warn(PERMISSIONS_TAG, "Couldn't get permission description for %s: %s", permission, t);
                        }
                        msg.append(description);
                        msg.append("</p>");
                    }
                }

                Logger.debug(PERMISSIONS_TAG, msg.toString());

                ActivityExtKt.showAlertDialog(this,
                    getString(R.string.please_allow_lantern_to),
                    Html.fromHtml(msg.toString()),
                    null,
                    () -> ActivityCompat.requestPermissions(BaseActivity.this, neededPermissions, FULL_PERMISSIONS_REQUEST),
                    getString(R.string.continue_));
                return;
            }


            // Prompt the user to enable full-device VPN mode
            // Make a VPN connection from the client
            Logger.debug(TAG, "Load VPN configuration");
            Intent intent = VpnService.prepare(this);
            if (intent != null) {
                Logger.warn(TAG, "Requesting VPN connection");
                startActivityForResult(intent.setAction(LanternVpnService.ACTION_CONNECT), REQUEST_VPN);
            } else {
                Logger.debug(TAG, "VPN enabled, starting Lantern...");
                updateStatus(true);
                startVpnService();
            }
        } else {
            stopVpnService();
            updateStatus(false);
        }
    }

    private static final String[] allRequiredPermissions = new String[]{
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE};
    // Note - we do not include Manifest.permission.FOREGROUND_SERVICE because this is automatically
    // granted based on being included in Manifest and will show as denied even if we're eligible
    // to get it.

    private String[] missingPermissions() {
        List<String> missingPermissions = new ArrayList<String>();
        for (String permission : allRequiredPermissions) {
            if (!hasPermission(permission)) {
                missingPermissions.add(permission);
            }
        }
        return missingPermissions.toArray(new String[missingPermissions.size()]);
    }

    private boolean hasPermission(String permission) {
        boolean result = ContextCompat.checkSelfPermission(getApplicationContext(), permission) == PackageManager.PERMISSION_GRANTED;
        Logger.debug(PERMISSIONS_TAG, "has permission %s: %s", permission, result);
        return result;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case FULL_PERMISSIONS_REQUEST: {
                Logger.debug(PERMISSIONS_TAG, "Got result for %s: %s", permissions.length, grantResults.length);
                for (int i=0; i<permissions.length; i++) {
                    String permission = permissions[i];
                    int result = grantResults[i];
                    if (result == PackageManager.PERMISSION_DENIED) {
                        Logger.debug(PERMISSIONS_TAG, "User denied permission %s", permission);
                        return;
                    }
                }

                Logger.debug(PERMISSIONS_TAG, "User granted requested permissions, attempt to switch on Lantern");
                try {
                    switchLantern(true);
                } catch (Exception e) {
                    Logger.error(PERMISSIONS_TAG, "Unable to switch on Lantern", e);
                }

                return;
            }
        }
    }

    @Override
    protected void onActivityResult(int request, int response, Intent data) {
        super.onActivityResult(request, response, data);
        if (request == REQUEST_VPN) {
            boolean useVpn = response == RESULT_OK;
            updateStatus(useVpn);
            if (useVpn) {
                startVpnService();
            }
        }
    }

    protected void startVpnService() {
        startService(new Intent(this, LanternVpnService.class).setAction(LanternVpnService.ACTION_CONNECT));
    }

    protected void stopVpnService() {
        startService(new Intent(this, LanternVpnService.class).setAction(LanternVpnService.ACTION_DISCONNECT));
    }

    protected void updateStatus(boolean useVpn) {
        Logger.d(TAG, "Updating VPN status to %1$s", useVpn);
        EventBus.getDefault().post(new VpnState(useVpn));
        LanternApp.getSession().updateVpnPreference(useVpn);
        LanternApp.getSession().updateBootUpVpnPreference(useVpn);
    }

    protected void setupTabView(final View view, final boolean useVpn, final int position) {
        final Resources res = getResources();
        final ImageView icon = (ImageView) view.findViewById(R.id.tabIcon);
        final TextView title = (TextView) view.findViewById(R.id.tabText);
        switch (position) {
            case Constants.MAIN_SWITCH_TAB:
                break;
            case Constants.LOCATION_TAB:
                icon.setImageDrawable(res.getDrawable(R.drawable.location_icon));
                title.setText(LanternApp.getSession().getServerCountryCode());
                break;
        }
    }

    // Recreate the activity when the language changes
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void languageChanged(final Locale locale) {
        recreate();
    }

    /**
     * @return The layout id of the activity view.
     */
    protected abstract int getLayoutId();

}
