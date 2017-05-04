# skwas-cordova-plugin-datetimepicker
Cordova Plugin for showing a native date, time or datetime picker.

## Changelog

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

| Name                | Type                | Android                    | iOS                        |
|---------------------|---------------------|:--------------------------:|:--------------------------:|
| mode                | String              | `date`, `time`, `datetime` | `date`, `time`, `datetime` |
| date                | Date                | required                   | required                   |
| allowOldDates       | boolean             | -                          | supported                  |
| allowFutureDates    | boolean             | -                          | supported                  |
| minuteInterval      | int                 | >= Honeycomb < Lollipop    | supported                  |
| locale              | String              | -                          | supported                  |
| okText              | String              | -                          | supported                  |
| cancelText          | String              | -                          | supported                  |

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
	cancelText: "Cancel"
}, function(newDate) {
  // Handle new date.
  ...
}, function (err) {
  // Handle error.
	console.error(err);
});
```
