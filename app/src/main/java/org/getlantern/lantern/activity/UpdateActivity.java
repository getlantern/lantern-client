package org.getlantern.lantern.activity;

import android.Android;
import android.Updater;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.Settings;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Extra;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.R;
import org.getlantern.mobilesdk.Logger;

import java.io.File;

@EActivity(R.layout.activity_updater)
public class UpdateActivity extends Activity implements ActivityCompat.OnRequestPermissionsResultCallback {
    private static final String TAG = UpdateActivity.class.getName();
    private static final int REQUEST_CODE_REQUEST_INSTALL_PACKAGES = 1252;

    private UpdaterTask updaterTask;
    private ProgressDialog progressBar;
    private boolean fileDownloading = false;

    static boolean active = false;

    @Extra("updateUrl")
    String updateUrl;

    @ViewById
    TextView updateAvailable;

    @AfterViews
    void afterViews() {
        String appName = getResources().getString(R.string.app_name);
        String message = String.format(getResources().getString(R.string.update_available), appName);
        updateAvailable.setText(message);
    }

    @Override
    protected void onStart() {
        super.onStart();
        active = true;
    }

    @Override
    protected void onStop() {
        super.onStop();
        active = false;
    }

    @Click(R.id.notNow)
    void notNowClicked() {
        finish();
    }

    @Click(R.id.installUpdate)
    void installUpdateClicked() {

        Logger.debug(TAG, "Install Update clicked");

        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP_MR1) {

            final String[] permissions = {
                    android.Manifest.permission.REQUEST_INSTALL_PACKAGES
            };

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (!getPackageManager().canRequestPackageInstalls()) {
                    startActivityForResult(new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                                    .setData(Uri.parse(String.format("package:%s", getPackageName()))),
                            REQUEST_CODE_REQUEST_INSTALL_PACKAGES);
                    return;
                }

            } else {

                for (String permission : permissions) {
                    if (ContextCompat.checkSelfPermission(getApplicationContext(), permission) != PackageManager.PERMISSION_GRANTED) {
                        Logger.debug(TAG, "Requesting permission %1$s", permission);
                        // Android is smart enough to only prompt users the lacked permissions
                        ActivityCompat.requestPermissions(this, permissions, 1);
                        return;
                    }
                }
            }
        }

        installUpdate();
    }

    private void installUpdate() {
        Logger.debug(TAG, "Installing update");
        this.fileDownloading = true;

        final String[] updaterParams = {updateUrl};
        updaterTask = new UpdaterTask(this);
        updaterTask.execute(updaterParams);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_REQUEST_INSTALL_PACKAGES && resultCode == Activity.RESULT_OK) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (getPackageManager().canRequestPackageInstalls()) {
                    installUpdate();
                }
            }
        } else {
            // user didn't give the Install Apps From Unknown Sources permission
            // show error message or just do nothing
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            Logger.v(TAG,"Permission: "+permissions[0]+ "was "+grantResults[0]);
            installUpdate();
        }
    }

    private class UpdaterTask extends AsyncTask<String, Long, Boolean> implements DialogInterface.OnClickListener {

        private final UpdateActivity activity;
        private final Context context;
        private final File apkDir;
        private final File apkPath;

        public UpdaterTask(final UpdateActivity activity) {
            context = activity.getApplicationContext();
            apkDir = new File(context.getCacheDir(), "updates");
            apkPath = new File(apkDir, "Lantern.apk");
            this.activity = activity;
        }

        @Override
        public void onClick(DialogInterface dialog, int which) {
            //Cancel download task
            fileDownloading = false;
            progressBar.dismiss();
            activity.finish();
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            progressBar = new ProgressDialog(activity);
            String appName = getString(R.string.app_name);
            progressBar.setMessage(String.format(getString(R.string.updating_lantern), appName));
            progressBar.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
            progressBar.setIndeterminate(false);
            progressBar.setCancelable(true);
            progressBar.setProgress(0);

            String cancel = getResources().getString(R.string.cancel);

            progressBar.setButton(ProgressDialog.BUTTON_NEGATIVE, cancel, this);
            progressBar.show();
        }

        @Override
        protected Boolean doInBackground(String... params) {

            String updateUrl = params[0];

            Logger.debug(TAG, "Attempting to download update from " + updateUrl);

            try {

                Updater updater = new Updater() {
                    public void progress(long percentage) {
                        publishProgress(percentage);
                    }
                };

                apkDir.mkdirs();
                Android.downloadUpdate(updateUrl,
                        apkPath.getAbsolutePath(), updater);

                return true;

            } catch (Exception e) {
                Logger.debug(TAG, "Error downloading update: " + e.getMessage());
            }
            return false;
        }

        // show an alert when the update fails
        // and mention where the user can download the latest version
        // this also dismisses the current updater activity
        private void displayError() {

            AlertDialog alertDialog = new AlertDialog.Builder(activity).create();
            alertDialog.setTitle(context.getString(R.string.error_update));
            alertDialog.setMessage(context.getString(R.string.manual_update));
            alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                            activity.finish();
                        }
                    });
            alertDialog.show();
        }

        /**
         * Updating progress bar
         */
        @Override
        protected void onProgressUpdate(Long... progress) {
            super.onProgressUpdate(progress);
            // setting progress percentage
            if (progress[0] != null) {
                progressBar.setProgress(progress[0].intValue());
            }
        }

        // begin the installation by opening the resulting file
        @Override
        protected void onPostExecute(Boolean result) {
            super.onPostExecute(result);

            progressBar.dismiss();

            // update cancelled by the user
            if (!fileDownloading) {
                finish();
                return;
            }

            if (!result) {
                Logger.debug(TAG, "Error trying to install Lantern update");
                displayError();
                return;
            }

            Logger.debug(TAG, "About to install new version of Lantern Android");
            if (!apkPath.isFile()) {
                Logger.error(TAG, "Error loading APK; not found at " + apkPath);
                displayError();
                return;
            }

            Intent i = new Intent();
            i.setAction(Intent.ACTION_VIEW);
            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Uri apkURI = Uri.fromFile(apkPath);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                apkURI = FileProvider.getUriForFile(
                        this.context,
                        "org.getlantern.lantern.fileProvider",
                        apkPath);
            }
            ;
            i.setDataAndType(apkURI, "application/vnd.android.package-archive");

            this.context.startActivity(i);

            activity.finish();
        }
    }
}
