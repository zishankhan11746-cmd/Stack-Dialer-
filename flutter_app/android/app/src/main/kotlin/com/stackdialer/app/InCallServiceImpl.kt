package com.stackdialer.app

import android.telecom.Call
import android.telecom.InCallService

class InCallServiceImpl : InCallService() {
    companion object {
        var currentCall: Call? = null
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        currentCall = call
        call.registerCallback(object : Call.Callback() {
            override fun onStateChanged(call: Call, state: Int) {
                super.onStateChanged(call, state)
            }
        })
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        if (currentCall == call) {
            currentCall = null
        }
    }
}
