package org.getlantern.lantern.plausible

import android.content.Context
import org.getlantern.mobilesdk.Logger
import java.util.concurrent.atomic.AtomicReference

// Singleton for sending events to Plausible.
object Plausible {
    private val client: AtomicReference<PlausibleClient?> = AtomicReference(null)
    private val config: AtomicReference<PlausibleConfig?> = AtomicReference(null)

    fun init(context: Context) {
        val config = AndroidResourcePlausibleConfig(context)
        val client = NetworkFirstPlausibleClient(config)
        init(client, config)
    }

    internal fun init(client: PlausibleClient, config: PlausibleConfig) {
        this.client.set(client)
        this.config.set(config)
    }

    // Enable or disable event sending
    @Suppress("unused")
    fun enable(enable: Boolean) {
        config.get()
            ?.let {
                it.enable = enable
            }
            ?: Logger.d(
                "Plausible",
                "Ignoring call to enable(). Did you forget to call Plausible.init()?"
            )
    }

    /**
     * The raw value of User-Agent is used to calculate the user_id which identifies a unique
     * visitor in Plausible.
     * User-Agent is also used to populate the Devices report in your
     * Plausible dashboard. The device data is derived from the open source database
     * device-detector. If your User-Agent is not showing up in your dashboard, it's probably
     * because it is not recognized as one in the device-detector database.
     */
    @Suppress("unused")
    fun setUserAgent(userAgent: String) {
        config.get()
            ?.let {
                it.userAgent = userAgent
            }
            ?: Logger.d(
                "Plausible",
                "Ignoring call to setUserAgent(). Did you forget to call Plausible.init()?"
            )
    }

    /**
     * Send a `pageview` event.
     *
     * @param url URL of the page where the event was triggered. If the URL contains UTM parameters,
     * they will be extracted and stored.
     * The URL parameter will feel strange in a mobile app but you can manufacture something that looks
     * like a web URL. If you name your mobile app screens like page URLs, Plausible will know how to
     * handle it. So for example, on your login screen you could send something like
     * `app://localhost/login`. The pathname (/login) is what will be shown as the page value in the
     * Plausible dashboard.
     * @param referrer Referrer for this event.
     * Plausible uses the open source referer-parser database to parse referrers and assign these
     */
    fun pageView(
        url: String,
        referrer: String = "",
        props: Map<String, Any?>? = null
    ) = event(
        name = "pageview",
        url = url,
        referrer = referrer,
        props = props
    )

    /**
     * Send a custom event. To send a `pageview` event, consider using [pageView] instead.
     *
     * @param name Name of the event. Can specify `pageview` which is a special type of event in
     * Plausible. All other names will be treated as custom events.
     * @param url URL of the page where the event was triggered. If the URL contains UTM parameters,
     * they will be extracted and stored.
     * The URL parameter will feel strange in a mobile app but you can manufacture something that looks
     * like a web URL. If you name your mobile app screens like page URLs, Plausible will know how to
     * handle it. So for example, on your login screen you could send something like
     * `app://localhost/login`. The pathname (/login) is what will be shown as the page value in the
     * Plausible dashboard.
     * @param referrer Referrer for this event.
     * Plausible uses the open source referer-parser database to parse referrers and assign these
     * source categories.
     */
    @Suppress("MemberVisibilityCanBePrivate")
    fun event(
        name: String,
        url: String = "",
        referrer: String = "",
        props: Map<String, Any?>? = null
    ) {
        client.get()
            ?.let { client ->
                config.get()
                    ?.let { config ->
                        client.event(config.domain, name, url, referrer, config.screenWidth, props)
                    }
                    ?: Logger.d(
                        "Plausible",
                        "Ignoring call to event(). Did you forget to call Plausible.init()?"
                    )
            }
            ?: Logger.d(
                "Plausible",
                "Ignoring call to event(). Did you forget to call Plausible.init()?"
            )
    }
}