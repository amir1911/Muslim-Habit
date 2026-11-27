package com.muslimhabit.muslim_habit

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object CustomNotificationManager {
    const val CHANNEL_ID = "muslim_habit_custom_reminders_v2"
    const val CHANNEL_NAME = "Pengingat Muslim Habbit"
    const val EXTRA_NOTIFICATION_ID = "extra_notif_id"
    const val EXTRA_TITLE = "extra_title"
    const val EXTRA_MESSAGE = "extra_message"
    const val EXTRA_PAYLOAD = "extra_payload"
    const val EXTRA_TIME_STR = "extra_time_str"

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifikasi estetik pengingat ibadah Muslim Habit"
                enableVibration(true)
                setShowBadge(true)
            }
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    fun showCustomNotification(
        context: Context,
        id: Int,
        title: String,
        message: String,
        timeStr: String?,
        payload: String?
    ) {
        createNotificationChannel(context)

        val currentTimeStr = timeStr ?: SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())

        // 1. RemoteViews untuk Collapsed Layout
        val collapsedViews = RemoteViews(context.packageName, R.layout.custom_notification_collapsed).apply {
            setTextViewText(R.id.notification_app_title, title)
            setTextViewText(R.id.notification_message, message)
            setTextViewText(R.id.notification_time, currentTimeStr)
        }

        // 2. RemoteViews untuk Expanded Layout
        val expandedViews = RemoteViews(context.packageName, R.layout.custom_notification_expanded).apply {
            setTextViewText(R.id.notification_app_title_exp, title)
            setTextViewText(R.id.notification_message_exp, message)
            setTextViewText(R.id.notification_time_exp, currentTimeStr)
        }

        // 3. Intent untuk navigasi saat diklik
        val clickIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_payload", payload ?: "")
            putExtra("from_custom_notification", true)
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getActivity(context, id, clickIntent, flags)

        // 4. Bangun Notifikasi dengan NotificationCompat
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(collapsedViews)
            .setCustomBigContentView(expandedViews)
            .setCustomHeadsUpContentView(collapsedViews)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(id, builder.build())
    }

    fun scheduleCustomNotification(
        context: Context,
        id: Int,
        title: String,
        message: String,
        targetEpochMillis: Long,
        payload: String?
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, CustomNotificationReceiver::class.java).apply {
            action = "com.muslimhabit.ACTION_SHOW_CUSTOM_NOTIFICATION"
            putExtra(EXTRA_NOTIFICATION_ID, id)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_MESSAGE, message)
            putExtra(EXTRA_PAYLOAD, payload)
            putExtra(EXTRA_TIME_STR, SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(targetEpochMillis)))
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getBroadcast(context, id, intent, flags)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetEpochMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, targetEpochMillis, pendingIntent)
            }
        } catch (e: SecurityException) {
            // Fallback jika exact alarm tidak diizinkan sistem
            alarmManager.set(AlarmManager.RTC_WAKEUP, targetEpochMillis, pendingIntent)
        }
    }

    fun cancelCustomNotification(context: Context, id: Int) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(id)

        val intent = Intent(context, CustomNotificationReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_NO_CREATE
        }
        val pendingIntent = PendingIntent.getBroadcast(context, id, intent, flags)
        if (pendingIntent != null) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager?.cancel(pendingIntent)
        }
    }
}
