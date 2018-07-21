[![npm version](https://badge.fury.io/js/skwas-cordova-plugin-datetimepicker.svg)](https://badge.fury.io/js/skwas-cordova-plugin-datetimepicker)

# skwas-cordova-plugin-datetimepicker
Cordova Plugin for showing a native date, time or datetime picker.

## Installation ##

`cordova plugin add skwas-cordova-plugin-datetimepicker`

or for latest

`cordova plugin add https://github.com/skwasjer/skwas-cordova-plugin-datetimepicker.git`

## Supported platforms ##

- Android 4 and higher
- iOS 8 and higher (tested with Xcode 7.2.3, Xcode 8 and Xcode 9.2)

## Methods ##

### show ###

`show(options)`  
Show the plugin with specified options.

`show(options, successCallback, errorCallback)`  
Show the plugin with specified options and callbacks.

This was the original way to call the plugin, and is kept for compatibility.
> Note: The `successCallback` and `errorCallback` respectively will be ignored if the `success` or `error` callback is provided on the `options` argument.

#### Options ####

| Name                | Type                | Default        | Android                    | iOS                        | |
|---------------------|---------------------|----------------|:--------------------------:|:--------------------------:|--------------------------|
| mode                | String              | `date`         | `date`, `time`, `datetime` | `date`, `time`, `datetime` | The display mode |
| date                | Date                |                | required                   | required                   | The initial date to display |
| allowOldDates       | boolean             | true           | supported                  | supported                  | Allow older dates to be selected |
| allowFutureDates    | boolean             | true           | supported                  | supported                  | Allow future dates to be selected |
| minDate             | Date                |                | supported                  | supported                  | Set the minimum date that can be selected |
| maxDate             | Date                |                | supported                  | supported                  | Set the maximum date that can be selected |
| minuteInterval      | int                 | 1              | >= Honeycomb               | supported                  | For minute spinner the number of minutes per step |
| locale              | String              | "EN"           | -                          | supported                  | The locale to use for text and date/time |
| okText              | String              | "Select"       | supported                  | supported                  | The text to use for the ok button |
| cancelText          | String              | "Cancel"       | supported                  | supported                  | The text to use for the cancel button |
| success             | Function            | -              | supported                  | supported                  | The success callback |
| cancel              | Function            | -              | supported                  | supported                  | The cancel callback |
| error               | Function            | -              | supported                  | supported                  | The error callback |
| android             | Object              | {}             | optional                   | ignored                    | Android specific options |

#### Android options

| Name                | Type                | Default     | Description               |
|---------------------|---------------------|-------------|---------------------------|
| theme               | int                 | [Theme_DeviceDefault_Dialog](https://developer.android.com/reference/android/R.style.html#Theme_DeviceDefault_Dialog)| android.R.style theme |
| calendar (obsolete) | boolean             | false       | `false` shows spinners, however this depend on the theme selected and SDK version. When `true`, forces a calendar view.|
| is24HourView        | boolean             | true        | Use a 24 hour clock |

> On Lollipop and upwards the date and time pickers changed to calendar and radial pickers. If you want to use spinners (for example to use `minuteInterval`), use a built-in [android.R.style](https://developer.android.com/reference/android/R.style.html) theme that shows a date and time picker with spinners or read up here [how to customize this](./docs/Android_custom_theme_and_styling.md).

#### Example ####

```js
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {

	var myDate = new Date(); // From model.

	cordova.plugins.DateTimePicker.show({
		mode: "date",
		date: myDate,
		allowOldDates: true,
		allowFutureDates: true,
		minDate: new Date(),
		maxDate: null,
		minuteInterval: 15,
		locale: "EN",
		okText: "Select",
		cancelText: "Cancel",
		android: {
			theme: 16974126, // Theme_DeviceDefault_Dialog
			calendar: false,
			is24HourView: true
		},
		success: function(newDate) {
			// Handle new date.
			console.info(newDate);
			myDate = newDate;
		},
		cancel: function() {
			console.info("Cancelled");
		},
		error: function (err) {
			// Handle error.
			console.error(err);
		}
	});
}
```
> Note that not all options have to be set.

## Changelog

For a list of all changes  [see here](./CHANGELOG.md).

### Contributors ###

- [skwasjer](https://github.com/skwasjer)
- [turshija](https://github.com/turshija)
- [emanfu](https://github.com/emanfu)
- [masimplo](https://github.com/masimplo)
