package org.getlantern.lantern.util

import android.content.Context
import android.os.Process
import io.sentry.SentryOptions
import io.sentry.android.core.SentryAndroid
import org.getlantern.mobilesdk.Logger
import java.io.BufferedReader
import java.io.InputStreamReader

object SentryUtil {
    private val TAG = SentryUtil::class.java.name

    /**
     * Enables enrichment of sentry crash reports with the most recent Go panic from logcat.
     * Keep in mind that Sentry only finds panics the next time that it runs after the process
     * actually panicked. So, we can safely exclude logs from our current run.
     *
     * Keep in mind also that there's no guarantee that the panic log in question belongs to our
     * specific panic, we're just picking up the most recent panic log information.
     */
    @JvmStatic
    fun enableGoPanicEnrichment(ctx: Context) {
        SentryAndroid.init(ctx) { options ->
            options.beforeSend = SentryOptions.BeforeSendCallback { event, _ ->
                // enable enrichment only for exceptions related to OS signals like SIGABRT
                if (event.exceptions?.firstOrNull()?.type?.startsWith("SIG") == true) {
                    val myPid = Process.myPid().toString()
                    val goErrorLog = StringBuilder()
                    val process = Runtime.getRuntime().exec(
                        "logcat -d -v brief"
                    )
                    BufferedReader(InputStreamReader(process.inputStream)).use { reader ->
                        reader.forEachLine { line ->
                            if (!line.contains(myPid) && line.startsWith("E/Go ")) {
                                if (line.contains("panic: ")) {
                                    // this is the first line of the most recent panic, remove old rows
                                    // from what must be prior panics
                                    goErrorLog.clear()
                                }
                                goErrorLog.appendLine(line)
                            }
                        }
                    }

                    if (goErrorLog.isNotEmpty()) {
                        Logger.debug(TAG, "Attaching latestgopanic to event")
                        event.setExtra("latestgopanic", goErrorLog.toString())
                    }
                }

                event
            }
        }
    }
}
