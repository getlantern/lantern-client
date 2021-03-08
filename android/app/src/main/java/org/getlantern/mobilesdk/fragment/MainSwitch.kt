package org.getlantern.mobilesdk.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CompoundButton
import androidx.core.content.res.ResourcesCompat
import androidx.fragment.app.Fragment
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.databinding.MainSwitchBinding
import org.getlantern.lantern.model.Stats
import org.getlantern.lantern.model.VpnState
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.activity.BaseActivity
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class MainSwitch() : Fragment() {
    private lateinit var binding: MainSwitchBinding

    private val baseActivity by lazy {
        activity as BaseActivity
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!EventBus.getDefault().isRegistered(this)) {
            Logger.debug(TAG, "Registering with EventBus")
            EventBus.getDefault().register(this);
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Logger.debug(TAG, "Unregistering with EventBus");
        EventBus.getDefault().unregister(this)
    }

    override fun onPause() {
        super.onPause()
        binding.powerLantern.setOnCheckedChangeListener(null)
    }

    override fun onResume() {
        super.onResume()
        binding.location = LanternApp.getSession().countryCode
        updateLayout(LanternApp.getSession().useVpn())
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        binding = MainSwitchBinding.inflate(inflater)
        return binding.root
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public fun onVPNStateChange(vpnState: VpnState) {
        val on = vpnState.use()
        Logger.debug(TAG, "Received boolean useVpn %1\$s", on)
        updateLayout(on)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public fun onStats(stats: Stats) {
        binding.location = stats.countryCode
    }
    
    private fun updateLayout(on: Boolean) {
        binding.on = on
        binding.powerLantern.setBackColorRes(if (on) R.color.on_color else R.color.off_color)
        binding.powerLantern.setOnCheckedChangeListener(switchListener)
        binding.powerLantern.isEnabled = true
    }

    private val switchListener = CompoundButton.OnCheckedChangeListener { _, isChecked ->
        Logger.debug(TAG, "Calling switch lantern (switch button clicked) %1\$s", isChecked)
        switchLantern(isChecked)
    }

    private fun switchLantern(isChecked: Boolean) {
        try {
            // temporary disable to prevent repeated toggling
            binding.powerLantern.isEnabled = false
            binding.powerLantern.setOnCheckedChangeListener(null)
            baseActivity.switchLantern(isChecked)
        } catch (e: Exception) {
            Logger.error(TAG, "Could not establish VPN connection: ", e)
            updateLayout(false)
        }
    }

    companion object {
        private val TAG = MainSwitch::class.java.name
    }
}