package org.getlantern.lantern.model

class ApkSignature(
    var md5: Array<String> = arrayOf(),
    var sha1: Array<String> = arrayOf(),
    var sha256: Array<String> = arrayOf()
)