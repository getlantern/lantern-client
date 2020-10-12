package org.getlantern.lantern.activity;

import android.Android;
import android.Manifest;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
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
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.viewpager.widget.PagerAdapter;

import com.google.android.material.snackbar.Snackbar;
import com.google.gson.Gson;
import com.ogaclejapan.smarttablayout.SmartTabLayout;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItem;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItemAdapter;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItems;
import com.thefinestartist.finestwebview.FinestWebView;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.getlantern.lantern.BuildConfig;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.yinbi.YinbiLauncher;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.fragment.TabFragment;
import org.getlantern.lantern.model.AuctionCountDown;
import org.getlantern.lantern.model.AuctionInfo;
import org.getlantern.lantern.model.BannerAd;
import org.getlantern.lantern.model.CheckUpdate;
import org.getlantern.lantern.model.Constants;
import org.getlantern.lantern.model.DynamicViewPager;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.LanternStatus;
import org.getlantern.lantern.model.ListAdapter;
import org.getlantern.lantern.model.LoConf;
import org.getlantern.lantern.model.NavItem;
import org.getlantern.lantern.model.PopUpAd;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProUser;
import org.getlantern.lantern.model.SessionManager;
import org.getlantern.lantern.model.Survey;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.lantern.service.LanternService_;
import org.getlantern.lantern.vpn.LanternVpnService;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.activity.LanguageActivity;
import org.getlantern.mobilesdk.activity.SettingsActivity;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import okhttp3.Response;

public abstract class BaseActivity extends AppCompatActivity {

    private static final String TAG = BaseActivity.class.getName();
    private static final String SURVEY_TAG = TAG + ".survey";
    private static final String PERMISSIONS_TAG = TAG + ".permissions";

    protected static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    protected static final SessionManager session = LanternApp.getSession();

    private static final int REQUEST_VPN = 7777;

    private static final int FULL_PERMISSIONS_REQUEST = 8888;

    private AuctionCountDown countDown;

    private String appVersion;

    protected DrawerLayout drawerLayout;
    private ListView drawerList;

    protected CoordinatorLayout coordinatorLayout;

    protected RelativeLayout drawerPane;

    protected LinearLayout yinbiAdLayout;

    protected LinearLayout bulkRenewSection;

    protected SmartTabLayout viewPagerTab;

    protected DynamicViewPager viewPager;

    protected ImageView menuIcon;

    protected ImageView headerLogo;

    private TextView bulkRenew;
    protected TextView versionNum;
    protected TextView yinbiWebsite;
    protected TextView yinbiAdText;

    protected TextView privacyPolicyLink;
    protected TextView termsOfServiceLink;
    protected Snackbar statusSnackbar;

    private ActionBarDrawerToggle drawerToggle;

    protected int white, cardBlueColor, proBlueColor, black, customTabColor;

    private final ServiceConnection lanternServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceDisconnected(ComponentName name) {
            Logger.e(TAG, "LanternService disconnected, closing app");
            finishAndRemoveTask();
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
        }
    };

    private void initViews() {

        final Resources res = getResources();
        white = res.getColor(R.color.accent_white);
        cardBlueColor = res.getColor(R.color.card_blue_color);
        proBlueColor = res.getColor(R.color.pro_blue_color);
        black = res.getColor(R.color.black);
        customTabColor = res.getColor(R.color.custom_tab_icon);

        bulkRenewSection = (LinearLayout) findViewById(R.id.bulkRenewSection);

        headerLogo = (ImageView) findViewById(R.id.headerLogo);
        viewPager = (DynamicViewPager) findViewById(R.id.viewPager);
        viewPagerTab = (SmartTabLayout) findViewById(R.id.viewPagerTab);
        menuIcon = (ImageView) findViewById(R.id.menuIcon);
        drawerPane = (RelativeLayout) findViewById(R.id.drawerPane);
        drawerLayout = (DrawerLayout) findViewById(R.id.drawerLayout);
        drawerList = (ListView) findViewById(R.id.drawerList);

        coordinatorLayout = (CoordinatorLayout) findViewById(R.id.coordinatorLayout);

        versionNum = (TextView) findViewById(R.id.versionNum);
        yinbiAdLayout = (LinearLayout) findViewById(R.id.yinbiAdLayout);
        yinbiWebsite = (TextView) findViewById(R.id.yinbiWebsite);
        yinbiAdText = (TextView) findViewById(R.id.yinbiAdText);

        bulkRenew = (TextView) findViewById(R.id.bulkRenew);
        bulkRenew.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                lanternClient.openBulkProCodes(BaseActivity.this);
            }
        });

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

        statusSnackbar = Utils.formatSnackbar(
                Snackbar.make(coordinatorLayout, getResources().getString(R.string.lantern_off), Snackbar.LENGTH_LONG));

        final Intent intent = new Intent(this, LanternService_.class);
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
        if (session.yinbiEnabled()) {
            bulkRenewSection.setVisibility(View.VISIBLE);
        } else {
            final View tab = (View)viewPagerTab.getTabAt(Constants.YINBI_AUCTION_TAB);
            if (tab != null) {
                tab.setVisibility(View.GONE);
            }
        }

        if (session.lanternDidStart()) {
            fetchLoConf();
        }
        setupTabs();
        setupSideMenu();
        updateUserData();

        if (Utils.isPlayVersion(this)) {
            if (!session.hasAcceptedTerms()) {
                startActivity(new Intent(this, PrivacyDisclosureActivity_.class));
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

    @Override
    protected void onPause() {
        super.onPause();
        // stop auction countdown
        if (countDown != null) {
            countDown.cancel();
            countDown = null;
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

        final TypedArray icons;
        final TypedArray ids;
        final String[] titles;
        if (session.isProUser()) {
            ids = getResources().obtainTypedArray(R.array.pro_side_menu_ids);
            icons = getResources().obtainTypedArray(R.array.pro_side_menu_icons);
            titles = getResources().getStringArray(R.array.pro_side_menu_options);
        } else {
            ids = getResources().obtainTypedArray(R.array.free_side_menu_ids);
            icons = getResources().obtainTypedArray(R.array.free_side_menu_icons);
            titles = getResources().getStringArray(R.array.free_side_menu_options);
        }

        for (int i = 0; i < titles.length; i++) {
            final int id = ids.getResourceId(i, 0);
            final int icon = icons.getResourceId(i, 0);
            if (id == R.id.yinbi_redemption && !session.yinbiEnabled()) {
                continue;
            }
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

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void lanternStarted(final LanternStatus status) {
        updateUserData();
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

        String noUpdateTitle = getResources().getString(R.string.no_update_available);
        String noUpdateMsg = String.format(getResources().getString(R.string.have_latest_version), appVersion);
        Utils.showAlertDialog(this, noUpdateTitle, noUpdateMsg, false);
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
    private void drawerItemClicked(final NavItem navItem, final int position) {
        Class itemClass = null;
        switch (navItem.getId()) {
            case R.id.get_lantern_pro:
                itemClass = session.plansActivity();
                break;
            case R.id.invite_friends:
                itemClass = InviteActivity_.class;
                break;
            case R.id.authorize_device_pro:
                itemClass = AccountRecoveryActivity_.class;
                break;
            case R.id.pro_account:
                itemClass = ProAccountActivity_.class;
                break;
            case R.id.add_device:
                itemClass = AddDeviceActivity_.class;
                break;
            case R.id.check_for_update:
                runCheckUpdate(new CheckUpdate(true));
                break;
            case R.id.yinbi_redemption:
                itemClass = YinbiLauncher.class;
                break;
            case R.id.language:
                itemClass = LanguageActivity.class;
                break;
            case R.id.desktop_option:
                itemClass = DesktopActivity_.class;
                break;
            case R.id.action_settings:
                itemClass = SettingsActivity.class;
                break;
            case R.id.report_an_issue:
                itemClass = ReportIssueActivity_.class;
                break;
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
            if (session.surveyLinkOpened(url)) {
                Logger.debug(TAG, "User already opened link to survey; not displaying snackbar");
                return;
            }
        }

        final View.OnClickListener surveyListener = new View.OnClickListener() {
            public void onClick(View v) {
                if (survey.getShowPlansScreen()) {
                    startActivity(new Intent(BaseActivity.this, session.plansActivity()));
                    return;
                }

                session.setSurveyLinkOpened(survey.getUrl());

                new FinestWebView.Builder(BaseActivity.this)
                        .webViewLoadWithProxy(session.getHTTPAddr())
                        .webViewSupportMultipleWindows(true)
                        .webViewJavaScriptEnabled(true)
                        .swipeRefreshColorRes(R.color.black)
                        .webViewAllowFileAccessFromFileURLs(true)
                        .webViewJavaScriptCanOpenWindowsAutomatically(true)
                        .show(survey.getUrl());
            }
        };
        Logger.debug(TAG, "Showing user survey snackbar");
        Utils.showSnackbar(coordinatorLayout, survey.getMessage(), survey.getButton(),
                getResources().getColor(R.color.pink), Snackbar.LENGTH_INDEFINITE, surveyListener);
    }

    /**
     * Fetch the latest loconf config and update the UI based on those
     * settings
     */
    protected void fetchLoConf() {
        lanternClient.fetchLoConf(new LanternHttpClient.LoConfCallback() {
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
        final String locale = session.getLanguage();
        final String countryCode = session.getCountryCode();
        Logger.debug(SURVEY_TAG, "Processing loconf; country code is " + countryCode);
        if (loconf.getAds() != null) {
            handleBannerAd(loconf.getAds());
        }

        if (loconf.getPopUpAds() != null) {
            handlePopUpAd(loconf.getPopUpAds());
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
                if (userType.equals("free") && session.isProUser()) {
                    Logger.debug(SURVEY_TAG, "Not showing messages targetted to free users to Pro users");
                    return;
                } else if (userType.equals("pro") && !session.isProUser()) {
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
        PopUpAd popUpAd = popUpAds.get(session.getCountryCode());
        if (popUpAd == null) {
            popUpAd = popUpAds.get(session.getLanguage());
        }
        if (popUpAd == null || !popUpAd.getEnabled()) {
            return;
        }
        if (!session.hasPrefExpired("popUpAd")) {
            Logger.debug(TAG, "Not showing popup ad: not enough time has elapsed since it was last shown to the user");
            return;
        }
        Logger.debug(TAG, "Displaying popup ad..");
        final Integer numSeconds = popUpAd.getDisplayFrequency();
        session.saveExpiringPref("popUpAd", numSeconds);
        final Intent intent = new Intent(this, PopUpAdActivity_.class);
        intent.putExtra("popUpAdStr", new Gson().toJson(popUpAd));
        startActivity(intent);
    }

    /**
     * Check if the banner ad for our region or language is enabled and display. Returns true if ad
     * was displayed.
     *
     * @param ads the ads as defined in loconf
     */
    private boolean handleBannerAd(final Map<String, BannerAd> ads) {
        BannerAd ad = ads.get(session.getCountryCode());
        if (ad == null) {
            ad = ads.get(session.getLanguage());
        }
        if (ad != null && ad.getEnabled()) {
            final String adUrl = ad.getUrl();
            Logger.debug(TAG, "Displaying banner ad with url " + adUrl + " " + ad.getText());
            yinbiAdText.setText(ad.getText());
            //Utils.setMargins(viewPagerTab, 125, 450, 0, 0);
            Utils.clickify(yinbiWebsite, getString(R.string.visit_yinbi_website), new ClickSpan.OnClickListener() {
                @Override
                public void onClick() {
                    final Intent intent = new Intent(BaseActivity.this, WebViewActivity_.class);
                    intent.putExtra("url", adUrl);
                    startActivity(intent);
                    Lantern.sendEvent(BaseActivity.this, "yinbi_link_clicked_on");
                }
            });
            yinbiWebsite.setPaintFlags(0);
            Lantern.sendEvent(this, "yinbi_ad_shown");
            yinbiAdLayout.setVisibility(View.VISIBLE);
            return true;
        }
        return false;
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
                Utils.showAlertDialog(activity, "Lantern", getResources().getString(R.string.error_checking_for_update), false);
                return;
            }
            if (url.equals("")) {
                noUpdateAvailable(userInitiated);
                Logger.debug(TAG, "No update available");
                return;
            }
            Logger.debug(TAG, "Update available at " + url);
            // an updated version of Lantern is available at the given url
            Intent intent = new Intent(activity, UpdateActivity_.class);
            intent.putExtra("updateUrl", url);
            startActivity(intent);
        }
    }

    public void switchLantern(final boolean on) throws Exception {

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

                Utils.showAlertDialog(this,
                        getString(R.string.please_allow_lantern_to),
                        Html.fromHtml(msg.toString()),
                        getString(R.string.continue_),
                        false,
                        new Runnable() {
                    @Override
                    public void run() {
                        ActivityCompat.requestPermissions(BaseActivity.this, neededPermissions, FULL_PERMISSIONS_REQUEST);
                    }
                });
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

    public void onRequestPermissionsResult(int requestCode,
                                           String[] permissions, int[] grantResults) {
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
        displayStatus(useVpn);
        EventBus.getDefault().post(new VpnState(useVpn));
        session.updateVpnPreference(useVpn);
        session.updateBootUpVpnPreference(useVpn);
    }

    private void setYinbiAuctionInfo() {
        final View tab = (View) viewPagerTab.getTabAt(Constants.YINBI_AUCTION_TAB);
        if (tab == null) {
            return;
        }
        final TextView title = (TextView) tab.findViewById(R.id.tabText);
        if (countDown != null && countDown.isRunning()) {
            return;
        }
        lanternClient.getYinbiAuctionInfo(new LanternHttpClient.AuctionInfoCallback() {
            @Override
            public void onSuccess(final AuctionInfo info) {
                if (info == null || info.getTimeLeft() == null) {
                    return;
                }
                EventBus.getDefault().post(info);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        countDown = new AuctionCountDown(info, title);
                        countDown.start();
                    }
                });
            }
        });
    }

    private void setupTabView(final View view, final boolean useVpn, final int position) {
        final Resources res = getResources();
        final ImageView icon = (ImageView) view.findViewById(R.id.tabIcon);
        final TextView title = (TextView) view.findViewById(R.id.tabText);
        switch (position) {
            case Constants.MAIN_SWITCH_TAB:
                break;
            case Constants.LOCATION_TAB:
                icon.setImageDrawable(res.getDrawable(R.drawable.location_icon));
                title.setText(session.getServerCountryCode());
                break;
            case Constants.YINBI_AUCTION_TAB:
                icon.setImageDrawable(res.getDrawable(R.drawable.yinbi_icon_small));
                break;
            case Constants.DATA_USAGE_TAB:
                if (session.isProUser()) {
                    title.setText(session.getProTimeLeft());
                    icon.setImageDrawable(res.getDrawable(R.drawable.time_small_icon));
                } else {
                    title.setText(session.savedBandwidth());
                    icon.setImageDrawable(res.getDrawable(R.drawable.data_usage_off_icon));
                }
                break;
        }
    }

    private void setupTabs() {
        final LayoutInflater inflater = getLayoutInflater();
        final Resources res = getResources();
        final boolean useVpn = session.useVpn();

        viewPagerTab.setCustomTabView(new SmartTabLayout.TabProvider() {
            @Override
            public View createTabView(ViewGroup container, int position, PagerAdapter adapter) {
                final int layout;
                switch (position) {
                    case Constants.MAIN_SWITCH_TAB:
                        layout = R.layout.custom_tab_icon_switch;
                        break;
                    case Constants.YINBI_AUCTION_TAB:
                        layout = getTabLayout(Constants.YINBI_AUCTION_TAB);
                        break;
                    default:
                        layout = getTabLayout(position);
                        break;
                }
                View view = (View) inflater.inflate(layout, container, false);
                setupTabView(view, useVpn, position);
                return view;
            }
        });

        FragmentPagerItems pages = new FragmentPagerItems(this);
        for (int i = 0; i < Constants.NUM_HOME_TABS; i++) {
            final Bundle bundle = new Bundle();
            bundle.putInt(Constants.TAB_POSITION_KEY, i);
            pages.add(FragmentPagerItem.of(getString(R.string.no_title), TabFragment.class, bundle));
        }

        final FragmentPagerItemAdapter adapter = new FragmentPagerItemAdapter(getSupportFragmentManager(), pages);
        viewPager.setAdapter(adapter);
        viewPager.setOffscreenPageLimit(Constants.NUM_HOME_TABS);
        viewPagerTab.setViewPager(viewPager);

        viewPagerTab.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                viewPagerTab.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                final View tab = (View) viewPagerTab.getTabAt(Constants.LOCATION_TAB);
                final int height = Utils.convertDip2Pixels(BaseActivity.this, Constants.TABS_MARGIN_TOP);
                Utils.setMargins(viewPagerTab, 0, height, tab.getWidth(), 0);
            }
        });
    }

    // getTabLayout gets the layout that showed be displayed
    // for the given tab position
    private int getTabLayout(final int position) {
        final boolean useVpn = session.useVpn();
        if (position == Constants.YINBI_AUCTION_TAB &&
                session.yinbiEnabled()) {
            return R.layout.custom_tab_auction;
        }
        if (useVpn) {
            return R.layout.custom_tab_icon_on;
        } else {
            return R.layout.custom_tab_icon;
        }
    }


    public void displayStatus(final boolean useVpn) {
        if (statusSnackbar == null) {
            return;
        }

        View view = statusSnackbar.getView();
        TextView tv = (TextView) view.findViewById(com.google.android.material.R.id.snackbar_text);
        tv.setTextSize(14);
        if (useVpn) {
            // whenever we switch 'on', we want to trigger the color
            // fade for the background color animation and switch
            // our image view to use the 'on' image resource
            tv.setText(getResources().getString(R.string.lantern_on));
        } else {
            tv.setText(getResources().getString(R.string.lantern_off));
        }

        statusSnackbar.show();
    }

    protected void updateTabIcon(int pos, int iconImage) {
        final Resources r = getResources();
        final View tab = (View) viewPagerTab.getTabAt(pos);
        if (tab == null) {
            return;
        }

        ImageView icon = (ImageView) tab.findViewById(R.id.tabIcon);
        if (icon == null) {
            Logger.error(TAG, "Could not find tab icon to update");
            return;
        }
        icon.setImageDrawable(r.getDrawable(iconImage));
    }

    /**
     * updateTheme changes the default layout depending on
     * whether or not Lantern is turned on
     */
    public void updateTheme(boolean useVpn) {
        if (useVpn) {
            //colorFadeIn.start();
            viewPagerTab.setBackgroundColor(proBlueColor);
            coordinatorLayout.setBackgroundColor(proBlueColor);
            menuIcon.setImageResource(R.drawable.menu_white);
        } else {
            viewPagerTab.setBackgroundColor(customTabColor);
            coordinatorLayout.setBackgroundColor(customTabColor);
            menuIcon.setImageResource(R.drawable.menu);
        }

        for (int i = 1; i < Constants.NUM_HOME_TABS; i++) {
            final View tab = (View) viewPagerTab.getTabAt(i);
            if (tab == null) {
                break;
            }
            TextView title = (TextView) tab.findViewById(R.id.tabText);
            if (title == null) {
                continue;
            }
            title.setTextColor(useVpn ? white : black);
        }
    }

    private void updateUserData() {
        lanternClient.userData(new LanternHttpClient.ProUserCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                Logger.error(TAG, "Unable to fetch user data", throwable);
            }

            @Override
            public void onSuccess(final Response response, final ProUser user) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (user != null) {
                            final boolean yinbiEnabled = user.getYinbiEnabled();
                            if (yinbiEnabled) {
                                setYinbiAuctionInfo();
                            }
                            session.setYinbiEnabled(yinbiEnabled);
                            onUserDataUpdate(user);
                        }
                    }
                });
            }
        });
    }

    // Recreate the activity when the language changes
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void languageChanged(final Locale locale) {
        recreate();
    }

    /**
     * selectHomeTab resets the view pager to its default position
     */
    public void selectHomeTab() {
        viewPager.setCurrentItem(0);
    }

    /**
     * @return The layout id of the activity view.
     */
    protected abstract int getLayoutId();

    /**
     * onUserDataUpdate is the callback used after a successful
     * user data response
     */
    protected abstract void onUserDataUpdate(final ProUser user);

}
