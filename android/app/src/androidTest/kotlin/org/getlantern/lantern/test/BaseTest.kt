package org.getlantern.lantern.test

import android.content.Context
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.After
import org.junit.Before
import java.io.File
import java.util.Random

open class BaseTest {

    var tempDir : File? = null

    fun getTargetContext(): Context {
        return InstrumentationRegistry.getInstrumentation().getTargetContext()
    }

    @Before
    fun setupTempDir() {
        tempDir = File(
                getTargetContext().getCacheDir(),
                Random().nextLong().toString()
        )
        tempDir?.mkdirs()
    }

    @After
    fun deleteTempDir() {
        deleteDirectory(tempDir!!)
    }

    fun deleteDirectory(dir: File) {
        var allContents = dir.listFiles()
        if (allContents != null) {
            for (file in allContents) {
                deleteDirectory(file)
            }
        }
        dir.delete()
    }
}
