package io.lantern.android.model

import org.junit.Assert
import org.junit.Test

class BaseModelTest {
    @Test
    fun testGet() {
        val model = BaseModel()
        var theValue = "thevalue";
        model.put("path", theValue)
        Assert.assertEquals(theValue, model.get("path"))
        Assert.assertEquals(theValue, model.get<String>("path"))
        Assert.assertNull(model.get<String>("anotherPath"))
    }

    @Test
    fun testGetRange() {
        val model = BaseModel()
        var theValue = listOf(1, 2, 3)
        model.put("path", theValue)
        Assert.assertEquals(theValue, model.get("path"))
        Assert.assertEquals(theValue.subList(1, 3), model.getRange<String>("path", 1, 2))
        Assert.assertEquals(theValue, model.getRange<String>("path", 0, 4))
        Assert.assertEquals(3, model.getRange<Any>("path", 0, 4).size)
        Assert.assertEquals(0, model.getRange<String>("anotherPath", 0, 4).size)
    }

    @Test
    fun testSubscribeLate() {
        val model = BaseModel()
        var theValue = "thevalue";

        model.put("path", theValue)
        model.subscribe<String>(100,"path") { path: String, value: String? ->
            Assert.assertEquals("path", path)
            Assert.assertEquals(theValue, value)
        }

        theValue = "new value"
        model.put("path", theValue)
    }

    @Test
    fun testSubscribe() {
        val model = BaseModel()
        var currentValue = "original value";

        model.subscribe<String>(100,"path") { path: String, value: String? ->
            Assert.fail("this subscriber was replaced and should never have been notified")
        }

        model.subscribe<String>(100,"path") { path: String, value: String? ->
            Assert.assertEquals("path", path)
            // this subscriber should only ever get the original value because we unsubscribe later
            Assert.assertEquals("original value", value)
        }

        model.subscribe<String>(101,"path") { path: String, value: String? ->
            Assert.assertEquals("path", path)
            // this subscriber should always get the current value because we don't unsubscribe it
            Assert.assertEquals(currentValue, value)
        }

        model.unsubscribe(100, "path")

        model.put("path", currentValue)
        currentValue = "new value"
        model.put("path", currentValue)
    }

    @Test
    fun testGetRangeDetails() {
        val model = BaseModel()
        var theValue = listOf(1, 2, 3)
        model.put("path", theValue)
        theValue.forEach { model.put("details/$it", "detail $it") }
        Assert.assertArrayEquals(listOf("detail 2", "detail 3").toTypedArray(), model.getRangeDetails<String>("path", "details", 1, 3).toTypedArray())
    }

    @Test
    fun testSubscribeDetails() {
        val model = BaseModel()
        var theValue = listOf(1, 2, 3)
        model.put("path", theValue)
        theValue.forEach { model.put("details/$it", "detail $it") }

        model.subscribeDetails<String>(100,"path", "details") { path: String, value: List<String?> ->
            Assert.assertEquals("path", path)
            Assert.assertArrayEquals(listOf("detail 2", "detail 3").toTypedArray(), model.getRangeDetails<String>("path", "details", 1, 3).toTypedArray())
        }
    }
}