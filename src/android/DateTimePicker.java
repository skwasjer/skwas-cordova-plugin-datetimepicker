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
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.TimePickerDialog.OnTimeSetListener;
import android.content.Context;
import android.util.Log;
import android.widget.DatePicker;
import android.widget.TimePicker;

import javax.annotation.Nonnull;

public class DateTimePicker extends CordovaPlugin {

	/**
	 * Options for date picker.
	 *
	 * Note that not all options are supported, they are here to match the options across all platforms.
	 */
	private class DateTimePickerOptions {
		@Nonnull
		public String mode = "date";
		public Date date = new Date();
		public Boolean allowOldDates = true;
		public Boolean allowFutureDates = true;
		public Integer minuteInterval = 1;
		public String locale = "EN";
		public String okText = "Select";
		public String cancelText = "Cancel";
	}

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
		final Runnable runnable;
		final DateTimePicker datePickerPlugin = this;
		final DateTimePickerOptions options = new DateTimePickerOptions();

		// Parse information from data parameter.
		if (data.length() == 1) {
			JSONObject obj = null;
			try {
				obj = data.getJSONObject(0);
				
				// Get mode.
				if (obj.has("mode")) {
					options.mode = obj.getString("mode");
				}
	
				// Get interval for time picker.
				if (obj.has("minuteInterval")) {
					options.minuteInterval = obj.getInt("minuteInterval");
				}

				// Get date/time.
				if (obj.has("date")) {
					String date = obj.getString("date");
					if (date != null && date != "") {
						try {
							// Attempt to parse with ISO 8601.
							options.date = ISO8601.toDate(date);
						} catch (ParseException ex) {
							callbackContext.error("Failed to parse date/time: " + date);
							return false;
						}
					}
				}
	
				// Other values currently not handled/supported in Android...
			}
			catch (JSONException ex) {
				if (obj == null)
					callbackContext.error("Failed to load JSON options." + ex.getMessage());
				else
					callbackContext.error("Invalid property in JSON options: " + obj.toString());
				return false;
			}
		}


		// Set calendar.
		final Calendar calendar = GregorianCalendar.getInstance();
		calendar.setTime(options.date);

		if (ACTION_TIME.equalsIgnoreCase(options.mode)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final TimeSetListener timeSetListener = new TimeSetListener(datePickerPlugin, callbackContext, calendar);
					final DurationTimePickerDialog timeDialog = new DurationTimePickerDialog(
							_activity,
							timeSetListener,
							calendar.get(Calendar.HOUR_OF_DAY),
							calendar.get(Calendar.MINUTE),
							true,
							options.minuteInterval
					);

					timeDialog.setCancelable(true);
					timeDialog.setCanceledOnTouchOutside(false);

					timeDialog.show();
				}
			};
		} 
		else if (ACTION_DATE.equalsIgnoreCase(options.mode) || ACTION_CALENDAR.equalsIgnoreCase(options.mode)) {
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

					dateDialog.setCancelable(true);
					dateDialog.setCanceledOnTouchOutside(false);

					if (ACTION_CALENDAR.equalsIgnoreCase(options.mode)) {
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
			callbackContext.error("Unknown mode. Only 'date' or 'time' are valid actions");
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
}
