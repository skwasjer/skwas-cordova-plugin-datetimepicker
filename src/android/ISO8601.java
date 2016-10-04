package com.skwas.cordova.datetimepicker;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * Helpers for handling ISO 8601 date stringsin the following formats:
 *      "2008-03-01T13:00:00+01:00"
 *      "2008-03-01T13:00:00Z" (UTC)
 */
final class ISO8601 {

    private ISO8601() {
    }

    /**
     * Transform Calendar to ISO 8601 string.
     */
    public static String toString(final Calendar calendar) {
        return toString(calendar.getTime());
    }

    /**
     * Transform Date to ISO 8601 string.
     */
    public static String toString(final Date date) {
        String formatted = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                .format(date);
        // Insert colon between hours/minutes of timezone to conform to ISO 8601.
        Integer posTzHourMin = formatted.length() - 2;
        return formatted.substring(0, posTzHourMin) + ":" + formatted.substring(posTzHourMin);
    }

    /**
     * Parse ISO 8601 string to Calendar.
     */
    public static Calendar toCalendar(final String iso8601string)
            throws ParseException {
        Calendar calendar = GregorianCalendar.getInstance();
        calendar.setTime(toDate(iso8601string));
        return calendar;
    }

    /**
     * Parse ISO 8601 string to Date.
     */
    public static Date toDate(final String iso8601string)
            throws ParseException {
        Calendar calendar = GregorianCalendar.getInstance();
        String s = iso8601string.replace("Z", "+00:00");
//	        try {
//	            s = s.substring(0, 22) + s.substring(23);  // to get rid of the ":"
//	        } catch (IndexOutOfBoundsException e) {
//	            throw new ParseException("Invalid length", 0);
//	        }
        Date date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").parse(s);
        calendar.setTime(date);
        return date;
    }
}
