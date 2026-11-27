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
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import java.util.*

/**
 * PrayerWidgetProvider — Android Home Screen Widget untuk MuslimHabit
 *
 * Mengimplementasikan konsep "Islamic Garden – Soft Green & Gold":
 * - Panel Kiri: Info sholat sekarang, jam digital TextClock, lokasi,
 *   maskot Nunu (membaca Al-Qur'an), dan tombol "Pantau Habit →".
 * - Panel Kanan: Jadwal 5 waktu sholat dengan indikator sholat berikutnya
 *   (badge emas "Berikutnya") dan sholat yang telah selesai (centang hijau).
 * - Mendukung 3 ukuran responsif:
 *   1. Small (2x2 / lebar < 220dp) -> prayer_widget_small.xml
 *   2. Medium (4x2 / standar)       -> prayer_widget_layout.xml
 *   3. Large (4x3 atau 4x4)         -> prayer_widget_large.xml
 */
class PrayerWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "com.muslimhabit.muslim_habit"
        const val ACTION_UPDATE_WIDGET = "com.muslimhabit.UPDATE_WIDGET"
        private const val ALARM_REQUEST_CODE = 8821

        /** Paksa refresh semua widget yang terpasang di launcher */
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

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_WIDGET ||
            intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action == Intent.ACTION_TIME_CHANGED ||
            intent.action == Intent.ACTION_TIMEZONE_CHANGED ||
            intent.action == "android.intent.action.TIME_SET"
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
        val badgeLabel: String,         // "Sekarang"
        val activeName: String,         // Nama salat yang sedang berlangsung (misal "Subuh")
        val nextPrayerName: String,     // Nama salat berikutnya (misal "Dzuhur")
        val nextPrayerTime: String,     // Jam salat berikutnya (misal "11:55")
        val displayTime: String,        // Jam salat aktif
        val highlightName: String,      // Nama salat yang di-highlight ("subuh", "dzuhur", dll)
        val passedPrayers: Set<String>, // Kumpulan salat yang sudah lewat hari ini
        val minutesToNextTrigger: Int   // Sisa menit menuju waktu salat berikutnya
    )

    /**
     * Menghitung status salat secara real-time berdasarkan jam perangkat saat ini:
     * - 00:00 - < Subuh     -> Sekarang Isya, Berikutnya Subuh
     * - Subuh - < Dzuhur    -> Sekarang Subuh, Berikutnya Dzuhur
     * - Dzuhur - < Ashar    -> Sekarang Dzuhur, Berikutnya Ashar
     * - Ashar - < Maghrib   -> Sekarang Ashar, Berikutnya Maghrib
     * - Maghrib - < Isya    -> Sekarang Maghrib, Berikutnya Isya
     * - Isya - 23:59        -> Sekarang Isya, Berikutnya Subuh
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
            // Sebelum Subuh (misal 03:00)
            nowMin < subuhMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Isya",
                    nextPrayerName = "Subuh",
                    nextPrayerTime = subuh,
                    displayTime = subuh,
                    highlightName = "subuh",
                    passedPrayers = emptySet(),
                    minutesToNextTrigger = (subuhMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Subuh (misal 04:35)
            nowMin < dzuhurMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Subuh",
                    nextPrayerName = "Dzuhur",
                    nextPrayerTime = dzuhur,
                    displayTime = subuh,
                    highlightName = "dzuhur",
                    passedPrayers = setOf("subuh"),
                    minutesToNextTrigger = (dzuhurMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Dzuhur (misal 12:15)
            nowMin < asharMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Dzuhur",
                    nextPrayerName = "Ashar",
                    nextPrayerTime = ashar,
                    displayTime = dzuhur,
                    highlightName = "ashar",
                    passedPrayers = setOf("subuh", "dzuhur"),
                    minutesToNextTrigger = (asharMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Ashar (misal 15:45)
            nowMin < maghribMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Ashar",
                    nextPrayerName = "Maghrib",
                    nextPrayerTime = maghrib,
                    displayTime = ashar,
                    highlightName = "maghrib",
                    passedPrayers = setOf("subuh", "dzuhur", "ashar"),
                    minutesToNextTrigger = (maghribMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Maghrib (misal 18:05)
            nowMin < isyaMin -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Maghrib",
                    nextPrayerName = "Isya",
                    nextPrayerTime = isya,
                    displayTime = maghrib,
                    highlightName = "isya",
                    passedPrayers = setOf("subuh", "dzuhur", "ashar", "maghrib"),
                    minutesToNextTrigger = (isyaMin - nowMin).coerceAtLeast(1)
                )
            }
            // Rentang Isya (misal 19:30 s/d 23:59)
            else -> {
                PrayerCalculation(
                    badgeLabel = "Sekarang",
                    activeName = "Isya",
                    nextPrayerName = "Subuh",
                    nextPrayerTime = subuh,
                    displayTime = isya,
                    highlightName = "subuh",
                    passedPrayers = setOf("subuh", "dzuhur", "ashar", "maghrib", "isya"),
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
        val city    = readString(prefs, "widget_city",    "Palembang")
        val tz      = readString(prefs, "widget_timezone", "WIB")

        val calculation = determinePrayerStatus(subuh, dzuhur, ashar, maghrib, isya)

        // PendingIntent untuk tombol "Pantau Habit" -> Navigasi ke Habits Tab
        val habitLaunchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(
                    "notification_payload",
                    "{\"id\":\"widget_habit\",\"title\":\"Habits\",\"body\":\"\",\"target\":\"habits\"}"
                )
                putExtra("route", "habits")
            }

        val habitPendingIntent = PendingIntent.getActivity(
            context,
            101,
            habitLaunchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // PendingIntent untuk widget root -> Buka aplikasi biasa
        val rootLaunchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val rootPendingIntent = PendingIntent.getActivity(
            context,
            100,
            rootLaunchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Dukungan responsif Android 12+ (API 31+) menggunakan SizeF map
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val smallViews = createViews(
                context, R.layout.prayer_widget_small,
                subuh, dzuhur, ashar, maghrib, isya, city, tz,
                calculation, habitPendingIntent, rootPendingIntent, isSmall = true
            )
            val mediumViews = createViews(
                context, R.layout.prayer_widget_layout,
                subuh, dzuhur, ashar, maghrib, isya, city, tz,
                calculation, habitPendingIntent, rootPendingIntent, isSmall = false
            )
            val largeViews = createViews(
                context, R.layout.prayer_widget_large,
                subuh, dzuhur, ashar, maghrib, isya, city, tz,
                calculation, habitPendingIntent, rootPendingIntent, isSmall = false
            )

            val viewsMap = mapOf(
                SizeF(100f, 100f) to smallViews,
                SizeF(220f, 100f) to mediumViews,
                SizeF(260f, 180f) to largeViews
            )
            manager.updateAppWidget(widgetId, RemoteViews(viewsMap))
        } else {
            // Android versi sebelumnya: tentukan layout berdasarkan opsi ukuran
            val options = manager.getAppWidgetOptions(widgetId)
            val minWidth = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0
            val minHeight = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0

            val layoutId = when {
                minWidth in 1..219 -> R.layout.prayer_widget_small
                minHeight >= 180 -> R.layout.prayer_widget_large
                else -> R.layout.prayer_widget_layout
            }

            val isSmall = (layoutId == R.layout.prayer_widget_small)
            val views = createViews(
                context, layoutId,
                subuh, dzuhur, ashar, maghrib, isya, city, tz,
                calculation, habitPendingIntent, rootPendingIntent, isSmall
            )
            manager.updateAppWidget(widgetId, views)
        }

        // Jadwalkan auto-update tepat pada waktu salat berikutnya
        scheduleNextPrayerAlarm(context, calculation.minutesToNextTrigger)
    }

    private fun createViews(
        context: Context,
        layoutId: Int,
        subuh: String,
        dzuhur: String,
        ashar: String,
        maghrib: String,
        isya: String,
        city: String,
        tz: String,
        calculation: PrayerCalculation,
        habitPendingIntent: PendingIntent?,
        rootPendingIntent: PendingIntent?,
        isSmall: Boolean
    ): RemoteViews {
        val views = RemoteViews(context.packageName, layoutId)

        // Set Data Header Kiri
        views.setTextViewText(R.id.tv_badge_label, calculation.badgeLabel)
        views.setTextViewText(R.id.tv_next_prayer_name, calculation.activeName)
        views.setTextViewText(R.id.tv_location, city)

        // Pasang aksi klik
        if (habitPendingIntent != null) {
            views.setOnClickPendingIntent(R.id.btn_open_app, habitPendingIntent)
        }
        if (rootPendingIntent != null) {
            views.setOnClickPendingIntent(R.id.widget_root, rootPendingIntent)
        }

        if (isSmall) {
            // Small layout: tampilkan banner sholat berikutnya
            views.setTextViewText(
                R.id.tv_small_next_banner,
                "Berikutnya: ${calculation.nextPrayerName} ${calculation.nextPrayerTime}"
            )
        } else {
            // Medium & Large layout: pasang data 5 waktu sholat pada panel kanan
            views.setTextViewText(R.id.tv_subuh,   subuh)
            views.setTextViewText(R.id.tv_dzuhur,  dzuhur)
            views.setTextViewText(R.id.tv_ashar,   ashar)
            views.setTextViewText(R.id.tv_maghrib, maghrib)
            views.setTextViewText(R.id.tv_isya,    isya)

            // Atur status centang selesai dan badge berikutnya untuk masing-masing waktu sholat
            applyPrayerRowStatus(
                views = views,
                rowId = R.id.row_subuh,
                checkId = R.id.iv_check_subuh,
                badgeId = R.id.tv_badge_subuh,
                prayerKey = "subuh",
                calculation = calculation
            )

            applyPrayerRowStatus(
                views = views,
                rowId = R.id.row_dzuhur,
                checkId = R.id.iv_check_dzuhur,
                badgeId = R.id.tv_badge_dzuhur,
                prayerKey = "dzuhur",
                calculation = calculation
            )

            applyPrayerRowStatus(
                views = views,
                rowId = R.id.row_ashar,
                checkId = R.id.iv_check_ashar,
                badgeId = R.id.tv_badge_ashar,
                prayerKey = "ashar",
                calculation = calculation
            )

            applyPrayerRowStatus(
                views = views,
                rowId = R.id.row_maghrib,
                checkId = R.id.iv_check_maghrib,
                badgeId = R.id.tv_badge_maghrib,
                prayerKey = "maghrib",
                calculation = calculation
            )

            applyPrayerRowStatus(
                views = views,
                rowId = R.id.row_isya,
                checkId = R.id.iv_check_isya,
                badgeId = R.id.tv_badge_isya,
                prayerKey = "isya",
                calculation = calculation
            )
        }

        return views
    }

    /**
     * Mengatur visual indikator pada baris jadwal sholat:
     * 1. Jika sudah lewat: tampilkan centang hijau (@drawable/ic_widget_check).
     * 2. Jika sholat berikutnya: tampilkan badge emas (@drawable/badge_berikutnya_bg)
     *    dan berikan highlight background (@drawable/row_next_highlight_bg).
     * 3. Jika belum tiba: sembunyikan keduanya dan gunakan background transparan.
     */
    private fun applyPrayerRowStatus(
        views: RemoteViews,
        rowId: Int,
        checkId: Int,
        badgeId: Int,
        prayerKey: String,
        calculation: PrayerCalculation
    ) {
        val isPassed = calculation.passedPrayers.contains(prayerKey)
        val isNext = calculation.highlightName.equals(prayerKey, ignoreCase = true)

        if (isPassed) {
            views.setViewVisibility(checkId, View.VISIBLE)
            views.setViewVisibility(badgeId, View.GONE)
            views.setInt(rowId, "setBackgroundColor", Color.TRANSPARENT)
        } else if (isNext) {
            views.setViewVisibility(checkId, View.GONE)
            views.setViewVisibility(badgeId, View.VISIBLE)
            views.setInt(rowId, "setBackgroundResource", R.drawable.row_next_highlight_bg)
        } else {
            views.setViewVisibility(checkId, View.GONE)
            views.setViewVisibility(badgeId, View.GONE)
            views.setInt(rowId, "setBackgroundColor", Color.TRANSPARENT)
        }
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
}
