package org.getlantern.lantern.test

import android.Manifest
import androidx.test.rule.GrantPermissionRule

internal fun grantStoragePermissions() = GrantPermissionRule.grant(
    Manifest.permission.WRITE_EXTERNAL_STORAGE,
    Manifest.permission.READ_EXTERNAL_STORAGE
)!!

internal fun grantPermissions(vararg params : String) = GrantPermissionRule.grant(params)!!