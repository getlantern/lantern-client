package org.getlantern.lantern.util

import io.mockk.mockk
import okhttp3.Protocol
import org.junit.Test

class LanternHttpClientTest {
    @Test
    fun `from raw http - normal`() {
        val statusOK = "HTTP/1.1 200 OK\r\n" +
                "Content-Type: application/json;charset=utf-8\r\n" +
                "X-Lantern-Device-Id: abc\r\n" +
                "X-Lantern-User-Id: 12345\r\n" +
                "\r\n" +
                "Some Content"

        statusOK.toVauInnerHttpResponse(mockk()).let {
            assertEquals(Protocol.HTTP_1_1, it.protocol)
            assertEquals(200, it.code)
            assertEquals("abc", it.headers["X-Lantern-Device-Id"])
            assertEquals("12345", it.headers["X-Lantern-User-Id"])
            assertEquals("application/json;charset=utf-8", it.body!!.contentType().toString())
            assertEquals("Some Content", it.body!!.string())
        }

        val notFound = "HTTP/1.1 400 NOT FOUND\r\n" +
                "Content-Type: application/json;charset=utf-8\r\n" +
                "X-Header: abc\r\n" +
                "Y-Header: 12345\r\n" +
                "\r\n" +
                "Some Content"

        notFound.toVauInnerHttpResponse(mockk()).let {
            assertEquals(Protocol.HTTP_1_1, it.protocol)
            assertEquals(400, it.code)
            assertEquals("abc", it.headers["X-Lantern-Device-Id"])
            assertEquals("12345", it.headers["X-Lantern-User-Id"])
            assertEquals("application/json;charset=utf-8", it.body!!.contentType().toString())
            assertEquals("Some Content", it.body!!.string())
        }
    }
}
