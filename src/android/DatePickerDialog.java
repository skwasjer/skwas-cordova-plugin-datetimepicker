package com.skwas.cordova.datetimepicker;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StyleRes;
import android.text.TextUtils;
import android.widget.DatePicker;

import java.lang.reflect.Method;

public class DatePickerDialog extends android.app.DatePickerDialog {

	// On Jelly Bean/KitKat the success handler is always called (even when cancelling).
	// https://issuetracker.google.com/issues/36951008 - Fixes #18
	private final static boolean mShouldFixCallbackDelegate = Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP;
	private final OnDateSetListener mListener;
	private DatePicker mDatePicker;
	private CharSequence mTitle;

	public DatePickerDialog(@NonNull Context context, @Nullable OnDateSetListener listener, int year, int monthOfYear, int dayOfMonth) {
		super(context, patchListener(listener), year, monthOfYear, dayOfMonth);

		mListener = listener;
	}

	public DatePickerDialog(@NonNull Context context, @StyleRes int theme, @Nullable OnDateSetListener listener, int year, int monthOfYear, int dayOfMonth) {
		super(context, theme, patchListener(listener), year, monthOfYear, dayOfMonth);

		mListener = listener;
	}

	@Override
	public void onClick(DialogInterface dialog, int which) {
		if (mShouldFixCallbackDelegate) {
			switch (which) {
				case BUTTON_POSITIVE:
					if (mListener != null && mDatePicker != null) {
						mDatePicker.clearFocus();
						mListener.onDateSet(mDatePicker, mDatePicker.getYear(), mDatePicker.getMonth(), mDatePicker.getDayOfMonth());
					}
					return;

				case BUTTON_NEGATIVE:
					cancel();
					return;
			}
		}
		super.onClick(dialog, which);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mDatePicker = getDatePicker();
	}

	public void setOkText(String text) {
		setButton(BUTTON_POSITIVE, text, this);
	}

	public void setCancelText(String text) {
		setButton(BUTTON_NEGATIVE, text, this);
	}

	/*
	 * Sets the calendar mode.
	 * @remarks The deprecated functions setCalendarViewShown/setSpinnersShown are used via reflection.
	 */
	public void setCalendarEnabled(boolean enabled) {
		try {
			Method getDatePicker = DatePickerDialog.class.getMethod("getDatePicker");
			DatePicker dp = (DatePicker) getDatePicker.invoke(this, (Object[]) null);

			Method setCalendarViewShown = DatePicker.class.getMethod("setCalendarViewShown", boolean.class);
			setCalendarViewShown.invoke(dp, enabled);
			Method setSpinnersShown = DatePicker.class.getMethod("setSpinnersShown", boolean.class);
			setSpinnersShown.invoke(dp, !enabled);
		} catch (Exception ex) {
			//ex.printStackTrace();
		}
	}

	public void setPermanentTitle(CharSequence title) {
		mTitle = title;
		if (!TextUtils.isEmpty(mTitle)) {
			setTitle(title);
		}
	}

	@Override
	public void onDateChanged(@NonNull DatePicker view, int year, int month, int dayOfMonth) {
		super.onDateChanged(view, year, month, dayOfMonth);

		// If set, enforce title.
		if (!TextUtils.isEmpty(mTitle)) {
			setTitle(mTitle);
		}
	}

	/*
	 * For Jelly Bean/KitKat we don't send the callback to the super class, instead we call it ourselves via an override.
	 */
	private static OnDateSetListener patchListener(OnDateSetListener listener) {
		return mShouldFixCallbackDelegate
				? null
				: listener;
	}
}
