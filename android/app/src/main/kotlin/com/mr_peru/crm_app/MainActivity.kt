package com.mr_peru.crm_app

import android.os.Bundle
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {

    private lateinit var telephonyManager: TelephonyManager
    private lateinit var callStateListener: CallStateListener

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.yourdomain.call_duration")
            .setMethodCallHandler { call, result ->
                if (call.method == "startCall") {
                    val phoneNumber = call.arguments as String  // Asegúrate de que el número de teléfono se obtiene correctamente
                    startListeningForCallState(phoneNumber)  // Pasa el número de teléfono al método
                    result.success(null)
                }
            }
    }

    private fun startListeningForCallState(phoneNumber: String) {
        Log.d("MainActivity", "Start listening for call state changes")
        callStateListener = CallStateListener(this, phoneNumber) { duration ->
            Log.d("MainActivity", "Call duration received: $duration seconds")
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.yourdomain.call_duration")
                .invokeMethod("callEnded", duration)
        }
        telephonyManager.listen(callStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }

    override fun onDestroy() {
        super.onDestroy()
        telephonyManager.listen(callStateListener, PhoneStateListener.LISTEN_NONE)
    }
}