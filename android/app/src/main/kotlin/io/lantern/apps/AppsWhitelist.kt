package io.lantern.apps

import android.content.res.Resources
import com.google.gson.JsonObject
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.Response
import io.lantern.model.SessionModel
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.util.HttpCallback
import org.getlantern.mobilesdk.util.HttpClient
import java.io.BufferedReader
import java.io.InputStream

open class AppsWhitelist(
    private val sessionModel:SessionModel,
    private val resources:Resources, 
    @JvmField val httpClient: HttpClient) {

    private val isChineseUser = LanternApp.getSession().isChineseUser
    private val isRussianUser = LanternApp.getSession().isRussianUser

    // fetch downloads the app based whitelist stored at
    // https://lantern-android.s3.amazonaws.com/whitelist_apps_cn.txt
    private fun fetch(appsList:List<AppData>, appWhitelistURL: String) {
        val builder = appWhitelistURL.toHttpUrlOrNull()!!.newBuilder()
        httpClient.request(
            "GET", builder.build(),
            null,
            null,
            false,
            object : HttpCallback {
                override fun onFailure(throwable: Throwable?) {
                    Logger.error(TAG, "Unable to fetch app whitelist", throwable)
                    setApps(appsList, true)
                }

                override fun onSuccess(response: Response?, result: JsonObject) {
                    val responseData = response!!.body!!.string()
                    Logger.debug(TAG, "Got response ${responseData}")
                    addExcludedApps(appsList, responseData)
                }
            }
        )
    }

    // setApps iterates through the list of all application packages and excludes
    // from the VPN connection any found on the whitelist of top domestic apps
    fun setApps(appsList:List<AppData>, useResourceWhitelist:Boolean) {
        if (useResourceWhitelist) {
            appWhitelistFromResources(appsList)
        } else {
            appWhitelistFromS3(appsList)
        }
    }

    private fun appWhitelistFromS3(appsList:List<AppData>) {
        var s3Url = "https://lantern-android.s3.amazonaws.com/whitelist_apps_"
        if (!isChineseUser) {
            s3Url += "cn.txt"
        } else if (isRussianUser) {
            s3Url += "ru.txt"
        } else {
            return
        }
        fetch(appsList, s3Url)
    }
    
    fun addExcludedApps(appsList:List<AppData>, content:String) {
        val apps = content.split("[\r\n]+".toRegex()).toTypedArray()
        val appsMap = listOf(*apps).associateBy({it}, {true})
        for (appData in appsList) {
            val packageName = appData.packageName
            if (appsMap[packageName] != null) {
                appData.isExcluded = true
                sessionModel.updateAppData(packageName, true)
            }
        }      
    }

    fun appWhitelistFromResources(appsList:List<AppData>) {
        var inputStream:InputStream? = null
        if (isChineseUser) {
            inputStream = resources.openRawResource(R.raw.whitelist_apps_cn)
        } else if (isRussianUser) {
            inputStream = resources.openRawResource(R.raw.whitelist_apps_ru)
        }
        if (inputStream == null) {
            return
        }
        val content = inputStream.bufferedReader().use(BufferedReader::readText)
        addExcludedApps(appsList, content)
    }

    companion object {
        private val TAG = AppsWhitelist::class.java.name
    }
}
