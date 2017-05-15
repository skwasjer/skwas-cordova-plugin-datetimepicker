[![npm version](https://badge.fury.io/js/skwas-cordova-plugin-datetimepicker.svg)](https://badge.fury.io/js/skwas-cordova-plugin-datetimepicker)

# skwas-cordova-plugin-datetimepicker
Cordova Plugin for showing a native date, time or datetime picker.

## Installation ##

`cordova plugin add skwas-cordova-plugin-datetimepicker`

or for latest

`cordova plugin add https://github.com/skwasjer/skwas-cordova-plugin-datetimepicker.git`

## Supported platforms ##

Android 4 and higher  
iOS 8 and higher (tested with Xcode 7.2.3 and Xcode 8)

## Methods ##

### show ###

show(options, successCallback, errorCallback);

#### Options ####

| Name                | Type                | Default        | Android                    | iOS                        |
|---------------------|---------------------|----------------|:--------------------------:|:--------------------------:|
| mode                | String              | "date"         | `date`, `time`, `datetime` | `date`, `time`, `datetime` |
| date                | Date                |                | required                   | required                   |
| allowOldDates       | boolean             | true           | -                          | supported                  |
| allowFutureDates    | boolean             | true           | -                          | supported                  |
| minuteInterval      | int                 | 1              | >= Honeycomb               | supported                  |
| locale              | String              | "EN"           | -                          | supported                  |
| okText              | String              | "Select"       | supported                  | supported                  |
| cancelText          | String              | "Cancel"       | supported                  | supported                  |
| android             | Object              | {}             | optional                   | ignored                    |

#### Android options

| Name                | Type                | Description               |
|---------------------|---------------------|---------------------------|
| theme               | int                 | Default [android.R.style.Theme_DeviceDefault_Dialog](https://developer.android.com/reference/android/R.style.html#Theme_DeviceDefault_Dialog)|
| calendar            | boolean             | Default false shows spinners, however this depend on the theme selected and SDK version. When true, forces a calendar view.|

> On Lollipop and upwards the date and time pickers changed to calendar and radial pickers. If you want to use spinners (for example to use `minuteInterval`), choose a theme that shows a date and time picker with spinners, like Theme_DeviceDefault_Light, Theme_Holo_Dialog or the traditional theme (1).

#### Example ####

```
var myDate = new Date();	// From model.

cordova.plugins.DateTimePicker.show({
	mode: "date",
	date: myDate,
	allowOldDates: true,
	allowFutureDates: true,
	minuteInterval: 15,
	locale: "EN",
	okText: "Select",
	cancelText: "Cancel",
	android: {
		theme: 16974126, // Theme_DeviceDefault_Dialog
		calendar: false
	}
}, function(newDate) {
	// Handle new date.
	...
}, function (err) {
	// Handle error.
	console.error(err);
});
```
> Note that not all options have to be set.

## Changelog

#### 0.9.1 ####

- Android: add support for okText/cancelText

#### 0.9.0 ####

- Android: fixed datetime mode only showing date picker (see #10)
- Android: added theme support
- Android: added calendar switch

#### 0.8.0 ####

- Android: fix @NonNull error when building apk

#### 0.7.0 ####

- iOS: use auto layout
- iOS: remove < iOS 7 support (UIActionSheet)
- iOS: remove custom modal picker type
- Android: fix minute spinner for setting minute interval

#### 0.6.0 ####

- Android: support Lollipop radial picker (no support for minute interval however)
- Android: overall refactor and improvements

#### 0.5.1 ####

- iOS: replace initWithWebView with pluginInitialize (deprecated in cordova-ios-4.0)

#### 0.5.0 ####

- rename repo to conform to npm/cordova plugin naming convention
