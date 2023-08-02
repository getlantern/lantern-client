package org.getlantern.lantern.service

import android.content.Intent

class BaseService {
    interface Callback {
        fun onStateChanged(state: ConnectionState)
    }

    interface Service {
        fun onStart(intent: Intent?) {
            /*val manager = this@BaseService
            if (manager.state != ConnectionState.Disconnected) return

            manager.changeState(ConnectionState.Connected)*/
        }
    }
}
