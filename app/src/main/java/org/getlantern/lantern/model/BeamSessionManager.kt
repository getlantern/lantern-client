package org.getlantern.lantern.model

import android.content.Context
import org.getlantern.mobilesdk.model.SessionManager

class BeamSessionManager(context: Context) : SessionManager(context) {
    override fun isProUser(): Boolean {
        return false;
    }

    override fun currency(): String? {
        return "";
    }

    override fun code(): String? {
        return ""
    }

    override fun setCode(referral: String?) {
    }

    override fun provider(): String? {
        return ""
    }
}