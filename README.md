# skwas-cordova-plugin-datetimepicker
Cordova Plugin for showing a native date, time or datetime picker.

## Installation ##

`cordova plugin add skwas-cordova-plugin-datetimepicker`

or for latest

`cordova plugin add https://github.com/skwasjer/skwas-cordova-plugin-datetimepicker.git`

## Supported platforms ##

Currently Android and iOS are supported.

## Methods ##

### show ###

show(options, successCallback, errorCallback);

#### Options ####

| Name                | Type                | Android                    | iOS                        |
|---------------------|---------------------|:--------------------------:|:--------------------------:|
| mode                | String              | `date`, `time`, `calendar` | `date`, `time`, `datetime` |
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
