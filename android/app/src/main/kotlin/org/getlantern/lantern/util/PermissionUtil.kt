package org.getlantern.lantern.util

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import org.getlantern.mobilesdk.Logger

class PermissionUtil {
    companion object {
        private val TAG = PermissionUtil::class.java.simpleName
        private val PERMISSIONS_TAG = "$TAG.permissions"


        /*Note - we do not include Manifest.permission.FOREGROUND_SERVICE because this is automatically
   granted based on being included in Manifest and will show as denied even if we're eligible
   to get it.*/
        private val allRequiredPermissions = arrayOf(
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
        )

        /**
         * This function checks the necessary permissions for the VPN to operate properly.
         * If permissions are missing, it collects them into an array and returns it.
         *
         * @param context the application context is necessary for checking permissions.
         * @return An array of strings, where each string represents a missing permission.
         */
         fun missingPermissions(context: Context): Array<String> {
            val missingPermissions: MutableList<String> = ArrayList()
            for (permission in allRequiredPermissions) {
                if (!hasPermission(permission, context)) {
                    missingPermissions.add(permission)
                }
            }
            return missingPermissions.toTypedArray()
        }


         fun hasPermission(permission: String, context: Context): Boolean {
            val result = ContextCompat.checkSelfPermission(
                context,
                permission,
            ) == PackageManager.PERMISSION_GRANTED
            Logger.debug(PERMISSIONS_TAG, "has permission %s: %s", permission, result)
            return result
        }
    }

}