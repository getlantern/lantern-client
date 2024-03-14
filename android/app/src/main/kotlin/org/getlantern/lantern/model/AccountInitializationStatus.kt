package org.getlantern.lantern.model

data class AccountInitializationStatus(val status: Status) {

    enum class Status {
        PROCESSING, SUCCESS, FAILURE
    }

    fun isProcessing(): Boolean {
        return status == Status.PROCESSING
    }

    fun isSuccess(): Boolean {
        return status == Status.SUCCESS
    }

    fun isFailure(): Boolean {
        return status == Status.FAILURE
    }
}
