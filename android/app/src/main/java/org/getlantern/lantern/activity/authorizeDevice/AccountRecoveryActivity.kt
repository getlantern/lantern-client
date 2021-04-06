package org.getlantern.lantern.activity.authorizeDevice

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import org.getlantern.lantern.databinding.ActivityAccountRecoveryBinding

class AccountRecoveryActivity : AppCompatActivity() {
    private lateinit var binding: ActivityAccountRecoveryBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAccountRecoveryBinding.inflate(layoutInflater)
        val view = binding.root
        setContentView(view)
        binding.linkThisDevice.setOnClickListener {
            startActivity(Intent(this, LinkDeviceActivity_::class.java))
        }
        binding.linkEmail.setOnClickListener {
            startActivity(Intent(this, LinkEmailActivity::class.java))
        }
    }
}