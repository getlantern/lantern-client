/* See https://android.googlesource.com/platform/development/+/master/samples/ToyVpn/src/com/example/android/toyvpn/ToyVpnService.java
 * for an example of a VpnService implementation.
 */
package org.getlantern.lantern.vpn;

import internalsdk.Internalsdk;
import internalsdk.SocketProtector;

import android.annotation.TargetApi;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.net.VpnService;
import android.os.Build;
import android.os.IBinder;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.MainActivity;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.VpnState;
import org.getlantern.lantern.service.LanternService_;
import org.getlantern.lantern.service.ServiceHelper;
import org.getlantern.mobilesdk.Logger;
import org.greenrobot.eventbus.EventBus;

@TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
public class LanternVpnService extends VpnService implements Runnable {
    public static final String ACTION_CONNECT = "org.getlantern.lantern.vpn.START";
    public static final String ACTION_DISCONNECT = "org.getlantern.lantern.vpn.STOP";

    private static final String TAG = "VpnService";

    private Provider mProvider = null;

    private PendingIntent mConfigureIntent;

    private ServiceHelper helper = new ServiceHelper(this, R.drawable.status_connected, R.string.service_connected);

    private final ServiceConnection lanternServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceDisconnected(ComponentName name) {
            Logger.e(TAG, "LanternService disconnected, disconnecting VPN");
            stop();
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
        }
    };

    private synchronized Provider getOrInitProvider() {
        Logger.d(TAG, "getOrInitProvider()");
        if (mProvider == null) {
            Logger.d(TAG, "Using Go tun2socks");
            mProvider = new GoTun2SocksProvider();
        }
        return mProvider;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Logger.d(TAG, "VpnService created");
        mConfigureIntent = PendingIntent.getActivity(this, 0, new Intent(this, MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT);
        bindService(new Intent(this, LanternService_.class), lanternServiceConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    public void onDestroy() {
        Logger.d(TAG, "destroyed");
        doStop();
        super.onDestroy();
        unbindService(lanternServiceConnection);
        helper.onDestroy();
    }

    @Override
    public void onRevoke() {
        Logger.d(TAG, "revoked");
        stop();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Logger.d(TAG, "LanternVpnService: onStartCommand()");

        if (intent != null && ACTION_DISCONNECT.equals(intent.getAction())) {
            stop();
            return START_NOT_STICKY;
        } else {
            connect();
            return START_STICKY;
        }
    }

    private void connect() {
        Logger.d(TAG, "connect");
        helper.makeForeground();
        new Thread(this, "VpnService").start();
    }

    @Override
    public void run() {
        try {
            Logger.d(TAG, "Loading Lantern library");
            Internalsdk.protectConnections(new SocketProtector() {
                // Protect is used to exclude a socket specified by fileDescriptor
                // from the VPN connection. Once protected, the underlying connection
                // is bound to the VPN device and won't be forwarded
                @Override
                public void protectConn(long fileDescriptor) throws Exception {
                    if (!protect((int) fileDescriptor)) {
                        throw new Exception("protect socket failed");
                    }
                }

                public String dnsServerIP() {
                    return LanternApp.getSession().getDNSServer();
                }
            });

            getOrInitProvider().run(this, new Builder(), LanternApp.getSession().getSOCKS5Addr(), LanternApp.getSession().getDNSGrabAddr());
        } catch (Exception e) {
            e.printStackTrace();
            Logger.error(TAG, "Error running VPN", e);
        } finally {
            Logger.debug(TAG, "Lantern terminated.");
            stop();
        }
    }

    private void stop() {
        doStop();
        stopSelf();
        Logger.d(TAG, "done stopping");
    }

    private void doStop() {
        Logger.d(TAG, "stop");
        try {
            Logger.d(TAG, "getting provider");
            Provider provider = getOrInitProvider();
            Logger.d(TAG, "stopping provider");
            provider.stop();
        } catch (Throwable t) {
            Logger.e(TAG, "error stopping provider", t);
        }
        try {
            Logger.d(TAG, "updating vpn preference");
            LanternApp.getSession().updateVpnPreference(false);
        } catch (Throwable t) {
            Logger.e(TAG, "error updating vpn preference", t);
        }
        try {
            Logger.d(TAG, "posting updated vpnstate");
            EventBus.getDefault().post(new VpnState(false));
        } catch (Throwable t) {
            Logger.e(TAG, "error posting updated vpnstate", t);
        }
        try {
            Logger.d(TAG, "removing overrides");
            Internalsdk.removeOverrides();
        } catch (Throwable t) {
            Logger.e(TAG, "error removing overrides", t);
        }
    }
}