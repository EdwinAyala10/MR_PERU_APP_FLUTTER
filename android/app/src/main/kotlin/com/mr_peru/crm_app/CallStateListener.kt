package com.mr_peru.crm_app

import android.content.Context
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log

class CallStateListener(private val context: Context, private val phoneNumber: String, private val onCallEnded: (Long) -> Unit) : PhoneStateListener() {

    private var callStartTime: Long = 0
    private var isCallActive: Boolean = false

    override fun onCallStateChanged(state: Int, incomingNumber: String?) {
        super.onCallStateChanged(state, incomingNumber)

        Log.d("CallStateListener", "onCallStateChanged: state = $state")

        /*when (state) {
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                Log.d("CallStateListener", "CALL_STATE_OFFHOOK")
                if (incomingNumber == phoneNumber || incomingNumber == null) {
                    callStartTime = System.currentTimeMillis()
                    isCallActive = true
                    Log.d("CallStateListener", "Call answered")
                }
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                Log.d("CallStateListener", "CALL_STATE_IDLE")
                if (isCallActive) {
                    val callDuration = System.currentTimeMillis() - callStartTime
                    Log.d("CallStateListener", "Call ended. Duration: ${callDuration / 1000} seconds")
                    onCallEnded(callDuration / 1000)
                    isCallActive = false
                }
            }
            TelephonyManager.CALL_STATE_RINGING -> {
                Log.d("CallStateListener", "CALL_STATE_RINGING")
                Log.d("CallStateListener", "Phone is ringing: $incomingNumber")
            }
        }*/
        when (state) {
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                callStartTime = System.currentTimeMillis()
                isCallActive = true
                Log.d("CallStateListener", "Call answered")
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                if (isCallActive) {
                    val callDuration = System.currentTimeMillis() - callStartTime
                    Log.d("CallStateListener", "Call ended. Duration: ${callDuration / 1000} seconds")
                    onCallEnded(callDuration / 1000)
                    isCallActive = false
                }
            }
            TelephonyManager.CALL_STATE_RINGING -> {
                Log.d("CallStateListener", "Phone is ringing: $incomingNumber")
            }
        }
    }
}