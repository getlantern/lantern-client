package org.getlantern.lantern.activity;

import android.content.Intent;
import android.content.res.Resources;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.constraintlayout.widget.Group;
import androidx.fragment.app.FragmentActivity;

import com.google.gson.JsonObject;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.MainActivity;
import org.getlantern.lantern.NavigatorKt;
import org.getlantern.lantern.R;
import org.getlantern.lantern.model.Device;
import org.getlantern.lantern.model.DeviceView;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.ProError;
import org.getlantern.lantern.util.ActivityExtKt;
import org.getlantern.mobilesdk.Logger;

import java.util.Map;

import okhttp3.FormBody;
import okhttp3.RequestBody;
import okhttp3.Response;

@EActivity(R.layout.pro_account)
public class ProAccountActivity extends FragmentActivity {

    private static final String TAG = ProAccountActivity.class.getName();
    private static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    
    @ViewById
    TextView proAccountText, emailAddress;

    @ViewById
    LinearLayout deviceList;

    @ViewById
    Group addDeviceListGroup;

    private boolean onlyOneDevice = false;

    @AfterViews
    void afterViews() {
        if (!LanternApp.getSession().deviceLinked()) {
            finish();
            return;
        }

        proAccountText.setText(LanternApp.getSession().getExpirationStr());

        updateDeviceList();

        emailAddress.setText(LanternApp.getSession().email());
    }

    @Click(R.id.renewProBtn)
    void onClickRenewProBtn(View v) {
        renewPro(v);
    }

    @Click(R.id.addDeviceBtn)
    void onClickAddDeviceBtn(View v) {
        NavigatorKt.openAddDevice(this);
    }

    public void updateDeviceList() {
        if (deviceList != null && deviceList.getChildCount() > 0)
            deviceList.removeAllViews();

        Map<String, Device> devices = LanternApp.getSession().getDevices();
        if (devices == null || devices.isEmpty()) {
            addDeviceListGroup.setVisibility(View.GONE);
            return;
        } else {
            addDeviceListGroup.setVisibility(View.VISIBLE);
        }

        if (devices.size() == 1) {
            onlyOneDevice = true;
        }

        for (Device device : devices.values()) {
            final DeviceView view = new DeviceView(this);
            String name = device.getName();
            if (name != null && name.equals(android.os.Build.MODEL)) {
                view.unauthorize.setText(getResources().getString(R.string.logout));
            }
            view.name.setText(name);
            // set the unauthorize/X button tag to the device id
            view.unauthorize.setTag(device.getId());
            view.unauthorize.setOnClickListener(this::unauthorizeDevice);
            deviceList.addView(view);
        }
    }

    private void removeDeviceView(String deviceId) {
        for (int i = 0; i < deviceList.getChildCount(); i++) {
            View v = deviceList.getChildAt(i);
            if (v instanceof DeviceView) {
                DeviceView dv = ((DeviceView)v);
                String tag = (String)dv.unauthorize.getTag();
                if (tag != null && tag.equals(deviceId)) {
                    deviceList.removeView(v);
                    return;
                }
            }
        }
    }

    private void removeDevice(final String deviceId) {
        Logger.debug(TAG, "Calling user link remove on device " + deviceId);
        final RequestBody formBody = new FormBody.Builder()
            .add("deviceID", deviceId)
            .build();
        lanternClient.post(LanternHttpClient.createProUrl("/user-link-remove"), formBody,
            new LanternHttpClient.ProCallback() {
            @Override
            public void onFailure(final Throwable throwable, final ProError error) {
                if (error != null) {
                    Logger.error(TAG, "Error removing device:" + error);
                }
                // encountered some issue removing the device; display an error
                ActivityExtKt.showErrorDialog(ProAccountActivity.this,
                        getResources().getString(R.string.unable_remove_device));
            }
            @Override
            public void onSuccess(final Response response, final JsonObject result) {
                Logger.debug(TAG, "Successfully redeemed voucher code");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        removeDeviceView(deviceId);
                        if (deviceId.equals(LanternApp.getSession().getDeviceID())) {
                            // if one of the devices we removed is the current device
                            // make sure to logout
                            logout(null);
                            return;
                        }
                        updateDeviceList();
                    }
                });
            }
        });
    }

    public void logout(View view) {
        Logger.debug(TAG, "Logout button clicked.");
        LanternApp.getSession().unlinkDevice();
        startActivity(new Intent(this, MainActivity.class));
    }

    public void renewPro(View view) {
        Logger.debug(TAG, "Renew Pro button clicked.");
        startActivity(new Intent(this, LanternApp.getSession().plansActivity()));
    }

    public void unauthorizeDevice(View view) {
        Logger.debug(TAG, "Unauthorize device button clicked.");
        final String deviceId = (String)view.getTag();
        if (deviceId == null) {
            Logger.error(TAG, "Error trying to get tag for device item; cannot unauthorize device");
            return;
        }

        if (onlyOneDevice) {
            Logger.debug(TAG, "Only one device found. Not letting user unauthorize it");
            Resources res = getResources();

            ActivityExtKt.showAlertDialog(this, res.getString(R.string.only_one_device),
                    res.getString(R.string.sorry_cannot_remove));
            return;
        }

        ActivityExtKt.showAlertDialog(
            this,
            null,
            getString(R.string.unauthorize_confirmation),
            null,
            () -> removeDevice(deviceId),
            getString(R.string.yes),
            false,
            getString(R.string.no)
            );
    }
}
