package com.skwas.cordova.datetimepicker;

import java.lang.reflect.Method;
import java.text.ParseException;
import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.TimePickerDialog.OnTimeSetListener;
import android.support.annotation.NonNull;
import android.util.Log;
import android.widget.DatePicker;
import android.widget.TimePicker;

public class DateTimePicker extends CordovaPlugin {

	/**
	 * Options for date picker.
	 *
	 * Note that not all options are supported, they are here to match the options across all platforms.
	 */
	private class DateTimePickerOptions {
		@NonNull
		public String mode = "date";
		public Date date = new Date();
		public boolean allowOldDates = true;
		public boolean allowFutureDates = true;
		public int minuteInterval = 1;
		public String locale = "EN";
		public String okText = "Select";
		public String cancelText = "Cancel";

		public DateTimePickerOptions () {
		}

		public DateTimePickerOptions (JSONObject obj) throws JSONException {
			this();

			// Get mode.
			if (obj.has("mode")) {
				mode = obj.getString("mode");
			}

			// Get interval for time picker.
			if (obj.has("minuteInterval")) {
				minuteInterval = obj.getInt("minuteInterval");
			}

			// Get date/time.
			if (obj.has("date")) {
				String sDate = obj.getString("date");
				if (sDate != null && sDate != "") {
					try {
						// Attempt to parse with ISO 8601.
						date = ISO8601.toDate(sDate);
					} catch (ParseException ex) {
						throw new JSONException(ex.getMessage());
					}
				}
			}

			// Get date from ticks.
			if (obj.has("ticks")) {
				date = new Date(obj.getLong("ticks"));
			}

			// Other values currently not handled/supported in Android...
		}
	}

	private static final String MODE_DATE = "date";
	private static final String MODE_TIME = "time";
	private static final String MODE_DATETIME = "datetime";
	private static final String TAG = "DateTimePicker";

	private Activity _activity;
	
	@Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        
        _activity = cordova.getActivity();
    } 
	
	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
		Log.d(TAG, "DateTimePicker called with options: " + args);

		if (action.equals("show")) {
			show(args, callbackContext);
			return true;
		}
		return false;
	}

	/**
	 * Plugin 'show' method.
	 * @param data The JSON arguments passed to the method.
	 * @param callbackContext The callback context.
     * @return true when the dialog is shown
     */
	public synchronized boolean show(final JSONArray data, final CallbackContext callbackContext) {
		final Runnable runnable;
		final DateTimePicker datePickerPlugin = this;
		final DateTimePickerOptions options;

		// Parse options from data parameter.
		if (data.length() == 1) {
			try {
				options = new DateTimePickerOptions(data.getJSONObject(0));
			}
			catch (JSONException ex) {
				callbackContext.error("Failed to load JSON options. " + ex.getMessage());
				return false;
			}
		}
		else {
			// Defaults.
			options = new DateTimePickerOptions();
		}

		// Set calendar.
		final Calendar calendar = GregorianCalendar.getInstance();
		calendar.setTime(options.date);

		if (MODE_TIME.equalsIgnoreCase(options.mode)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final TimeSetListener timeSetListener = new TimeSetListener(datePickerPlugin, callbackContext, calendar);
					showDialog(new DurationTimePickerDialog(
							_activity,
							timeSetListener,
							calendar.get(Calendar.HOUR_OF_DAY),
							calendar.get(Calendar.MINUTE),
							true,
							options.minuteInterval
					));
				}
			};
		} 
		else if (MODE_DATE.equalsIgnoreCase(options.mode) || MODE_DATETIME.equalsIgnoreCase(options.mode)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final DateSetListener dateSetListener = new DateSetListener(datePickerPlugin, callbackContext, calendar);
					final DatePickerDialog dateDialog = new DatePickerDialog(
							_activity,
							dateSetListener,
							calendar.get(Calendar.YEAR),
							calendar.get(Calendar.MONTH),
							calendar.get(Calendar.DAY_OF_MONTH)
					);

					if (MODE_DATETIME.equalsIgnoreCase(options.mode)) {
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

					showDialog(dateDialog);
				}
			};
		}
		else {
			callbackContext.error("Unknown mode. Only 'date', 'time' and 'datetime' are valid modes.");
			return false;
		}

		cordova.getActivity().runOnUiThread(runnable);
		return true;
	}

	/**
	 * Show the picker dialog.
	 * @param dialog
     */
	private static void showDialog(AlertDialog dialog) {
		dialog.setCancelable(true);
		dialog.setCanceledOnTouchOutside(false);

		dialog.show();
	}

	/**
	 * Success callback for when a new date or time is set.
	 * @param calendar The calendar with the new date and/or time.
	 * @param callbackContext The callback context.
     */
	private static void onCalendarSet(Calendar calendar, CallbackContext callbackContext) {
		try {
			JSONObject result = new JSONObject();
			Date date = calendar.getTime();
			// Provide the date in ISO 8601.
			result.put("date", ISO8601.toString(date));
			// Due to lack of browser/user agent support for ISO 8601 parsing, we also provide ticks since epoch.
			// The Javascript date constructor works far more reliably this way, even on old JS engines.
			result.put("ticks", date.getTime());
			callbackContext.success(result);
		}
		catch (JSONException ex) {
			callbackContext.error("Failed to serialize date. " + calendar.getTime().toString());
		}
	}

	/**
	 * Listener for the date dialog.
	 */
	private final class DateSetListener implements OnDateSetListener {
		private final DateTimePicker mDatePickerPlugin;
		private final CallbackContext mCallbackContext;
		private final Calendar mCalendar;

		private DateSetListener(DateTimePicker datePickerPlugin, CallbackContext callbackContext, Calendar calendar) {
			mDatePickerPlugin = datePickerPlugin;
			mCallbackContext = callbackContext;
			mCalendar = calendar;
		}

		@Override
		public void onDateSet(final DatePicker view, final int year, final int monthOfYear, final int dayOfMonth) {
			mCalendar.set(Calendar.YEAR, year);
			mCalendar.set(Calendar.MONTH, monthOfYear);
			mCalendar.set(Calendar.DAY_OF_MONTH, dayOfMonth);

			mDatePickerPlugin.onCalendarSet(mCalendar, mCallbackContext);
		}
	}

	/**
	 * Listener for the time dialog.
	 */
	private final class TimeSetListener implements OnTimeSetListener {
		private final DateTimePicker mDatePickerPlugin;
		private final CallbackContext mCallbackContext;
		private final Calendar mCalendar;

		private TimeSetListener(DateTimePicker datePickerPlugin, CallbackContext callbackContext, Calendar calendar) {
			mDatePickerPlugin = datePickerPlugin;
			mCallbackContext = callbackContext;
			mCalendar = calendar;
		}

		@Override
		public void onTimeSet(final TimePicker view, final int hourOfDay, final int minute) {
			mCalendar.set(Calendar.HOUR_OF_DAY, hourOfDay);
			mCalendar.set(Calendar.MINUTE, minute);
			mCalendar.set(Calendar.SECOND, 0);
			mCalendar.set(Calendar.MILLISECOND, 0);

			mDatePickerPlugin.onCalendarSet(mCalendar, mCallbackContext);
		}
	}
}
