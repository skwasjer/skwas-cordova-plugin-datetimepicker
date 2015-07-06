package com.skwas.cordova.datetimepicker;

import java.lang.reflect.Method;
import java.util.Calendar;
import java.util.Locale;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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

		if (action.equals("show"))
			return show(args, callbackContext);
		return false;
	}

	public synchronized boolean show(final JSONArray data, final CallbackContext callbackContext) {
		final Calendar c = Calendar.getInstance();
		final Runnable runnable;
		final Context currentCtx = cordova.getActivity();
		final DateTimePicker datePickerPlugin = this;


		String action = "date";


		/*
		 * Parse information from data parameter and where possible, override
		 * above date fields
		 */
		int month = -1, day = -1, year = -1, hour = -1, min = -1;
		int minuteInterval = 1;
		try {
			JSONObject obj = data.getJSONObject(0);
			action = obj.getString("mode");

			String sMinuteInterval = obj.getString("minuteInterval");
			if (sMinuteInterval != null && sMinuteInterval != "")
				minuteInterval = Integer.parseInt(sMinuteInterval);

			String optionDate = obj.getString("date");

			String[] datePart = optionDate.split("/");
			month = Integer.parseInt(datePart[0]);
			day = Integer.parseInt(datePart[1]);
			year = Integer.parseInt(datePart[2]);
			hour = Integer.parseInt(datePart[3]);
			min = Integer.parseInt(datePart[4]);


			/* currently not handled in Android */
			// boolean optionAllowOldDates = obj.getBoolean("allowOldDates");

		} catch (JSONException e) {
			e.printStackTrace();
		}


		// By default initalize these fields to 'now'
		final int mYear = year == -1 ? c.get(Calendar.YEAR) : year;
		final int mMonth = month == -1 ? c.get(Calendar.MONTH) : month - 1;
		final int mDay = day == -1 ? c.get(Calendar.DAY_OF_MONTH) : day;
		final int mHour = hour == -1 ? c.get(Calendar.HOUR_OF_DAY) : hour;
		final int mMinutes = min == -1 ? c.get(Calendar.MINUTE) : min;
		final int mMinuteInterval = minuteInterval;
		final String sAction = action;


		if (ACTION_TIME.equalsIgnoreCase(action)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final TimeSetListener timeSetListener = new TimeSetListener(datePickerPlugin, callbackContext);
					final DurationTimePickerDialog timeDialog = new DurationTimePickerDialog(
							currentCtx, timeSetListener, mHour, mMinutes, true, mMinuteInterval);

					timeDialog.setCancelable(true);
					timeDialog.setCanceledOnTouchOutside(false);

					timeDialog.show();
				}
			};


		} else if (ACTION_DATE.equalsIgnoreCase(action) || ACTION_CALENDAR.equalsIgnoreCase(action)) {
			runnable = new Runnable() {
				@Override
				public void run() {
					final DateSetListener dateSetListener = new DateSetListener(datePickerPlugin, callbackContext);
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
						catch (Exception e) {
							e.printStackTrace();
						}
					}

					dateDialog.show();
				}
			};


		} else {
			Log.d(pluginName, "Unknown action. Only 'date' or 'time' are valid actions");
			return false;
		}


		cordova.getActivity().runOnUiThread(runnable);
		return true;
	}


	private final class DateSetListener implements OnDateSetListener {
		@SuppressWarnings("unused")
		private final DateTimePicker datePickerPlugin;
		private final CallbackContext callbackContext;

		private DateSetListener(DateTimePicker datePickerPlugin, CallbackContext callbackContext) {
			this.datePickerPlugin = datePickerPlugin;
			this.callbackContext = callbackContext;
		}


		/**
		 * Return a string containing the date in the format YYYY/MM/DD
		 */
		@Override
		public void onDateSet(final DatePicker view, final int year, final int monthOfYear, final int dayOfMonth) {
			String returnDate = String.format(new Locale("en"), "%02d/%02d/%02d",
					year,
					monthOfYear + 1,
					dayOfMonth
					);

			PluginResult res = new PluginResult(PluginResult.Status.OK, returnDate);
			res.setKeepCallback(false);
			callbackContext.sendPluginResult(res);
		}
	}

	private final class TimeSetListener implements OnTimeSetListener {
		@SuppressWarnings("unused")
		private final DateTimePicker datePickerPlugin;
		private final CallbackContext callbackContext;

		private TimeSetListener(DateTimePicker datePickerPlugin, CallbackContext callbackContext) {
			this.datePickerPlugin = datePickerPlugin;
			this.callbackContext = callbackContext;
		}


		/**
		 * Return the current date with the time modified as it was set in the
		 * time picker.
		 */
		@Override
		public void onTimeSet(final TimePicker view, final int hourOfDay, final int minute) {
			Calendar c = Calendar.getInstance();
			c.set(Calendar.HOUR_OF_DAY, hourOfDay);
			c.set(Calendar.MINUTE, minute);
			c.set(Calendar.MILLISECOND, 0);

			String returnDate = String.format(new Locale("en"), "%02d/%02d/%02d %02d:%02d",
					c.get(Calendar.YEAR),
					c.get(Calendar.MONTH) + 1,
					c.get(Calendar.DAY_OF_MONTH),
					c.get(Calendar.HOUR_OF_DAY),
					c.get(Calendar.MINUTE)
					);

			PluginResult res = new PluginResult(PluginResult.Status.OK, returnDate);
			res.setKeepCallback(false);
			callbackContext.sendPluginResult(res);
		}
	}


}
