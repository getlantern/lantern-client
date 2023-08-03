package org.getlantern.lantern.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import kotlinx.coroutines.*
import org.getlantern.lantern.Actions
import org.getlantern.lantern.util.broadcastReceiver
import org.getlantern.lantern.util.runOnMainDispatcher
import org.getlantern.mobilesdk.Logger

class ServiceManager {

    companion object {
        private val TAG = ServiceManager::class.java.simpleName
    }

    class Data internal constructor(private val service: Runner) {
        var state = ConnectionState.Disconnected
        var connectingJob: Job? = null
        // var notification: Notification? = null

        val stopReceiver = broadcastReceiver { ctx, intent ->
            service.stopRunner()
        }

        fun changeState(s: ConnectionState) {
            state = s
        }

        var closeReceiverRegistered = false
    }

    interface Runner {
        val data: Data
        fun killProcesses()
        suspend fun startProcesses()

        fun startRunner() {
            this as Context
            if (Build.VERSION.SDK_INT >= 26) {
                startForegroundService(Intent(this, javaClass))
            } else {
                startService(Intent(this, javaClass))
            }
        }

        fun stopRunner(restart: Boolean = false) {
            if (data.state == ConnectionState.Disconnecting) return
            this as Service
            Logger.d(TAG, "Received stop service request")
            data.changeState(ConnectionState.Disconnecting)
            runOnMainDispatcher {
                data.connectingJob?.cancelAndJoin()
                coroutineScope {
                    killProcesses()
                    val data = data
                    data.connectingJob?.cancelAndJoin()
                    if (data.closeReceiverRegistered) {
                        unregisterReceiver(data.stopReceiver)
                        data.closeReceiverRegistered = false
                    }
                }

                data.changeState(ConnectionState.Disconnected)
                if (restart) {
                    startRunner()
                } else {
                    stopSelf()
                }
            }
        }

        fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
            val data = data
            if (data.state != ConnectionState.Disconnected) return Service.START_NOT_STICKY
            this as Context
            if (!data.closeReceiverRegistered) {
                registerReceiver(
                    data.stopReceiver,
                    IntentFilter().apply {
                        addAction(Actions.STOP_SERVICE)
                    },
                )
                data.closeReceiverRegistered = true
            }

            data.changeState(ConnectionState.Connecting)
            runOnMainDispatcher {
                try {
                    startProcesses()
                    data.changeState(ConnectionState.Connected)
                    // LanternApp.notifications.vpnConnected()
                } catch (exc: Throwable) {
                } finally {
                    data.connectingJob = null
                }
            }
            return Service.START_NOT_STICKY
        }
    }
}
