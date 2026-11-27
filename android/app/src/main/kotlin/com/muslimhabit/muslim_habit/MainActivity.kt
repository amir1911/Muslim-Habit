package com.muslimhabit.muslim_habit

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.muslimhabit/custom_notification"
    private var pendingPayload: String? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val payload = intent?.getStringExtra("notification_payload")
        if (!payload.isNullOrEmpty()) {
            pendingPayload = payload
            methodChannel?.invokeMethod("onNotificationClicked", payload)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "showCustomNotification" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        val title = call.argument<String>("title") ?: "Muslim Habbit"
                        val message = call.argument<String>("message") ?: ""
                        val timeStr = call.argument<String>("time")
                        val payload = call.argument<String>("payload")

                        CustomNotificationManager.showCustomNotification(
                            context = applicationContext,
                            id = id,
                            title = title,
                            message = message,
                            timeStr = timeStr,
                            payload = payload
                        )
                        result.success(true)
                    }
                    "scheduleCustomNotification" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        val title = call.argument<String>("title") ?: "Muslim Habbit"
                        val message = call.argument<String>("message") ?: ""
                        val targetEpochMillis = (call.argument<Number>("targetEpochMillis"))?.toLong() ?: System.currentTimeMillis()
                        val payload = call.argument<String>("payload")

                        CustomNotificationManager.scheduleCustomNotification(
                            context = applicationContext,
                            id = id,
                            title = title,
                            message = message,
                            targetEpochMillis = targetEpochMillis,
                            payload = payload
                        )
                        result.success(true)
                    }
                    "cancelCustomNotification" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        CustomNotificationManager.cancelCustomNotification(applicationContext, id)
                        result.success(true)
                    }
                    "getPendingPayload" -> {
                        val payload = pendingPayload
                        pendingPayload = null
                        result.success(payload)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
}
