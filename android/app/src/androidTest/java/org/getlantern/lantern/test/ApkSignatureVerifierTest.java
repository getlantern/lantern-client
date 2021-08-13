package org.getlantern.lantern.test;

import androidx.test.filters.LargeTest;
import androidx.test.runner.AndroidJUnit4;

import org.getlantern.lantern.util.ApkSignatureVerifier;
import org.getlantern.lantern.util.SignatureVerificationException;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;

@RunWith(AndroidJUnit4.class)
@LargeTest
public class ApkSignatureVerifierTest extends BaseTest {
    private static final String GOOD_SIGNATURE = "108f612ae55354078ec12b10bb705362840d48fa78b9262c11b6d0adeff6f289";
    private static final String BAD_SIGNATURE = GOOD_SIGNATURE + "bad";

    @Test
    public void testVerifySignature() throws Exception {
        File apkFile = new File(tempDir, "test.apk");
        TestUtils.downloadToFile("https://lantern.s3.amazonaws.com/lantern-installer-6.7.2.apk",
                apkFile);
        ApkSignatureVerifier.verify(getTargetContext(), apkFile, GOOD_SIGNATURE);
        try {
            ApkSignatureVerifier.verify(getTargetContext(), apkFile, BAD_SIGNATURE);
            Assert.fail("Verifying APK against bad signature should have failed");
        } catch (SignatureVerificationException sfe) {
            sfe.printStackTrace();
        }
    }
}
