package com.skillswap.utils;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

/** Formateo de fechas en espanol. */
public final class DateUtils {

    private static final Locale ES = new Locale("es", "PE");

    private DateUtils() {
    }

    public static String formatDate(long millis) {
        if (millis <= 0) return "--";
        return new SimpleDateFormat("dd MMM yyyy", ES).format(new Date(millis));
    }

    public static String formatDateTime(long millis) {
        if (millis <= 0) return "--";
        return new SimpleDateFormat("dd MMM yyyy · HH:mm", ES).format(new Date(millis));
    }

    public static String formatTime(long millis) {
        if (millis <= 0) return "--";
        return new SimpleDateFormat("HH:mm", ES).format(new Date(millis));
    }

    public static String formatDayHeader(long millis) {
        if (isToday(millis)) return "Hoy";
        if (isYesterday(millis)) return "Ayer";
        return new SimpleDateFormat("EEEE dd 'de' MMMM", ES).format(new Date(millis));
    }

    /** "hace 5 min", "hace 2 h", "hace 3 d", o la fecha. */
    public static String timeAgo(long millis) {
        if (millis <= 0) return "";
        long diff = System.currentTimeMillis() - millis;
        if (diff < TimeUnit.MINUTES.toMillis(1)) return "ahora";
        if (diff < TimeUnit.HOURS.toMillis(1)) {
            long m = TimeUnit.MILLISECONDS.toMinutes(diff);
            return "hace " + m + " min";
        }
        if (diff < TimeUnit.DAYS.toMillis(1)) {
            long h = TimeUnit.MILLISECONDS.toHours(diff);
            return "hace " + h + (h == 1 ? " hora" : " horas");
        }
        long d = TimeUnit.MILLISECONDS.toDays(diff);
        if (d < 7) return "hace " + d + (d == 1 ? " día" : " días");
        if (d < 30) {
            long w = d / 7;
            return "hace " + w + (w == 1 ? " semana" : " semanas");
        }
        return formatDate(millis);
    }

    /** Etiqueta corta para listas de chat. */
    public static String chatStamp(long millis) {
        if (millis <= 0) return "";
        if (isToday(millis)) return formatTime(millis);
        if (isYesterday(millis)) return "Ayer";
        return new SimpleDateFormat("dd/MM", ES).format(new Date(millis));
    }

    public static String daysLeft(long deadline) {
        long diff = deadline - System.currentTimeMillis();
        if (diff <= 0) return "Finalizado";
        long d = TimeUnit.MILLISECONDS.toDays(diff);
        if (d == 0) return "Último día";
        return d + (d == 1 ? " día restante" : " días restantes");
    }

    public static long plusDays(int days) {
        Calendar c = Calendar.getInstance();
        c.add(Calendar.DAY_OF_YEAR, days);
        return c.getTimeInMillis();
    }

    public static boolean isToday(long millis) {
        return sameDay(millis, System.currentTimeMillis());
    }

    public static boolean isYesterday(long millis) {
        Calendar c = Calendar.getInstance();
        c.add(Calendar.DAY_OF_YEAR, -1);
        return sameDay(millis, c.getTimeInMillis());
    }

    public static boolean sameDay(long a, long b) {
        Calendar c1 = Calendar.getInstance();
        Calendar c2 = Calendar.getInstance();
        c1.setTimeInMillis(a);
        c2.setTimeInMillis(b);
        return c1.get(Calendar.YEAR) == c2.get(Calendar.YEAR)
                && c1.get(Calendar.DAY_OF_YEAR) == c2.get(Calendar.DAY_OF_YEAR);
    }
}
