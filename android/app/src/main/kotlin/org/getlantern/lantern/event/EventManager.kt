package org.getlantern.lantern.event

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.util.EnumMap
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference

class EventManager(
    private val name: String,
    flutterEngine: FlutterEngine? = null
) : EventChannel.StreamHandler {

    private val activeSubscribers: EnumMap<Event, ConcurrentSkipListSet<Int>> =
        EnumMap(Event::class.java)

    private val activeSink = AtomicReference<EventChannel.EventSink?>()

    private val handler = Handler(Looper.getMainLooper()) // a handler for the main thread

    init {
        flutterEngine?.let {
            EventChannel(
                flutterEngine.dartExecutor,
                name
            ).setStreamHandler(this)
        }
    }

    fun onNewEvent(event: Event, params: HashMap<String, Any?>) {
        handler.post {
            synchronized(this@EventManager) {
                params["eventName"] = event.name

                // notify subscribers who listens for only 1 specific event
                var subscribers = activeSubscribers[event]
                subscribers?.forEach { subscriberID ->
                    params["subscriberID"] = subscriberID
                    activeSink.get()?.success(params)
                }

                // notify subscribers who listens for all events
                subscribers = activeSubscribers[Event.All]
                subscribers?.forEach { subscriberID ->
                    params["subscriberID"] = subscriberID
                    activeSink.get()?.success(params)
                }
            }
        }
    }

    @Synchronized
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        activeSink.set(events)
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as Int
        val eventName = args["eventName"] as String
        val event = Event.valueOf(eventName)

        val subscribers = activeSubscribers[event] ?: ConcurrentSkipListSet<Int>()
        subscribers.add(subscriberID)
        activeSubscribers[event] = subscribers
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == null) {
            return
        }
        val args = arguments as Map<String, Any>
        val subscriberID = args["subscriberID"] as Int
        for (entry in activeSubscribers.entries) {
            entry.value.remove(subscriberID)
        }
    }
}
