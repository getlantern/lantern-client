package org.getlantern.lantern.util

import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import kotlin.experimental.and

object SignUtil {

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

    @kotlin.jvm.JvmStatic
    fun getMD5(data: ByteArray?): String {
        var value = ""
        if (data == null || data.isEmpty()) {
            return value
        }
        try {
            val digester = MessageDigest.getInstance("MD5")
            value = bytes2Hex(digester.digest(data))
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
        return value
    }

    @kotlin.jvm.JvmStatic
    fun getSHA1(data: ByteArray?): String {
        var value = ""
        if (data == null || data.isEmpty()) {
            return value
        }
        try {
            val digester = MessageDigest.getInstance("SHA1")
            value = bytes2Hex(digester.digest(data))
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
        return value
    }

    @kotlin.jvm.JvmStatic
    fun getSHA256(data: ByteArray?): String {
        var value = ""
        if (data == null || data.isEmpty()) {
            return value
        }
        try {
            val digester = MessageDigest.getInstance("SHA256")
            value = bytes2Hex(digester.digest(data))
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        }
        return value
    }
}