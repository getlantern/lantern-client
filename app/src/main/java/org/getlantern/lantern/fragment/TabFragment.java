package org.getlantern.lantern.fragment;

import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.kyleduo.switchbutton.SwitchButton;
import com.ogaclejapan.smarttablayout.utils.v4.FragmentPagerItem;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.BaseActivity;
import org.getlantern.lantern.model.AuctionCountDown;
import org.getlantern.lantern.model.AuctionInfo;
import org.getlantern.lantern.model.Bandwidth;
import org.getlantern.lantern.model.Constants;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.Stats;
import org.getlantern.lantern.model.UserStatus;
import org.getlantern.lantern.model.Utils;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.lantern.vpn.LanternVpnService;
import org.getlantern.mobilesdk.Logger;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.HashSet;

public class TabFragment extends Fragment {

  private static final String TAG = TabFragment.class.getName();

  private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();

  // Always operated from main thread as one subscriber of EventBus.
  private HashSet<Long> notifiedBWPercents = new HashSet<>();

  private CompoundButton.OnCheckedChangeListener switchListener;

  private int position;

  private AuctionCountDown countDown;

  private ProgressBar progressBar;

  private SwitchButton powerLantern;

  private RelativeLayout mainSwitchLayout;
  private ViewGroup tabLayout;

  private ImageView closeBtn, tabIcon;

  private TextView currentLoc, headerText, subtitle, tabText, tokensReleased, totalReleased, timeLeft, timeLeftGiveaway,
      upgradeNow, underSwitchText;

  final static int[] layouts = new int[] { R.layout.main_switch, R.layout.current_location, R.layout.yinbi_auction_info,
      R.layout.data_usage };

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    final Bundle bundle = this.getArguments();
    if (bundle != null) {
      this.position = bundle.getInt(Constants.TAB_POSITION_KEY, 0);
    }

    if (!EventBus.getDefault().isRegistered(this)) {
      EventBus.getDefault().register(this);
    }
  }

  @Override
  public void onResume() {
    super.onResume();
    if (LanternApp.getSession().useVpn() && !Utils.isServiceRunning(getActivity(), LanternVpnService.class)) {
      Logger.d(TAG, "LanternVpnService isn't running, clearing VPN preference");
      LanternApp.getSession().clearVpnPreference();
    }
    updateLayout(getResources(), LanternApp.getSession().useVpn());
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    EventBus.getDefault().unregister(this);
  }

  private void configureSwitchView(View view) {
    powerLantern = (SwitchButton) view.findViewById(R.id.powerLantern);
    mainSwitchLayout = (RelativeLayout) view.findViewById(R.id.mainSwitchLayout);
    underSwitchText = (TextView) view.findViewById(R.id.underSwitchText);

    switchListener = new CompoundButton.OnCheckedChangeListener() {
      public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        Logger.debug(TAG, "Calling switch lantern (switch button clicked)");
        switchLantern(isChecked);
      }
    };
    powerLantern.setOnCheckedChangeListener(switchListener);
  }

  private void configureTabViews(View view) {
    // common text among tabs that changes color depending on if
    // there's an active VPN connection or not
    tabLayout = (LinearLayout) view.findViewById(R.id.tabLayout);
    closeBtn = (ImageView) view.findViewById(R.id.close);
    tabIcon = (ImageView) view.findViewById(R.id.tabIcon);
    headerText = (TextView) view.findViewById(R.id.headerText);
    subtitle = (TextView) view.findViewById(R.id.subtitle);
    tabText = (TextView) view.findViewById(R.id.tabText);
    timeLeft = (TextView) view.findViewById(R.id.timeLeft);
    timeLeftGiveaway = (TextView) view.findViewById(R.id.timeLeftGiveaway);
    tokensReleased = (TextView) view.findViewById(R.id.tokensReleased);
    totalReleased = (TextView) view.findViewById(R.id.totalReleased);
  }

  @Override
  public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
      @Nullable Bundle savedInstanceState) {
    int position = FragmentPagerItem.getPosition(getArguments());

    if (position == 3 && LanternApp.getSession().isProUser()) {
      return inflater.inflate(R.layout.account_time_left, container, false);
    }

    return inflater.inflate(layouts[position], container, false);
  }

  private void updateSwitchLayout(final boolean on) {
    final Resources r = getResources();

    powerLantern.setBackColorRes(on ? R.color.on_color : R.color.black);
    powerLantern.setOnCheckedChangeListener(null);
    powerLantern.setChecked(on);
    powerLantern.setOnCheckedChangeListener(switchListener);

    mainSwitchLayout.setBackgroundColor(r.getColor(on ? R.color.pro_blue_color : R.color.custom_tab_icon));
    underSwitchText.setText(on ? r.getString(R.string.lantern_on_text) : r.getString(R.string.turn_on_lantern));
    underSwitchText.setTextColor(r.getColor(on ? R.color.accent_white : R.color.black));
  }

  private void switchLantern(final boolean isChecked) {
    try {
      // temporary disable to prevent repeated toggling
      powerLantern.setEnabled(false);
      ((BaseActivity) getActivity()).switchLantern(isChecked);
      new Handler(getActivity().getMainLooper()).postDelayed(new Runnable() {
        @Override
        public void run() {
          // re-enable after 2000ms
          powerLantern.setEnabled(true);
        }
      }, 2000);
    } catch (Exception e) {
      Logger.error(TAG, "Could not establish VPN connection: ", e);
      powerLantern.setOnCheckedChangeListener(null);
      powerLantern.setChecked(false);
      powerLantern.setOnCheckedChangeListener(switchListener);
    }
  }

  private void setBandwidthUpdate(final Bandwidth update) {
    if (position != Constants.DATA_USAGE_TAB) {
      // do nothing data-related if its a pro user
      return;
    }

    tabText.setText(
        String.format(getResources().getString(R.string.data_usage_desc), update.getUsed(), update.getAllowed()));

    if (tabText.getVisibility() == View.INVISIBLE) {
      tabText.setVisibility(View.VISIBLE);
    }

    String dataFmt = getResources().getString(R.string.data_remaining);
    final long percent = update.getPercent();
    String amount = String.format("%s%%", percent);
    if (headerText != null) {
      headerText.setText(amount);
    }
    if (progressBar != null) {
      progressBar.setProgress((int) percent);
    }
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onEventMainThread(final UserStatus status) {
    if (status == null || position != Constants.DATA_USAGE_TAB || !LanternApp.getSession().isProUser()) {
      return;
    }

    tabText.setText(String.format(getResources().getString(R.string.account_left_desc, LanternApp.getSession().numProMonths())));

    headerText.setText(status.monthsLeft());
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onEventMainThread(Bandwidth update) {
    if (update != null && !LanternApp.getSession().isProUser()) {
      // ignore data usage updates if the user is Pro
      Logger.debug(TAG, "Received bandwidth data update");
      setBandwidthUpdate(update);
      sendBandwidthNotification(update);
    }
  }

  private void sendBandwidthNotification(final Bandwidth update) {
    final long percent = update.getPercent();
    final long remaining = update.getRemaining();
    String s = getNotificationText(percent, remaining);
    if (s != null) {
      Intent intent = new Intent();
      intent.setAction("org.getlantern.lantern.intent.DATA_USAGE");
      intent.putExtra("text", s);
      getActivity().sendBroadcast(intent);
      notifiedBWPercents.add(percent);
    }
  }

  private String getNotificationText(long percent, long remaining) {
    if (percent == 0 && remaining == 0) {
      // error condition, see flashlight/android.go
      return null;
    }
    // show notification only once for each percent hit.
    if (notifiedBWPercents.contains(percent)) {
      return null;
    }
    Resources res = getResources();
    switch ((int) percent) {
    case 50:
    case 80:
      return String.format(res.getString(R.string.data_cap_percent), percent);
    case 100:
      return res.getString(R.string.data_cap);
    case 0:
      return res.getString(R.string.data_cap_reset);
    default:
      return null;
    }
  }

  private void setProxyLocationHeader(final Stats st) {

    final String countryCode = (st != null) ? st.getCountryCode() : LanternApp.getSession().getServerCountryCode();
    if (headerText != null && !countryCode.equals("")) {
      Logger.debug(TAG, "Setting location tab country to " + countryCode);
      headerText.setText(countryCode);
    }
  }

  private void updateLocation(final Stats st) {
    setProxyLocationHeader(st);

    if (LanternApp.getSession().useVpn() && currentLoc != null) {
      final String current = String.format("%s, %s", st.getCity(), st.getCountry());
      Logger.debug(TAG, "Setting current server location to " + current);

      currentLoc.setText(String.format("%s %s", getResources().getString(R.string.current_location), current));
    }
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onEventMainThread(final Stats st) {
    if (currentLoc != null) {
      updateLocation(st);
    }
  }

  private void updateIconsBasedOnState(final Resources r, final boolean on) {

    if (position != Constants.DATA_USAGE_TAB) {
      return;
    }

    final Integer tabIconDrawable;
    if (LanternApp.getSession().isProUser()) {
      tabIconDrawable = R.drawable.time_icon;
    } else {
      tabIconDrawable = on ? R.drawable.data_usage_on : R.drawable.data_usage_off;
    }

    tabIcon.setImageDrawable(r.getDrawable(tabIconDrawable.intValue()));
  }

  private void updateTabLayout(final Resources r, final boolean on) {
    final int sdk = android.os.Build.VERSION.SDK_INT;
    final int bgDrawable = on ? R.drawable.iconframe_on : R.drawable.iconframe;
    int pL = tabLayout.getPaddingLeft();
    int pR = tabLayout.getPaddingRight();

    if (sdk < android.os.Build.VERSION_CODES.JELLY_BEAN) {
      tabLayout.setBackgroundDrawable(getResources().getDrawable(bgDrawable));
    } else {
      tabLayout.setBackground(getResources().getDrawable(bgDrawable));
    }
    tabLayout.setPadding(pL, 0, pR, 0);
  }

  private void updateTabText(final boolean on) {
    final TextView[] textToUpdate = { currentLoc, headerText, subtitle, tabText, timeLeft, timeLeftGiveaway,
        tokensReleased, totalReleased, upgradeNow };

    for (int i = 0; i < textToUpdate.length; i++) {
      final TextView view = textToUpdate[i];
      if (view != null) {
        final int color = on ? R.color.accent_white : R.color.black;
        view.setTextColor(getResources().getColor(color));
      }
    }
  }

  private void updateLayout(final Resources r, final boolean on) {
    if (tabLayout == null) {
      updateSwitchLayout(on);
      ((BaseActivity) getActivity()).updateTheme(on);
      return;
    }

    closeBtn.setImageResource(on ? R.drawable.close_on : R.drawable.close_off);

    updateTabLayout(r, on);
    updateIconsBasedOnState(r, on);
    updateTabText(on);

    if (currentLoc == null) {
      return;
    }

    if (on) {
      final String current = String.format("%s, %s", LanternApp.getSession().getServerCity(), LanternApp.getSession().getServerCountry());

      currentLoc.setText(String.format("%s %s", r.getString(R.string.current_location), current));
    } else {
      currentLoc
          .setText(String.format("%s %s", r.getString(R.string.current_location), r.getString(R.string.disconnected)));
    }
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onEventMainThread(VpnState useVpn) {
    Logger.debug(TAG, "Received boolean useVpn " + useVpn.use());

    final boolean on = useVpn.use();
    final Resources r = getResources();

    updateLayout(r, on);
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  public void onYinbiAuctionInfo(final AuctionInfo info) {
    if (position != Constants.YINBI_AUCTION_TAB) {
      return;
    }

    final View view = getView();
    if (view != null) {
      updateYinbiAuctionInfo(info, view);
    }
  }

  private void configureTabView(View view) {
    // common text among tabs that changes color depending on if
    // there's an active VPN connection or not
    tabLayout = (LinearLayout) view.findViewById(R.id.tabLayout);
    closeBtn = (ImageView) view.findViewById(R.id.close);
    tabIcon = (ImageView) view.findViewById(R.id.tabIcon);
    headerText = (TextView) view.findViewById(R.id.headerText);
    subtitle = (TextView) view.findViewById(R.id.subtitle);
    tabText = (TextView) view.findViewById(R.id.tabText);
    timeLeft = (TextView) view.findViewById(R.id.timeLeft);
    timeLeftGiveaway = (TextView) view.findViewById(R.id.timeLeftGiveaway);
    tokensReleased = (TextView) view.findViewById(R.id.tokensReleased);
    totalReleased = (TextView) view.findViewById(R.id.totalReleased);
  }

  /**
   * updateTokensReleasedText updates the auction card to display the number
   * of tokens being released
   */
  private void updateTokensReleasedText(final View view, final AuctionInfo info) {
    final TextView timeLeft = (TextView) view.findViewById(R.id.timeLeft);
    final TextView tokensReleased = (TextView) view.findViewById(R.id.tokensReleased);
    final Resources res = getResources();
    final String fmt = res.getString(R.string.yinbi_released_today);
    final String text = String.format(fmt, info.getTokensReleased());

    tokensReleased.setText(text);
  }

  /**
   * updateYinbiAuctionInfo fetches the latest auction info from the Yinbi
   * server; it updates view to show the number of tokens being released
   * and the amount of time remaining until the auction runs
   */
  private void updateYinbiAuctionInfo(final AuctionInfo info, final View view) {
    final TextView timeLeft = (TextView) view.findViewById(R.id.timeLeft);
    if (countDown != null && countDown.isRunning()) {
      countDown.cancel();
    }
    updateTokensReleasedText(view, info);
    countDown = new AuctionCountDown(info, timeLeft);
    countDown.start();
  }

  @Override
  public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);

    if (position == Constants.MAIN_SWITCH_TAB) {
      configureSwitchView(view);
    } else {
      configureTabViews(view);
    }

    final Resources res = getResources();
    switch (position) {
    case Constants.LOCATION_TAB:
      setProxyLocationHeader(null);
      currentLoc = (TextView) view.findViewById(R.id.currentLocation);
      currentLoc.setText(
          String.format("%s %s", res.getString(R.string.current_location), res.getString(R.string.disconnected)));
      break;
    case Constants.DATA_USAGE_TAB:
      upgradeNow = (TextView) view.findViewById(R.id.upgradeNow);
      if (LanternApp.getSession().isProUser()) {
        tabText.setText(String.format(res.getString(R.string.account_left_desc, LanternApp.getSession().numProMonths())));
        headerText.setText(LanternApp.getSession().getProTimeLeft());
      } else {
        progressBar = (ProgressBar) view.findViewById(R.id.dataProgressBar);
      }
      break;
    default:
      break;
    }

    updateLayout(getResources(), LanternApp.getSession().useVpn());
  }

}
