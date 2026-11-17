package com.muslimhabit.muslim_habit

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import java.util.*

/**
 * PrayerWidgetProvider — Android Home Screen Widget untuk MuslimHabit
 *
 * Menampilkan:
 * 1. Status waktu salat real-time ("Sekarang Ashar" atau "Berikutnya Subuh")
 * 2. Jam waktu salat (contoh: "15:30 WIB")
 * 3. Seluruh jadwal salat 5 waktu (Subuh, Dzuhur, Ashar, Maghrib, Isya)
 * 4. Maskot MuslimHabit (Lulu)
 * 5. Tombol "Pantau habit →" untuk membuka aplikasi
 *
 * Widget otomatis menghitung waktu salat aktif berdasarkan jam perangkat saat ini
 * dan menjadwalkan update otomatis tepat di pergantian waktu salat berikutnya.
 */
class PrayerWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "com.muslimhabit.muslim_habit"
        const val ACTION_UPDATE_WIDGET = "com.muslimhabit.UPDATE_WIDGET"
        private const val ALARM_REQUEST_CODE = 8821

        /** Paksa refresh semua widget yang terpasang */
        fun forceUpdate(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, PrayerWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                val intent = Intent(context, PrayerWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(intent)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_WIDGET ||
            intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action == Intent.ACTION_TIME_CHANGED ||
            intent.action == Intent.ACTION_TIMEZONE_CHANGED
        ) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, PrayerWidgetProvider::class.java)
            )
            for (id in ids) updateWidget(context, manager, id)
        }
    }

    private fun getPreference(context: Context): SharedPreferences {
        val candidates = listOf(
            PREFS_NAME,
            "${context.packageName}_preferences",
            "FlutterSharedPreferences"
        )
        for (name in candidates) {
            val sp = context.getSharedPreferences(name, Context.MODE_PRIVATE)
            if (sp.contains("widget_subuh") || sp.contains("flutter.widget_subuh")) {
                return sp
            }
        }
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    private fun readString(prefs: SharedPreferences, key: String, default: String): String {
        return prefs.getString(key, null)
            ?: prefs.getString("flutter.$key", null)
            ?: default
    }

    /**
     * Konversi string waktu "HH:mm" menjadi total menit dari tengah malam.
     * Contoh: "04:30" -> 4 * 60 + 30 = 270 menit.
     */
    private fun timeToMinutes(timeStr: String): Int {
        val clean = timeStr.trim().split(" ")[0]
        val parts = clean.split(":")
        if (parts.size >= 2) {
            val h = parts[0].toIntOrNull() ?: 0
            val m = parts[1].toIntOrNull() ?: 0
            return h * 60 + m
        }
        return 0
    }

    data class PrayerCalculation(
        val badgeLabel: String,     // "Sekarang" atau "Berikutnya"
        val activeName: String,     // Nama salat yang sedang berlangsung atau yang berikutnya
        val displayTime: String,    // Jam yang ditampilkan besar di kiri (misal "15:30")
        val highlightName: String,  // Nama salat yang di-highlight pada daftar kanan
        val minutesToNextTrigger: Int // Sisa menit menuju waktu salat berikutnya untuk AlarmManager
    )

    /**
     * Menghitung status salat secara real-time berdasarkan jam perangkat saat ini:
     * - 00:00 - < Subuh     -> Berikutnya Subuh
     * - Subuh - < Dzuhur    -> Sekarang Subuh
     * - Dzuhur - < Ashar    -> Sekarang Dzuhur
     * - Ashar - < Maghrib   -> Sekarang Ashar
     * - Maghrib - < Isya    -> Sekarang Maghrib
     * - Isya - 23:59        -> Sekarang Isya
     */
    private fun determinePrayerStatus(
        subuh: String,
        dzuhur: String,
        ashar: String,
        maghrib: String,
        isya: String,
        now: Calendar = Calendar.getInstance()
    ): PrayerCalculation {
        val subuhMin   = timeToMinutes(subuh)
        val dzuhurMin  = timeToMinutes(dzuhur)
        val asharMin   = timeToMinutes(ashar)
        val maghribMin = timeToMinutes(maghrib)
        val isyaMin    = timeToMinutes(isya)

        val nowMin = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)

        return when {
            // Sebelum Subuh (misal 04:10)
            nowMin < subuhMin -> {
                PrayerCalculation(
                    badgeLabel = "Berikutnya",
                    activeName = "Subuh",
                    displayTime = subuh,
                    highlightName = "subuh",
                    minutesToNextTrigger = (subuhMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Subuh (misal 04:35)
            nowMin < dzuhurMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Subuh",
                    displayTime = subuh,
                    highlightName = "subuh",
                    minutesToNextTrigger = (dzuhurMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Dzuhur (misal 12:10)
            nowMin < asharMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Dzuhur",
                    displayTime = dzuhur,
                    highlightName = "dzuhur",
                    minutesToNextTrigger = (asharMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Ashar (misal 16:00, 17:24)
            nowMin < maghribMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Ashar",
                    displayTime = ashar,
                    highlightName = "ashar",
                    minutesToNextTrigger = (maghribMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Maghrib (misal 18:00)
            nowMin < isyaMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Maghrib",
                    displayTime = maghrib,
                    highlightName = "maghrib",
                    minutesToNextTrigger = (isyaMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Isya (misal 19:10, 23:30)
            else -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Isya",
                    displayTime = isya,
                    highlightName = "isya",
                    // Menuju Subuh hari esok
                    minutesToNextTrigger = ((1440 - nowMin) + subuhMin).coerceAtLeast(1)
                )
            }
        }
    }

    private fun updateWidget(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int
    ) {
        val prefs = getPreference(context)

        val subuh   = readString(prefs, "widget_subuh",   "04:30")
        val dzuhur  = readString(prefs, "widget_dzuhur",  "11:55")
        val ashar   = readString(prefs, "widget_ashar",   "15:30")
        val maghrib = readString(prefs, "widget_maghrib", "17:50")
        val isya    = readString(prefs, "widget_isya",    "19:00")
        val tz      = readString(prefs, "widget_timezone", "WIB")

        // Hitung status waktu salat real-time berdasarkan jam perangkat
        val calculation = determinePrayerStatus(subuh, dzuhur, ashar, maghrib, isya)

        val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

        // Set Prayer Times di panel kanan
        views.setTextViewText(R.id.tv_subuh,   subuh)
        views.setTextViewText(R.id.tv_dzuhur,  dzuhur)
        views.setTextViewText(R.id.tv_ashar,   ashar)
        views.setTextViewText(R.id.tv_maghrib, maghrib)
        views.setTextViewText(R.id.tv_isya,    isya)

        // Set Badge & Jam Utama di panel kiri sesuai waktu saat ini
        views.setTextViewText(R.id.tv_badge_label, calculation.badgeLabel)
        views.setTextViewText(R.id.tv_next_prayer_name, calculation.activeName)
        views.setTextViewText(R.id.tv_next_prayer_time, "${calculation.displayTime} $tz")

        // Berikan highlight pill pada baris salat yang sedang aktif
        highlightPrayer(views, calculation.highlightName)

        // PendingIntent untuk membuka aplikasi saat widget atau tombol ditekan
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_open_app, pendingIntent)
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        manager.updateAppWidget(widgetId, views)

        // Jadwalkan auto-update tepat pada pergantian waktu salat berikutnya
        scheduleNextPrayerAlarm(context, calculation.minutesToNextTrigger)
    }

    /**
     * Jadwalkan alarm untuk update widget otomatis saat waktu salat berikutnya tiba.
     */
    private fun scheduleNextPrayerAlarm(context: Context, minutesUntilNext: Int) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val intent = Intent(context, PrayerWidgetProvider::class.java).apply {
                action = ACTION_UPDATE_WIDGET
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Trigger tepat saat waktu salat berikutnya + 2 detik buffer
            val triggerTimeMs = System.currentTimeMillis() + (minutesUntilNext * 60 * 1000L) + 2000L

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMs,
                    pendingIntent
                )
            } else {
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    triggerTimeMs,
                    pendingIntent
                )
            }
        } catch (_: Exception) {
            // Ignore jika security policy membatasi exact alarm
        }
    }

    /**
     * Berikan highlight pill hijau gelap pada baris waktu salat yang sedang aktif,
     * serta atur warna teks menjadi putih. Baris lainnya transparan dengan teks hijau gelap.
     */
    private fun highlightPrayer(views: RemoteViews, activeKey: String) {
        val darkGreen = Color.parseColor("#1B3D0D")
        val white = Color.WHITE

        val rows = listOf(
            Triple("subuh", R.id.row_subuh, Pair(R.id.tv_label_subuh, R.id.tv_subuh)),
            Triple("dzuhur", R.id.row_dzuhur, Pair(R.id.tv_label_dzuhur, R.id.tv_dzuhur)),
            Triple("ashar", R.id.row_ashar, Pair(R.id.tv_label_ashar, R.id.tv_ashar)),
            Triple("maghrib", R.id.row_maghrib, Pair(R.id.tv_label_maghrib, R.id.tv_maghrib)),
            Triple("isya", R.id.row_isya, Pair(R.id.tv_label_isya, R.id.tv_isya))
        )

        val target = activeKey.lowercase(Locale.getDefault())

        for ((name, rowId, textIds) in rows) {
            val (labelId, timeId) = textIds
            if (name == target) {
                views.setInt(rowId, "setBackgroundResource", R.drawable.active_prayer_row)
                views.setTextColor(labelId, white)
                views.setTextColor(timeId, white)
            } else {
                views.setInt(rowId, "setBackgroundResource", android.R.color.transparent)
                views.setTextColor(labelId, darkGreen)
                views.setTextColor(timeId, darkGreen)
            }
        }
    }
}
