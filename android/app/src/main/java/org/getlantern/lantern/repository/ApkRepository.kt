package org.getlantern.lantern.repository

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.SigningInfo
import org.getlantern.lantern.model.ApkSignature
import org.getlantern.lantern.util.SignUtil
import java.io.File

interface ApkRepository {
    fun getApkDetail(context: Context, file: File): ApplicationInfo?
    fun getSignatures(packageManager: PackageManager, file: File): ApkSignature?
}

class ApkRepositoryImplement: ApkRepository{
    override fun getApkDetail(context: Context, file: File): ApplicationInfo? {
        val packageManager = context.packageManager
        val realPath: String = file.absolutePath
        val info: PackageInfo = packageManager.getPackageArchiveInfo(realPath, 0) ?: return null
        val applicationInfo: ApplicationInfo = info.applicationInfo
        applicationInfo.sourceDir = realPath
        applicationInfo.publicSourceDir = realPath
        return applicationInfo
    }

    override fun getSignatures(packageManager: PackageManager, file: File): ApkSignature? {
        val apkSignature = ApkSignature()
        var info: PackageInfo?
        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P){
            info = packageManager.getPackageArchiveInfo(file.absolutePath, PackageManager.GET_SIGNING_CERTIFICATES)
            if (info.signingInfo == null) {
                info = packageManager.getPackageArchiveInfo(file.absolutePath, PackageManager.GET_SIGNATURES)
            }
            if(info == null) return null
            val signingInfo: SigningInfo? = info.signingInfo
            val signatures: Array<android.content.pm.Signature> =
                if (signingInfo == null) info.signatures else signingInfo.apkContentsSigners
            if (signatures != null) {
                apkSignature.md5 = Array(signatures.size){i -> ""}
                apkSignature.sha1 = Array(signatures.size){i -> ""}
                apkSignature.sha256 = Array(signatures.size){i -> ""}
                for (i in signatures.indices) {
                    val data = signatures[i].toByteArray()
                    apkSignature.md5[i] = SignUtil.getMD5(data)
                    apkSignature.sha1[i] = SignUtil.getSHA1(data)
                    apkSignature.sha256[i] = SignUtil.getSHA256(data)
                }
            }
        }else{
            info = packageManager.getPackageArchiveInfo(file.absolutePath, PackageManager.GET_SIGNING_CERTIFICATES)
            val signatures = info.signatures
            if (signatures != null) {
                apkSignature.md5 = Array(signatures.size){i -> ""}
                apkSignature.sha1 = Array(signatures.size){i -> ""}
                apkSignature.sha256 = Array(signatures.size){i -> ""}
                for (i in signatures.indices) {
                    val data = signatures[i].toByteArray()
                    apkSignature.md5[i] = SignUtil.getMD5(data)
                    apkSignature.sha1[i] = SignUtil.getSHA1(data)
                    apkSignature.sha256[i] = SignUtil.getSHA256(data)
                }
            }
        }
        return apkSignature
    }
}