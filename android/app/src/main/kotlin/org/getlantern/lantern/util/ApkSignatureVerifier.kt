package org.getlantern.lantern.util

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.content.pm.SigningInfo
import org.getlantern.mobilesdk.Logger
import java.io.File
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

/**
 * SignatureVerificationException significes that the signature of an APK failed to verify.
 */
class SignatureVerificationException(message: String) : Exception(message)

/**
 * Utility for verifying APK signatures
 */
object ApkSignatureVerifier {

    private const val TAG = "ApkSignatureVerifier"

    /**
     * Verifies that the given APK has one and only one Signature whose SHA256matches the expected
     * value.
     *
     * @param context Context used for obtaining PackageManager
     * @param file the APK file
     * @param expectedSignatureSha256 the expected SHA256 signature, hex encoded
     * @throws SignatureVerificationException if signature failed verification
     */
    @JvmStatic
    @Throws(SignatureVerificationException::class)
    fun verify(context: Context, file: File, expectedSignatureSha256: String) {
        val actualSignatureSha256 = getSignatureSha256(context, file)
        if (actualSignatureSha256 != expectedSignatureSha256) {
            throw SignatureVerificationException("Signature did not match expected for APK at ${file.absolutePath}.\n\nExpected $expectedSignatureSha256\n got $actualSignatureSha256")
        }
    }

    private fun getSignatureSha256(context: Context, file: File): String {
        val packageManager = context.packageManager
        var info: PackageInfo?
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            info = packageManager.getPackageArchiveInfo(
                file.absolutePath,
                PackageManager.GET_SIGNING_CERTIFICATES
            )
            if (info?.signingInfo == null) {
                info = packageManager.getPackageArchiveInfo(
                    file.absolutePath,
                    PackageManager.GET_SIGNATURES
                )
            }
            if (info == null)
                throw SignatureVerificationException("No package information available for APK at ${file.absolutePath}")
            val signingInfo: SigningInfo? = info.signingInfo
            val signatures: Array<Signature>? =
                if (signingInfo == null) info.signatures else signingInfo.apkContentsSigners
            return getSignatureSha256(signatures, file)
        } else {
            info = packageManager.getPackageArchiveInfo(
                file.absolutePath,
                PackageManager.GET_SIGNATURES
            )
            return getSignatureSha256(info?.signatures, file)
        }
    }

    private fun getSignatureSha256(signatures: Array<Signature>?, file: File): String {
        if (signatures == null)
            throw SignatureVerificationException("No signatures found for APK at ${file.absolutePath}")
        if (signatures.size != 1)
            throw SignatureVerificationException("Found ${signatures.size} signatures when expecting only 1 for APK at ${file.absolutePath}")
        return sha256(signatures[0].toByteArray())
    }

    // Used to convert the hex values into the final encrypted string array.
    // refers: https://gist.github.com/scottyab/b849701972d57cf9562e
    private val hexDigits = charArrayOf(
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f'
    )

    // Read an array of bytes and proceeds to convert it into a string which represents
    // the hex values of the current parameter.
    // refers: https://stackoverflow.com/questions/49651834/is-signature-hashcode-referring-to-the-right-hashcode/60415924#60415924
    private fun bytes2Hex(src: ByteArray): String {
        val res = CharArray(src.size * 2)
        var i = 0
        var j = 0
        while (i < src.size) {
            res[j++] = hexDigits[src[i].toInt().ushr(4) and 0x0f]
            res[j++] = hexDigits[(src[i].toInt() and 0x0f).toInt()]
            i++
        }
        return String(res)
    }

    // Returns an encrypted String, using an encryption needed with sha256.
    // also this class calls [bytes2Hex] and with that proceeds to return a value which has their representation
    // as a signed string.
    // refers: https://stackoverflow.com/questions/5578871/how-to-get-apk-signing-signature
    @JvmStatic
    fun sha256(data: ByteArray?): String {
        var value = ""
        if (data == null || data.isEmpty()) {
            return value
        }
        try {
            val digester = MessageDigest.getInstance("SHA256")
            value = bytes2Hex(digester.digest(data))
        } catch (e: NoSuchAlgorithmException) {
            Logger.error(TAG, "Unable to decode message into a encrypted string", e)
        }
        return value
    }
}
