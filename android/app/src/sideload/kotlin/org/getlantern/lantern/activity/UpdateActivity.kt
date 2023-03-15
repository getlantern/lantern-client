package org.getlantern.lantern.activity

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.Html
import android.widget.ProgressBar
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
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
import org.getlantern.lantern.util.DeviceInfo
import org.getlantern.lantern.util.SignatureVerificationException
import org.getlantern.lantern.util.getAppInstallIntent
import org.getlantern.mobilesdk.Logger
import java.io.File

@EActivity(R.layout.activity_updater)
open class UpdateActivity : BaseFragmentActivity(), DialogInterface.OnClickListener {

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

    // downloadUpdate 
    private fun downloadUpdate(context:Context, apkDir: File, apkPath: File): Boolean {
        val updater = Updater { percent: Long -> progressBar!!.progress = percent.toInt() }
        try {
            apkDir.mkdirs()
            Internalsdk.downloadUpdate(
                DeviceInfo,
                intent.getStringExtra("updateUrl").toString(),
                apkPath.getAbsolutePath(),
                updater,
            )
            ApkSignatureVerifier.verify(
                context,
                apkPath,
                BuildConfig.SIGNING_CERTIFICATE_SHA256,
            )
            return true
        } catch (e: Exception) {
            Logger.debug(TAG, "Error downloading update: " + e.message)
        }
        return false
    }

    // show an alert notifying the user that the downloaded apk has been tampered
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

    private fun installUpdate() {
        val callingActivity = this
        lifecycleScope.launch(IO) {
            Logger.debug(TAG, "Installing update")
            var context: Context = applicationContext
            var apkDir: File = File(context.cacheDir, "updates")
            val apkPath = File(apkDir, "Lantern.apk")
            var success = false
            try {
                success = downloadUpdate(context, apkDir, apkPath)
                if (success) {
                    val intent: Intent? = context.getAppInstallIntent(apkPath)
                    applicationContext.startActivity(intent)
                    finish()
                }
            } catch (sfe: SignatureVerificationException) {
                success = false
                Logger.error(TAG, "Error installing update", sfe)
                displayTamperedApk(context)
            } finally {
              Internalsdk.installFinished(DeviceInfo, success)
            }
        }
    }

    private fun manualUpdateHTML(): CharSequence {
        return Html.fromHtml("<span>" + getString(R.string.manual_update) + "</span>")
    }

    @Click(R.id.notNow)
    fun notNowClicked() {
        finish()
    }

    private fun hasInstallPackagesPermission(): Boolean {
        return PackageManager.PERMISSION_GRANTED ==
            packageManager.checkPermission(Manifest.permission.REQUEST_INSTALL_PACKAGES, packageName)
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    // start the process of installing the update on Android Oreo (8.x)
    private fun startInstallO() {
        val isGranted = packageManager.canRequestPackageInstalls()
        if (isGranted) {
            installUpdate()
        } else {
            val uri: Uri = Uri.parse("package:%s".format(packageName))
            startActivityForResult(
                Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).setData(uri),
                REQUEST_CODE_PERMISSION,
            )
        }
    }

    @Click(R.id.installUpdate)
    fun installUpdateClicked() {
        when {
            Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP_MR1 -> installUpdate()
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> startInstallO()
            !hasInstallPackagesPermission() -> ActivityCompat.requestPermissions(this, arrayOf<String>(Manifest.permission.INSTALL_PACKAGES), 1)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        if (resultCode != Activity.RESULT_OK) {
            return
        }
        when (requestCode) {
            REQUEST_CODE_PERMISSION -> {
                installUpdate()
            }
        }
    }
}
