package org.getlantern.lantern.event

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.filterIsInstance
import kotlinx.coroutines.launch
import org.getlantern.lantern.model.AccountInitializationStatus
import org.getlantern.lantern.model.LanternStatus
import org.getlantern.lantern.model.VpnState
import kotlin.coroutines.coroutineContext

object EventBus {
    private val _events = MutableSharedFlow<Any>()
    val events = _events.asSharedFlow()

    suspend fun publish(event: Any) {
        _events.emit(event)
    }

    suspend inline fun <reified T> subscribe(crossinline onEvent: (T) -> Unit) {
        events
            .filterIsInstance<T>()
            .collectLatest { event ->
                coroutineContext.ensureActive()
                onEvent(event)
            }
    }
}

// EventHandler is used to publish app events that subscribers can listen to from anywhere
internal object EventHandler {
    fun postAccountInitializationStatus(status: AccountInitializationStatus.Status) {
        postAppEvent(AppEvent.AccountInitializationEvent(status))
    }

    fun postStatusEvent(status: LanternStatus) {
        postAppEvent(AppEvent.StatusEvent(status))
    }

    fun postVpnStateEvent(vpnState: VpnState) {
        postAppEvent(AppEvent.VpnStateEvent(vpnState))
    }

    private fun postAppEvent(appEvent: AppEvent) {
        CoroutineScope(Dispatchers.IO).launch {
            EventBus.publish(appEvent)
        }
    }

    fun subscribeAppEvents(onEvent: (AppEvent) -> Unit) {
        CoroutineScope(Dispatchers.Main + SupervisorJob()).launch {
            EventBus.subscribe<AppEvent> { appEvent ->
                onEvent(appEvent)
            }
        }
    }
}

sealed class AppEvent {
    data class AccountInitializationEvent(
        val status: AccountInitializationStatus.Status,
    ) : AppEvent()

    data class StatusEvent(
        val status: LanternStatus,
    ) : AppEvent()

    data class VpnStateEvent(
        val vpnState: VpnState,
    ) : AppEvent()
}
