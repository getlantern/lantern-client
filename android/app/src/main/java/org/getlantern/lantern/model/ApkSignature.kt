package org.getlantern.lantern.model


//Class that contains the conversion from hashcode into a StringArray of the signature apk
class ApkSignature(
    var sha256: Array<String> = arrayOf()
){
    fun concatSHA256(): String {
        return sha256.joinToString(separator = "")
    }
}