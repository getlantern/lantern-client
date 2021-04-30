package org.getlantern.lantern.activity;

import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.IBinder;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.viewpager.widget.PagerAdapter;

import com.google.android.material.snackbar.Snackbar;
import com.ogaclejapan.smarttablayout.SmartTabLayout;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItem;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItemAdapter;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItems;
import com.thefinestartist.finestwebview.FinestWebView;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.addDevice.AddDeviceActivity_;
import org.getlantern.lantern.activity.authorizeDevice.AccountRecoveryActivity;
import org.getlantern.lantern.activity.yinbi.YinbiLauncher;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.fragment.TabFragment;
import org.getlantern.lantern.model.AuctionCountDown;
import org.getlantern.lantern.model.AuctionInfo;
import org.getlantern.lantern.model.Constants;
import org.getlantern.lantern.model.DynamicViewPager;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.LanternStatus;
import org.getlantern.lantern.model.NavItem;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.model.ProUser;
import org.getlantern.lantern.model.Utils;
import org.getlantern.mobilesdk.Lantern;
import org.getlantern.mobilesdk.Logger;
import org.getlantern.mobilesdk.model.BannerAd;
import org.getlantern.mobilesdk.model.LoConf;
import org.getlantern.mobilesdk.model.Survey;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Map;

import okhttp3.Response;

public abstract class BaseActivity extends org.getlantern.mobilesdk.activity.BaseActivity {

    private static final String TAG = BaseActivity.class.getName();

    protected static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    
    private AuctionCountDown countDown;

    protected LinearLayout yinbiAdLayout;

    protected LinearLayout bulkRenewSection;

    protected SmartTabLayout viewPagerTab;

    protected DynamicViewPager viewPager;

    private TextView bulkRenew;
    protected TextView yinbiWebsite;
    protected TextView yinbiAdText;

    protected Snackbar statusSnackbar;

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

    @Override
    protected void initViews() {
        super.initViews();

        final Resources res = getResources();
        bulkRenewSection = (LinearLayout) findViewById(R.id.bulkRenewSection);

        viewPager = (DynamicViewPager) findViewById(R.id.viewPager);
        viewPagerTab = (SmartTabLayout) findViewById(R.id.viewPagerTab);

        yinbiAdLayout = (LinearLayout) findViewById(R.id.yinbiAdLayout);
        yinbiWebsite = (TextView) findViewById(R.id.yinbiWebsite);
        yinbiAdText = (TextView) findViewById(R.id.yinbiAdText);

        bulkRenew = (TextView) findViewById(R.id.bulkRenew);
        bulkRenew.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                lanternClient.openBulkProCodes(BaseActivity.this);
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        statusSnackbar = Utils.formatSnackbar(
                Snackbar.make(coordinatorLayout, getResources().getString(R.string.lantern_off), Snackbar.LENGTH_LONG));
    }

    @Override
    protected void onResume() {
        if (LanternApp.getSession().yinbiEnabled()) {
            bulkRenewSection.setVisibility(View.VISIBLE);
        } else {
            final View tab = (View)viewPagerTab.getTabAt(Constants.YINBI_AUCTION_TAB);
            if (tab != null) {
                tab.setVisibility(View.GONE);
            }
        }

        setupTabs();
        updateUserData();

        super.onResume();
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

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void lanternStarted(final LanternStatus status) {
        updateUserData();
    }

    @Override
    protected int getSideMenuIDs() {
        return LanternApp.getSession().isProUser() ? R.array.pro_side_menu_ids : R.array.free_side_menu_ids;
    }

    @Override
    protected int getSideMenuIconIDs() {
        return LanternApp.getSession().isProUser() ? R.array.pro_side_menu_icons : R.array.free_side_menu_icons;
    }

    @Override
    protected int getSideMenuOptions() {
        return LanternApp.getSession().isProUser() ? R.array.pro_side_menu_options : R.array.free_side_menu_options;
    }

    /**
     * drawerItemClicked is called whenever an item in the
     * navigation menu is clicked on
     *
     */
    protected void drawerItemClicked(final NavItem navItem, final int position) {
        Class itemClass = null;
        switch (navItem.getId()) {
            case R.id.get_lantern_pro:
                itemClass = LanternApp.getSession().plansActivity();
                break;
            case R.id.invite_friends:
                itemClass = InviteActivity_.class;
                break;
            case R.id.authorize_device_pro:
                itemClass = AccountRecoveryActivity.class;
                break;
            case R.id.pro_account:
                itemClass = ProAccountActivity_.class;
                break;
            case R.id.add_device:
                itemClass = AddDeviceActivity_.class;
                break;
            case R.id.yinbi_redemption:
                itemClass = YinbiLauncher.class;
                break;
            case R.id.desktop_option:
                itemClass = DesktopActivity_.class;
                break;
        }

        if (itemClass != null) {
            startActivity(new Intent(this, itemClass));
        }

        super.drawerItemClicked(navItem, position);
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
                if (survey.getShowPlansScreen()) {
                    startActivity(new Intent(BaseActivity.this, LanternApp.getSession().plansActivity()));
                    return;
                }

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
        };
        Logger.debug(TAG, "Showing user survey snackbar");
        Utils.showSnackbar(coordinatorLayout, survey.getMessage(), survey.getButton(),
                getResources().getColor(R.color.pink), Snackbar.LENGTH_INDEFINITE, surveyListener);
    }

    @Override
    protected void surveyClicked(final Survey survey) {
        if (survey.getShowPlansScreen()) {
            startActivity(new Intent(BaseActivity.this, LanternApp.getSession().plansActivity()));
            return;
        }

        super.surveyClicked(survey);
    }

    @Override
    public void processLoconf(final LoConf loconf) {
        super.processLoconf(loconf);

        if (loconf.getAds() != null) {
            handleBannerAd(loconf.getAds());
        }
    }

    /**
     * Check if the banner ad for our region or language is enabled and display. Returns true if ad
     * was displayed.
     *
     * @param ads the ads as defined in loconf
     */
    private boolean handleBannerAd(final Map<String, BannerAd> ads) {
        BannerAd ad = ads.get(LanternApp.getSession().getCountryCode());
        if (ad == null) {
            ad = ads.get(LanternApp.getSession().getLanguage());
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

    protected void updateStatus(boolean useVpn) {
        displayStatus(useVpn);
        super.updateStatus(useVpn);
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

    @Override
    protected void setupTabView(final View view, final boolean useVpn, final int position) {
        final Resources res = getResources();
        final ImageView icon = (ImageView) view.findViewById(R.id.tabIcon);
        final TextView title = (TextView) view.findViewById(R.id.tabText);
        switch (position) {
            case Constants.YINBI_AUCTION_TAB:
                icon.setImageDrawable(res.getDrawable(R.drawable.yinbi_icon_small));
                break;
            case Constants.DATA_USAGE_TAB:
                if (LanternApp.getSession().isProUser()) {
                    title.setText(LanternApp.getSession().getProTimeLeft());
                    icon.setImageDrawable(res.getDrawable(R.drawable.time_small_icon));
                } else {
                    title.setText(LanternApp.getSession().savedBandwidth());
                    icon.setImageDrawable(res.getDrawable(R.drawable.data_usage_off_icon));
                }
                break;
            default:
                super.setupTabView(view, useVpn, position);
        }
    }

    private void setupTabs() {
        final LayoutInflater inflater = getLayoutInflater();
        final Resources res = getResources();
        final boolean useVpn = LanternApp.getSession().useVpn();

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
        final boolean useVpn = LanternApp.getSession().useVpn();
        if (position == Constants.YINBI_AUCTION_TAB &&
                LanternApp.getSession().yinbiEnabled()) {
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
                            LanternApp.getSession().setYinbiEnabled(yinbiEnabled);
                            onUserDataUpdate(user);
                        }
                    }
                });
            }
        });
    }

    /**
     * selectHomeTab resets the view pager to its default position
     */
    public void selectHomeTab() {
        viewPager.setCurrentItem(0);
    }

    /**
     * onUserDataUpdate is the callback used after a successful
     * user data response
     */
    protected abstract void onUserDataUpdate(final ProUser user);

}
