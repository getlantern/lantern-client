package io.lantern.isimud.model

import android.nfc.FormatException
import com.google.protobuf.GeneratedMessageLite
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer


class ProtobufMessageCodec: StandardMessageCodec() {
    override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
        if (value == null) {
            super.writeValue(stream, value)
            return
        }

        val type = when(value) {
            is Messaging.Timestamp -> TIMESTAMP
            is Messaging.Contact -> CONTACT
            is Messaging.Message -> MESSAGE
            is Messaging.Conversation -> CONVERSATION
            else -> 0
        }

        if (type == 0.toByte()) {
            super.writeValue(stream, value)
            return
        }

        stream.write(type.toInt())
        val bytes = (value as GeneratedMessageLite<*, *>).toByteArray()
        writeBytes(stream, bytes)
    }

    override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any {
        if (type < 30) {
            return super.readValueOfType(type, buffer)
        }

        val length = readSize(buffer)
        val serialized = ByteArray(length)
        buffer.get(serialized)
        return when (type) {
            TIMESTAMP -> Messaging.Conversation.parseFrom(serialized)
            CONTACT -> Messaging.Contact.parseFrom(serialized)
            MESSAGE -> Messaging.Message.parseFrom(serialized)
            CONVERSATION -> Messaging.Conversation.parseFrom(serialized)
            else -> throw FormatException("Unknown data type: $type")
        }
    }

    companion object {
        const val TIMESTAMP:Byte = 30
        const val CONTACT:Byte = 31
        const val MESSAGE:Byte = 32
        const val CONVERSATION:Byte = 33
    }
}