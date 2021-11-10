package io.lantern.android.model

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.getlantern.lantern.LanternApp

class ReplicaModel(
    flutterEngine: FlutterEngine? = null,
) : BaseModel("replica", flutterEngine, masterDB.withSchema("replica")) {

    companion object {
        private const val TAG = "ReplicaModel"
        private const val ERROR_LANTERN_UNAVAILABLE = "lantern_unavailable"
        private const val ERROR_REPLICA_UNAVAILABLE = "replica_unavailable"
    }

    override fun doOnMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.w(TAG, "doOnMethodCall: doOnMethodCall()")
        when (call.method) {
            "getReplicaAddr" -> getReplicaAddr(result)
            else -> super.doOnMethodCall(call, result)
        }
    }

    private fun getReplicaAddr(result: MethodChannel.Result) {
        Log.w(TAG, "getReplicaAddr: ")
        if (!LanternApp.getSession().lanternDidStart()) {
            Log.w(TAG, "getReplicaAddr: lantern did not start yet")
            result.error(ERROR_LANTERN_UNAVAILABLE, "", "")
        }
        if (LanternApp.getSession().replicaAddr.isEmpty()) {
            Log.w(TAG, "getReplicaAddr: replica failed to start")
            result.error(ERROR_REPLICA_UNAVAILABLE, "", "")
        }
        Log.w(TAG, "getReplicaAddr: lantern started: " + LanternApp.getSession().replicaAddr)
        result.success(LanternApp.getSession().replicaAddr)
    }
}

