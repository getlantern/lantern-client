package org.getlantern.lantern.activity

import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.text.Html
import android.widget.ProgressBar
import android.widget.TextView
import androidx.core.app.ActivityCompat
import androidx.core.content.FileProvider
import internalsdk.Internalsdk
import internalsdk.Updater
import kotlinx.coroutines.*
import kotlinx.coroutines.Dispatchers.IO
import org.androidannotations.annotations.AfterViews
import org.androidannotations.annotations.Click
import org.androidannotations.annotations.EActivity
import org.androidannotations.annotations.ViewById
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.R
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.util.ApkSignatureVerifier
import org.getlantern.lantern.util.SignatureVerificationException
import org.getlantern.lantern.util.SystemInfoHelper
import org.getlantern.mobilesdk.Logger
import java.io.File

@EActivity(R.layout.activity_updater)
open class UpdateActivity : BaseFragmentActivity(), ActivityCompat.OnRequestPermissionsResultCallback, DialogInterface.OnClickListener {

    companion object {
        private val TAG = UpdateActivity::class.java.name
        private const val REQUEST_CODE_PERMISSION = 1252
    }

    @ViewById
    @JvmField
    protected var updateAvailable: TextView? = null

    @ViewById
    @JvmField
    protected var progressBar: ProgressBar? = null

    @ViewById
    @JvmField
    protected var progressBarMessage: TextView? = null

    @AfterViews
    fun afterViews() {
        val appName: String = getString(R.string.app_name)
        val message: String = String.format(getString(R.string.update_available), appName)
        updateAvailable!!.text = message
        progressBarMessage!!.text = String.format(getString(R.string.updating_lantern), appName)
    }

    @Click(R.id.installUpdate)
    fun installUpdateClicked() {
        Logger.debug(TAG, "Install Update clicked")
    }

    private fun publishProgress(percent: Long) {
        progressBar!!.progress = percent.toInt()
    }

    private suspend fun downloadUpdate(apkDir: File, apkPath: File): Boolean {
        try {
            val updater = Updater { percent: Long -> publishProgress(percent) }
            apkDir.mkdirs()

            Internalsdk.downloadUpdate(
                SystemInfoHelper.model(),
                SystemInfoHelper.hardware(),
                SystemInfoHelper.sdkVersion().toLong(),
                intent.getStringExtra("updateUrl").toString(),
                apkPath.getAbsolutePath(),
                updater,
            )
            return true
        } catch (e: Exception) {
            Logger.debug(TAG, "Error downloading update: " + e.message)
        }
        return false
    }

    private fun displayTamperedApk(context: Context) {
        Utils.showAlertDialog(
            this,
            context.getString(R.string.error_install_update),
            manualUpdateHTML(),
            true,
        )
    }

    override fun onClick(dialog: DialogInterface, which: Int) {
        finish()
    }

    private suspend fun installUpdate() {
        Logger.debug(TAG, "Installing update")
        var context: Context = applicationContext
        var apkDir: File = File(context.cacheDir, "updates")
        val apkPath = File(apkDir, "Lantern.apk")

        val success = coroutineScope {
            downloadUpdate(apkDir, apkPath)
        }

        if (!success) {
            Logger.debug(TAG, "Error trying to install Lantern update")
            Utils.showAlertDialog(this, context.getString(R.string.error_update), manualUpdateHTML(), false)
            return
        }

        try {
            ApkSignatureVerifier.verify(
                context,
                apkPath,
                BuildConfig.SIGNING_CERTIFICATE_SHA256,
            )
        } catch (sfe: SignatureVerificationException) {
            Logger.error(TAG, "Error installing update", sfe)
            displayTamperedApk(context)
            return
        }

        val intent: Intent = Intent()
        intent.setAction(Intent.ACTION_VIEW)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        var apkURI: Uri = Uri.fromFile(apkPath)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            apkURI = FileProvider.getUriForFile(
                context,
                "org.getlantern.lantern.fileProvider",
                apkPath,
            )
        }
        intent.setDataAndType(apkURI, "application/nd.android.package-archive")
        applicationContext.startActivity(intent)
        finish()
    }

    private fun manualUpdateHTML(): CharSequence {
        return Html.fromHtml("<span>" + getString(R.string.manual_update) + "</span>")
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            REQUEST_CODE_PERMISSION -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    CoroutineScope(IO).launch {
                        installUpdate()
                    }
                }
            }
        }
    }
}
