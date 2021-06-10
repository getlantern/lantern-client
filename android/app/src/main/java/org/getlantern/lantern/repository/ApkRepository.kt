package org.getlantern.lantern.repository

import android.content.Context
import android.content.pm.*
import org.getlantern.lantern.model.ApkSignature
import org.getlantern.lantern.util.SignUtil
import java.io.File
import org.getlantern.lantern.BuildConfig

class ApkRepository {

    fun isSignatureValid(apkSignature: ApkSignature?): Boolean{
        if(apkSignature == null || apkSignature.sha256 == null || apkSignature.sha256.isEmpty()) return false
    return apkSignature.concatSHA256() == BuildConfig.SIGNIN_CERTIFICATE_SHA256
    }

     fun getApkSignature(context: Context, file: File): ApkSignature? {
        val packageManager =  context.packageManager
        val apkSignature = ApkSignature()
        var info: PackageInfo?
        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P){
            info = packageManager.getPackageArchiveInfo(file.absolutePath, PackageManager.GET_SIGNING_CERTIFICATES)
            if (info.signingInfo == null) {
                info = packageManager.getPackageArchiveInfo(file.absolutePath, PackageManager.GET_SIGNATURES)
            }
            if(info == null) return null
            val signingInfo: SigningInfo? = info.signingInfo
            val signatures: Array<Signature>? =
                if (signingInfo == null) info.signatures else signingInfo.apkContentsSigners
            if (signatures != null) {
                apkSignature.sha256 = Array(signatures.size){ ""}
                for (i in signatures.indices) {
                    val data = signatures[i].toByteArray()
                    apkSignature.sha256[i] = SignUtil.getSHA256(data)
                }
            }
        }else{
            info = packageManager.getPackageArchiveInfo(file.absolutePath, PackageManager.GET_SIGNATURES)
            val signatures = info.signatures
            if (signatures != null) {
                apkSignature.sha256 = Array(signatures.size){ ""}
                for (i in signatures.indices) {
                    val data = signatures[i].toByteArray()
                    apkSignature.sha256[i] = SignUtil.getSHA256(data)
                }
            }
        }
        return apkSignature
    }
}