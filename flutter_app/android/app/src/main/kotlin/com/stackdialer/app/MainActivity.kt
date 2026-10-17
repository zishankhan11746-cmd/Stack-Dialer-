package com.stackdialer.app

import android.app.role.RoleManager
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.stackdialer.app/telecom"
    private val REQUEST_ID_SET_DEFAULT_DIALER = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestDefaultDialer" -> {
                    requestSetDefaultDialer()
                    result.success(true)
                }
                "isDefaultDialer" -> {
                    val telecomManager = getSystemService(TELECOM_SERVICE) as TelecomManager
                    val isDefault = telecomManager.defaultDialerPackage == packageName
                    result.success(isDefault)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestSetDefaultDialer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(ROLE_SERVICE) as RoleManager
            if (roleManager.isRoleAvailable(RoleManager.ROLE_DIALER) && !roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                startActivityForResult(intent, REQUEST_ID_SET_DEFAULT_DIALER)
            }
        } else {
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER).apply {
                putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            }
            startActivityForResult(intent, REQUEST_ID_SET_DEFAULT_DIALER)
        }
    }
}
