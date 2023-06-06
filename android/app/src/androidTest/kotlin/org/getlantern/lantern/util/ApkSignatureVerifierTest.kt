package org.getlantern.lantern.util

import androidx.test.filters.LargeTest
import androidx.test.runner.AndroidJUnit4
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File
import org.getlantern.lantern.test.BaseTest
import org.getlantern.lantern.test.TestUtils

@LargeTest
@RunWith(AndroidJUnit4::class)
class ApkSignatureVerifierTest : BaseTest() {
    companion object {
        private const val GOOD_SIGNATURE = "108f612ae55354078ec12b10bb705362840d48fa78b9262c11b6d0adeff6f289"
        private const val BAD_SIGNATURE = GOOD_SIGNATURE + "bad"
    }

    @Test
    fun testVerifySignature() {
        val apkFile = File(tempDir, "test.apk")
        TestUtils.downloadToFile("https://lantern.s3.amazonaws.com/lantern-installer-6.7.2.apk",
                apkFile)
        ApkSignatureVerifier.verify(getTargetContext(), apkFile, GOOD_SIGNATURE)
        try {
            ApkSignatureVerifier.verify(getTargetContext(), apkFile, BAD_SIGNATURE)
            Assert.fail("Verifying APK against bad signature should have failed")
        } catch (sfe: SignatureVerificationException) {
            sfe.printStackTrace()
        }
    }
}
