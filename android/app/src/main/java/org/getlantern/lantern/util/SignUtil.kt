package org.getlantern.lantern.util

import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

object SignUtil {
    private fun bytes2Hex(byteArray: ByteArray): String {
        val sb = StringBuffer()
        for (b in byteArray) {
            val i: Int = b.toInt() and 0xff
            var hexString = Integer.toHexString(i)
            if (hexString.length < 2) {
                hexString = "0$hexString"
            }
            sb.append(hexString)
        }
        return sb.toString()
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