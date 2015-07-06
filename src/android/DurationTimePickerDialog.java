package com.skwas.cordova.datetimepicker;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import android.app.TimePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.widget.NumberPicker;
import android.widget.TimePicker;

public class DurationTimePickerDialog extends TimePickerDialog
{
	final OnTimeSetListener mCallback;
	TimePicker mTimePicker;
	final int increment;
	final Boolean isSupported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB;

	final int hourOfDay, minute;

	public DurationTimePickerDialog(Context context, OnTimeSetListener callBack, int hourOfDay, int minute, boolean is24HourView, int increment)
	{
		super(context, callBack, hourOfDay, minute, is24HourView);
		mCallback = callBack;
		this.increment = increment;

		this.hourOfDay = hourOfDay;
		this.minute = minute;
	}

	@Override
	public void onClick(DialogInterface dialog, int which) {
		if (mCallback != null && mTimePicker!=null) {
			mTimePicker.clearFocus();
			mCallback.onTimeSet(mTimePicker, mTimePicker.getCurrentHour(), mTimePicker.getCurrentMinute()*increment);
		}
		else
			super.onClick(dialog, which);
	}

	@Override
	public void onTimeChanged(TimePicker view, int hourOfDay, int minute) {
		super.onTimeChanged(view, hourOfDay, isSupported ? minute*increment : minute);
	}

	@Override
	protected void onStop()
	{
		// override and do nothing
	}

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		// Ignore on SDK < 11.
		if (!isSupported) return;

		try
		{
			Class<?> rClass = Class.forName("com.android.internal.R$id");
			Field timePicker = rClass.getField("timePicker");
			mTimePicker = (TimePicker)findViewById(timePicker.getInt(null));
			Field m = rClass.getField("minute");

			NumberPicker mMinuteSpinner = (NumberPicker)mTimePicker.findViewById(m.getInt(null));
			Class<?> mmsp = mMinuteSpinner.getClass();
			Method setMinValue = mmsp.getMethod("setMinValue", int.class);
			Method setMaxValue = mmsp.getMethod("setMaxValue", int.class);
			Method setDisplayedValues = mmsp.getMethod("setDisplayedValues", String[].class);

			setMinValue.invoke(mMinuteSpinner, 0);
			setMaxValue.invoke(mMinuteSpinner, (60/increment)-1);
			//            mMinuteSpinner.setMinValue(0);
			//            mMinuteSpinner.setMaxValue((60/increment)-1);
			List<String> displayedValues = new ArrayList<String>();
			for(int i=0;i<60;i+=increment)
			{
				displayedValues.add(String.format("%02d", i));
			}
			//mMinuteSpinner.setDisplayedValues(displayedValues.toArray(new String[0]));
			setDisplayedValues.invoke(mMinuteSpinner, (Object)displayedValues.toArray(new String[0]));
			updateTime(hourOfDay, isSupported ? minute/increment : minute);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
