/**
 * Interface for cordova.plugins adding DateTimePicker
 *
 * @interface Plugins
 */
interface Plugins {
  DateTimePicker: DateTimePicker;
}

interface IDatePickerOptions {
  mode: 'date' | 'time' | 'datetime';
  date: Date;
  minDate?: Date;
  maxDate?: Date;
  allowOldDates?: boolean;
  allowFutureDates?: boolean;
  minuteInterval?: number;
  locale?: string;
  okText?: string;
  cancelText?: string;
  clearText?: string;
  titleText?: string;
  android?: {
    theme?: number; // Theme_DeviceDefault_Dialog
    calendar?: boolean;
    is24HourView?: boolean;
  };
  success: (newDate?: Date) => void;
  cancel?: () => void;
  error: (err: Error) => void;
}

interface DateTimePicker {

  /**
   * Show the date/time picker with specified options.
   *
   * @param {IDatePickerOptions} options
   * @memberof DateTimePicker
   */
  show(options: IDatePickerOptions): void;

  /**
   * Show the date/time picker with specified options and callbacks.
   * Legacy way to call the show method, kept for backward compatibility.
   * NOTE: The successCallback and errorCallback respectively will be ignored if the success or error callback is provided on the options argument.
   *
   * @param {IDatePickerOptions} options
   * @param {(newDate?: Date) => void} successCb
   * @param {(err: Error) => void} errorCb
   * @memberof DateTimePicker
   */
  show(options: IDatePickerOptions, successCb: (newDate?: Date) => void, errorCb: (err: Error) => void): void;

  /**
   * Hide the date/time picker.
   *
   * If the picker is currently being shown and a cancel-callback was provided
   * in the options, the callback will be called when the picker is hidden.
   *
   * @memberof DateTimePicker
   */
  hide(): void;
}
