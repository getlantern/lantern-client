package org.getlantern.lantern.activity

import android.os.Bundle
import android.widget.Button
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
import android.view.View
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
import internalsdk.Internalsdk
import internalsdk.Updater
import kotlinx.coroutines.*
import kotlinx.coroutines.Dispatchers.IO
import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.model.Utils
import org.getlantern.lantern.R
import org.getlantern.lantern.util.ApkInstaller
import org.getlantern.lantern.util.ApkSignatureVerifier
import org.getlantern.lantern.util.DeviceInfo
import org.getlantern.lantern.util.SignatureVerificationException
import org.getlantern.mobilesdk.Logger
import java.io.File

open class UpdateActivity : BaseFragmentActivity(), DialogInterface.OnClickListener {

    companion object {
        private val TAG = UpdateActivity::class.java.name
        private const val REQUEST_CODE_PERMISSION = 1252
    }

    private var apkInstaller: ApkInstaller? = null

    lateinit var title: TextView
    lateinit var subTitle: TextView
    lateinit var progressBarLayout: LinearLayout
    lateinit var progressBar: ProgressBar
    lateinit var updateButtons: RelativeLayout
    lateinit var percentage: TextView
    lateinit var installUpdate: Button
    lateinit var notNow: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.update_dialog)
        title = findViewById(R.id.title)
        subTitle = findViewById(R.id.subTitle)
        progressBarLayout = findViewById(R.id.progressBarLayout)
        progressBar = findViewById(R.id.progressBar)
        updateButtons = findViewById(R.id.updateButtons)
        percentage = findViewById(R.id.percentage)
        installUpdate = findViewById(R.id.installUpdate)
        notNow = findViewById(R.id.notNow)
        installUpdate.setOnClickListener {
            installUpdateClicked()
        }
        notNow.setOnClickListener {
            finish()
        }
        subTitle.setText(getString(R.string.update_available, getString(R.string.app_name)))
    }

    fun publishProgress(percent: Long) {
        progressBar.progress = percent.toInt()
        runOnUiThread {
            percentage.text = "$percent%"
        }
    }

    fun showErrorAlert() {
        Utils.showAlertDialog(this, getString(R.string.error_update), manualUpdateHTML(), false)
    }

    // downloadUpdate creates a new instance of Updater and downloads an update via Go
    // Once the download is complete, ApkSignatureVerifier verifies the APK signature
    private fun downloadUpdate(context: Context, apkDir: File, apkPath: File): Boolean {
        val updater = Updater { percent: Long -> publishProgress(percent) }
        try {
            apkDir.mkdirs()
            val result: Boolean = Internalsdk.downloadUpdate(
                DeviceInfo,
                intent.getStringExtra("updateUrl").toString(),
                apkPath.getAbsolutePath(),
                updater,
            )
            if (!result) {
                // show an alert if there was an error downloading the update
                showErrorAlert()
                return false
            }
            if (!apkPath.isFile()) {
                Logger.error(TAG, "Error loading APK; not found at " + apkPath)
                showErrorAlert()
                return false
            }
            ApkSignatureVerifier.verify(
                context,
                apkPath,
                BuildConfig.SIGNING_CERTIFICATE_SHA256,
            )
            return true
        } catch (sfe: SignatureVerificationException) {
            Logger.debug(TAG, "Error verifying update: " + sfe.message)
            displayTamperedApk(context)
        }
        return false
    }

    override fun onDestroy() {
        super.onDestroy()
        apkInstaller?.let { it.unregisterCallback() }
    }

    // show an alert notifying the user that the downloaded apk has been tampered with
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

    // installUpdate launches a new coroutine to download an update and serves the APK
    // for installation once the download completes
    private fun installUpdate() {
        val callingActivity = this
        val appName = getString(R.string.app_name)
        // make progress bar layout in update prompt visible and hide the update buttons
        progressBarLayout.setVisibility(View.VISIBLE)
        subTitle.setVisibility(View.GONE)
        subTitle.setText(getString(R.string.update_available, getString(R.string.app_name)))
        updateButtons.setVisibility(View.GONE)
        title.text = String.format(getString(R.string.updating_lantern), appName)
        var context: Context = applicationContext
        var apkDir: File = File(context.cacheDir, "updates")
        val apkPath = File(apkDir, "Lantern.apk")
        apkInstaller = ApkInstaller(this, apkPath)
        lifecycleScope.launch(IO) {
            val success = downloadUpdate(context, apkDir, apkPath)
            if (success) {
                apkInstaller?.execute()
            }
        }
    }

    private fun manualUpdateHTML(): CharSequence {
        return Html.fromHtml("<span>" + getString(R.string.manual_update) + "</span>")
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