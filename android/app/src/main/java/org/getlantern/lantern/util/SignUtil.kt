package org.getlantern.lantern.util

import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import kotlin.experimental.and


//This instance is used to do the conversion of the Signature which is obtained from a bytearray
//into a more understandable format, also due to security reasons, this is needed due to only use hascode
//compromise the integrity of the apk and can lead to undesired results.
object SignUtil {

    //Used to convert the hex values into the final encrypted string array.
    //refers: https://gist.github.com/scottyab/b849701972d57cf9562e
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

    //Read an array of bytes and proceeds to convert it into a string which represents
    //the hex values of the current parameter.
    //refers: https://stackoverflow.com/questions/49651834/is-signature-hashcode-referring-to-the-right-hashcode/60415924#60415924
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

    //Returns an encrypted String, using an encryption needed with sha256.
    //also this class calls [bytes2Hex] and with that proceeds to return a value which has their representation
    //as a signed string.
    //refers: https://stackoverflow.com/questions/5578871/how-to-get-apk-signing-signature
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