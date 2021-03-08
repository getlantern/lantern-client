package org.getlantern.mobilesdk.activity

import android.os.Bundle
import android.text.Html
import androidx.fragment.app.FragmentActivity
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.databinding.SettingsBinding
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.getStringWithAppName

open class SettingsActivity() : FragmentActivity() {
    private lateinit var binding: SettingsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = SettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        if (LanternApp.getSession().proxyAll()) {
            binding.proxyAll.setCheckedImmediatelyNoEvent(true)
            binding.proxyAll.setBackColorRes(R.color.setting_on)
        }
        setDescText()
        binding.proxyAll.setOnCheckedChangeListener { _, isChecked -> proxyAll(isChecked) }
    }

    private fun setDescText() {
        binding.proxyAllDesc.text = Html.fromHtml(String.format(
                proxyAllDescFmt, getString(R.string.proxy_all_on_header),
                getStringWithAppName(R.string.proxy_all_on),
                getString(R.string.proxy_all_off_header),
                getStringWithAppName(R.string.proxy_all_off)))
    }

    fun proxyAll(on: Boolean) {
        // store updated user preference
        LanternApp.getSession().setProxyAll(on)
        binding.proxyAll.setBackColorRes(if (on) R.color.setting_on else R.color.setting_off)
        Logger.debug(TAG, "Proxy all setting is $on")
    }

    companion object {
        private val TAG = SettingsActivity::class.java.name
        private const val proxyAllDescFmt = "&#8226; %s<br />%s<br />&#8226; %s<br />%s"
    }
}