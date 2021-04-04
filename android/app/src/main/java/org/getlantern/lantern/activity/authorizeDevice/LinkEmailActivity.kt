package org.getlantern.lantern.activity.authorizeDevice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import org.getlantern.lantern.databinding.ActivityLinkEmailBinding

class LinkEmailActivity: AppCompatActivity() {
    private lateinit var binding: ActivityLinkEmailBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityLinkEmailBinding.inflate(layoutInflater)
        val view = binding.root
        setContentView(view)
    }
}