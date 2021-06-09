package org.getlantern.lantern.model

class ApkSignature(
    var md5: Array<String> = arrayOf(),
    var sha1: Array<String> = arrayOf(),
    var sha256: Array<String> = arrayOf()
){
    fun concatMD5(): String {
        return md5.joinToString(separator = "")
    }

    fun concatSHA1(): String {
        return sha1.joinToString(separator = "")
    }

    fun concatSHA256(): String {
        return sha256.joinToString(separator = "")
    }
}