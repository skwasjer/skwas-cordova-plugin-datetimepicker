// tslint:disable-next-line:no-reference
/// <reference path="index.d.ts" />

declare var cordova: { plugins: Plugins };

const dateTimePicker: DateTimePicker = cordova.plugins.DateTimePicker;

const optionsFull: IDatePickerOptions = {
  mode: 'datetime',
  date: new Date(),
  minDate: new Date(),
  maxDate: new Date(),
  allowOldDates: false,
  allowFutureDates: true,
  minuteInterval: 5,
  locale: 'en_GB',
  okText: 'Select',
  cancelText: 'Cancel',
  clearText: 'Clear',
  titleText: 'Picker title',
  android: {
    theme: 5, // Theme_DeviceDefault_Dialog
    calendar: false,
    is24HourView: true
  },
  success: (newDate: Date) => { /* newDate */ },
  cancel: () => { /* cancelled */ },
  error: (err: Error) => { /* error */ }

};
dateTimePicker.show(optionsFull);

const optionsMin: IDatePickerOptions = {
  mode: 'date',
  date: new Date(),
  success: (newDate: Date) => { /* newDate */ },
  error: (err: Error) => { /* error */ }
};
dateTimePicker.show(optionsMin);

// override method
dateTimePicker.show(optionsMin, (newDate) => { /* newDate */ }, (err) => { /* error */ });
