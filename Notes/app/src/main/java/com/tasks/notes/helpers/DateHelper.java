package com.tasks.notes.helpers;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.ISODateTimeFormat;

public class DateHelper {
    public final static DateTimeFormatter ISO8601_DATE_FORMAT =
            ISODateTimeFormat.dateTimeNoMillis();

    public final static DateTimeFormatter HUMAN_READABLE_DATE_FORMAT =
            DateTimeFormat.forPattern("E, d MMM yyyy");

    public static int compareDates(String s1, String s2) {
        DateTime d1 = new DateTime(s1).withTime(0, 0, 0, 0);
        DateTime d2 = new DateTime(s2).withTime(0, 0, 0, 0);
        return d1.compareTo(d2);
    }

    public static boolean dateBefore(String s1, String s2) {
        return compareDates(s1, s2) <= 0;
    }
}
