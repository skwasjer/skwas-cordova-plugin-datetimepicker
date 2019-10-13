package com.skwas.cordova.datetimepicker;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.widget.DatePicker;
import android.widget.NumberPicker;
import android.widget.TimePicker;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

public class TimePickerDialog extends android.app.TimePickerDialog {
	private final OnTimeSetListener mCallback;
	private final int mIncrement;
	private final int mHourOfDay, mMinute;
	private TimePicker mTimePicker;
	private CharSequence mTitle;
	// In Honeycomb upwards, we have access to the time picker. In Lollipop, the time picker has changed to a radial picker, and we can't change the interval.
	private boolean mIsSupported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB;

	public TimePickerDialog(Context context, OnTimeSetListener callBack, int hourOfDay, int minute, boolean is24HourView, int increment) {
		super(context, callBack, hourOfDay, minute, is24HourView);

		mCallback = callBack;

		mIncrement = increment;
		mHourOfDay = hourOfDay;
		mMinute = minute;
	}

	public TimePickerDialog(Context context, int themeResId, OnTimeSetListener callBack, int hourOfDay, int minute, boolean is24HourView, int increment) {
		super(context, themeResId, callBack, hourOfDay, minute, is24HourView);

		mCallback = callBack;

		mIncrement = increment;
		mHourOfDay = hourOfDay;
		mMinute = minute;
	}

	@Override
	public void onClick(DialogInterface dialog, int which) {
		switch (which) {
			case BUTTON_POSITIVE:
				if (mIsSupported && mCallback != null && mTimePicker != null) {
					mTimePicker.clearFocus();
					// Since M, getCurrentHour() and getCurrentMinute() are deprecated, but we won't get here as it is not supported by our code.
					mCallback.onTimeSet(mTimePicker, mTimePicker.getCurrentHour(), mTimePicker.getCurrentMinute() * mIncrement);
					return;
				}
				break;

			case BUTTON_NEGATIVE:
				cancel();
				return;
		}
		super.onClick(dialog, which);
	}

	@Override
	public void onTimeChanged(TimePicker view, int hourOfDay, int minute) {
		super.onTimeChanged(view, hourOfDay, mIsSupported ? minute * mIncrement : minute);

		// If set, enforce title.
		if (!TextUtils.isEmpty(mTitle)) {
			setTitle(mTitle);
		}
	}

	@Override
	protected void onStop() {
		// Do nothing.
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Ignore on SDK < 11.
		if (!mIsSupported) return;

		try {
			Class<?> rClass = Class.forName("com.android.internal.R$id");
			Field timePicker = rClass.getField("timePicker");
			mTimePicker = (TimePicker) findViewById(timePicker.getInt(null));
			Field m = rClass.getField("minute");

			NumberPicker mMinuteSpinner = (NumberPicker) mTimePicker.findViewById(m.getInt(null));
			if (mMinuteSpinner == null) {
				mTimePicker = null;
				mIsSupported = false;
			}

			Class<?> mmsp = mMinuteSpinner.getClass();
			Method setMinValue = mmsp.getMethod("setMinValue", int.class);
			Method setMaxValue = mmsp.getMethod("setMaxValue", int.class);
			Method setDisplayedValues = mmsp.getMethod("setDisplayedValues", String[].class);

			setMinValue.invoke(mMinuteSpinner, 0);
			setMaxValue.invoke(mMinuteSpinner, (60 / mIncrement) - 1);

			List<String> displayedValues = new ArrayList<String>();
			for (int i = 0; i < 60; i += mIncrement) {
				displayedValues.add(String.format("%02d", i));
			}

			setDisplayedValues.invoke(mMinuteSpinner, (Object) displayedValues.toArray(new String[0]));
			updateTime(mHourOfDay, mIsSupported ? mMinute / mIncrement : mMinute);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void setOkText(String text) {
		setButton(BUTTON_POSITIVE, text, this);
	}

	public void setCancelText(String text) {
		setButton(BUTTON_NEGATIVE, text, this);
	}

	public void setPermanentTitle(CharSequence title) {
		mTitle = title;
		if (!TextUtils.isEmpty(mTitle)) {
			setTitle(title);
		}
	}
}
