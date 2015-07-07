package com.skwas.cordova.datetimepicker;

import java.lang.reflect.Method;
import java.lang.IndexOutOfBoundsException;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.TimePickerDialog.OnTimeSetListener;
import android.content.Context;
import android.util.Log;
import android.widget.DatePicker;
import android.widget.TimePicker;

public class DateTimePicker extends CordovaPlugin {


	private static final String ACTION_DATE = "date";
	private static final String ACTION_CALENDAR = "calendar";
	private static final String ACTION_TIME = "time";
	private final String pluginName = "DateTimePicker";

	private Activity _activity;
	
	@Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        
        _activity = cordova.getActivity();        
    } 
	
	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
		Log.d(pluginName, "DateTimePicker called with options: " + args);

		if (action.equals("show")) {
			show(args, callbackContext);
			return true;
		}
		return false;
	}

	public synchronized boolean show(final JSONArray data, final CallbackContext callbackContext) {
		Calendar c = GregorianCalendar.getInstance();
		final Runnable runnable;
		final Context currentCtx = cordova.getActivity();
		final DateTimePicker datePickerPlugin = this;

		int minuteInterval = 1;
		String action = "date";

		// Parse information from data parameter.
		if (data.length() == 1) {
			JSONObject obj = null;
			try {
				obj = data.getJSONObject(0);
				
				// Get mode.
				action = obj.getString("mode");
	
				// Get interval for time picker.
				String sMinuteInterval = obj.getString("minuteInterval");
				if (sMinuteInterval != null && sMinuteInterval != "")
					minuteInterval = Integer.parseInt(sMinuteInterval);
	
				// Get date/time.
				String date = obj.getString("date");
				if (date != null && date != "") {
					try {
						// Attempt to parse with ISO 8601.
						c = ISO8601.toCalendar(date);
					}
					catch (ParseException ex) {
						// If failed, try again using MS JSON date format (returns null if not succesful).
						c = MicrosoftJSONDate.toCalendar(date);
						if (c == null) {
							callbackContext.error("Failed to parse date/time: " + date);
							return false;
						}
					}
				}
	
				// Currently not handled in Android...
				// boolean optionAllowOldDates = obj.getBoolean("allowOldDates");
			}
			catch (JSONException ex) {
//				ex.printStackTrace();
				if (obj == null)
					callbackContext.error("Failed to load JSON options." + ex.getMessage());
				else
					callbackContext.error("Invalid property in JSON options: " + obj.toString());
				return false;
			}
		}


		// Get final values.
		final int mYear = c.get(Calendar.YEAR);
		final int mMonth = c.get(Calendar.MONTH);
		final int mDay = c.get(Calendar.DAY_OF_MONTH);
		final int mHour = c.get(Calendar.HOUR_OF_DAY);
		final int mMinutes = c.get(Calendar.MINUTE);
		final int mMinuteInterval = minuteInterval;
		final String sAction = action;
		final Calendar fCalendar = c;


		if (ACTION_TIME.equalsIgnoreCase(action)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final TimeSetListener timeSetListener = new TimeSetListener(datePickerPlugin, callbackContext, fCalendar);
					final DurationTimePickerDialog timeDialog = new DurationTimePickerDialog(
							currentCtx, timeSetListener, mHour, mMinutes, true, mMinuteInterval);

					timeDialog.setCancelable(true);
					timeDialog.setCanceledOnTouchOutside(false);

					timeDialog.show();
				}
			};


		} 
		else if (ACTION_DATE.equalsIgnoreCase(action) || ACTION_CALENDAR.equalsIgnoreCase(action)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final DateSetListener dateSetListener = new DateSetListener(datePickerPlugin, callbackContext, fCalendar);
					final DatePickerDialog dateDialog = new DatePickerDialog(
							currentCtx, dateSetListener, mYear, mMonth, mDay);

					dateDialog.setCancelable(true);
					dateDialog.setCanceledOnTouchOutside(false);

					if (ACTION_CALENDAR.equalsIgnoreCase(sAction)) {
						try
						{
							Method getDatePicker = DatePickerDialog.class.getMethod("getDatePicker");
							DatePicker dp = (DatePicker)getDatePicker.invoke(dateDialog, (Object[])null);

							Method setCalendarViewShown = DatePicker.class.getMethod("setCalendarViewShown", boolean.class);
							setCalendarViewShown.invoke(dp, true);
							Method setSpinnersShown = DatePicker.class.getMethod("setSpinnersShown", boolean.class);
							setSpinnersShown.invoke(dp, false);
						}
						catch (Exception ex) {
							//ex.printStackTrace();
						}
					}

					dateDialog.show();
				}
			};


		}
		else {
			callbackContext.error("Unknown action. Only 'date' or 'time' are valid actions");
			return false;
		}


		cordova.getActivity().runOnUiThread(runnable);
		return true;
	}


	private final class DateSetListener implements OnDateSetListener {
		@SuppressWarnings("unused")
		private final DateTimePicker datePickerPlugin;
		private final CallbackContext callbackContext;
		private final Calendar calendar;

		private DateSetListener(DateTimePicker datePickerPlugin, CallbackContext callbackContext, Calendar calendar) {
			this.datePickerPlugin = datePickerPlugin;
			this.callbackContext = callbackContext;
			this.calendar = calendar;
		}


		/**
		 * Return a string containing the date in the format YYYY/MM/DD
		 */
		@Override
		public void onDateSet(final DatePicker view, final int year, final int monthOfYear, final int dayOfMonth) {
			calendar.set(Calendar.YEAR, year);
			calendar.set(Calendar.MONTH, monthOfYear);
			calendar.set(Calendar.DAY_OF_MONTH, dayOfMonth);
	
			Date date = calendar.getTime();
			Long millis = Long.valueOf(date.getTime());
			try {
				callbackContext.success(JSONObject.numberToString(millis));
			}
			catch (JSONException ex) {
				callbackContext.error("Failed to get date.");
			}
		}
	}

	private final class TimeSetListener implements OnTimeSetListener {
		@SuppressWarnings("unused")
		private final DateTimePicker datePickerPlugin;
		private final CallbackContext callbackContext;
		private final Calendar calendar;

		private TimeSetListener(DateTimePicker datePickerPlugin, CallbackContext callbackContext, Calendar calendar) {
			this.datePickerPlugin = datePickerPlugin;
			this.callbackContext = callbackContext;
			this.calendar = calendar;
		}


		/**
		 * Return the current date with the time modified as it was set in the
		 * time picker.
		 */
		@Override
		public void onTimeSet(final TimePicker view, final int hourOfDay, final int minute) {
			calendar.set(Calendar.HOUR_OF_DAY, hourOfDay);
			calendar.set(Calendar.MINUTE, minute);
			calendar.set(Calendar.SECOND, 0);
			calendar.set(Calendar.MILLISECOND, 0);
			
			Date date = calendar.getTime();
			Long millis = Long.valueOf(date.getTime());
			try {
				callbackContext.success(JSONObject.numberToString(millis));
			}
			catch (JSONException ex) {
				callbackContext.error("Failed to get time.");
			}
		}
	}
	
	private static class MicrosoftJSONDate {
		
		public static Calendar toCalendar(final String jsonDate) {
			Pattern regex = Pattern.compile("/?Date\\((\\d+)(([+-]?)(\\d{2})(\\d{2}))?\\)/");
			Matcher match = regex.matcher(jsonDate);
			if (match.find()) {
				Long ticks = Long.valueOf(match.group(1));
				// TODO: implement UTC offset from groups 3, 4, 5 (+, HH, mm)
				Calendar calendar = GregorianCalendar.getInstance();
				calendar.setTime(new Date(ticks.longValue()));
				return calendar;
			}
			return null;
		}		
	}
	
	// http://stackoverflow.com/questions/2201925/converting-iso-8601-compliant-string-to-java-util-date
	/**
	 * Helper class for handling a most common subset of ISO 8601 strings
	 * (in the following format: "2008-03-01T13:00:00+01:00"). It supports
	 * parsing the "Z" timezone, but many other less-used features are
	 * missing.
	 */
	private static class ISO8601 {
	    /** Transform Calendar to ISO 8601 string. */
	    public static String fromCalendar(final Calendar calendar) {
	        Date date = calendar.getTime();
	        String formatted = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
	            .format(date);
	        return formatted.substring(0, 22) + ":" + formatted.substring(22);
	    }

	    /** Get current date and time formatted as ISO 8601 string. */
	    public static String now() {
	        return fromCalendar(GregorianCalendar.getInstance());
	    }

	    /** Transform ISO 8601 string to Calendar. */
	    public static Calendar toCalendar(final String iso8601string)
	            throws ParseException {
	        Calendar calendar = GregorianCalendar.getInstance();
	        String s = iso8601string.replace("Z", "+00:00");
	        try {
	            s = s.substring(0, 22) + s.substring(23);  // to get rid of the ":"
	        } catch (IndexOutOfBoundsException e) {
	            throw new ParseException("Invalid length", 0);
	        }
	        Date date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ").parse(s);
	        calendar.setTime(date);
	        return calendar;
	    }
	}
}
