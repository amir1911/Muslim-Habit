package com.muslimhabit.muslim_habit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class CustomNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra(CustomNotificationManager.EXTRA_NOTIFICATION_ID, 1001)
        val title = intent.getStringExtra(CustomNotificationManager.EXTRA_TITLE) ?: "Muslim Habbit"
        val message = intent.getStringExtra(CustomNotificationManager.EXTRA_MESSAGE) ?: "Waktunya menjalankan ibadah hari ini."
        val timeStr = intent.getStringExtra(CustomNotificationManager.EXTRA_TIME_STR)
        val payload = intent.getStringExtra(CustomNotificationManager.EXTRA_PAYLOAD)

        CustomNotificationManager.showCustomNotification(
            context = context,
            id = id,
            title = title,
            message = message,
            timeStr = timeStr,
            payload = payload
        )
    }
}
