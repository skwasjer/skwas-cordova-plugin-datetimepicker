package com.skwas.cordova.datetimepicker;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StyleRes;
import android.widget.DatePicker;

import java.lang.reflect.Method;

public class DatePickerDialog extends android.app.DatePickerDialog {

	public DatePickerDialog(@NonNull Context context, @Nullable OnDateSetListener callBack, int year, int monthOfYear, int dayOfMonth) {
		super(context, callBack, year, monthOfYear, dayOfMonth);
	}

	public DatePickerDialog(@NonNull Context context, @StyleRes int theme, @Nullable OnDateSetListener listener, int year, int monthOfYear, int dayOfMonth) {
		super(context, theme, listener, year, monthOfYear, dayOfMonth);
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
}
