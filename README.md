[![npm version](https://badge.fury.io/js/skwas-cordova-plugin-datetimepicker.svg)](https://badge.fury.io/js/skwas-cordova-plugin-datetimepicker)

# skwas-cordova-plugin-datetimepicker

Cordova Plugin for showing a native date, time or datetime picker.

## Installation

`cordova plugin add skwas-cordova-plugin-datetimepicker`

or for latest

`cordova plugin add https://github.com/skwasjer/skwas-cordova-plugin-datetimepicker.git`

## Supported platforms

- Android 4.4 and higher
- iOS 9 and higher

## Methods

### show

`show(options)`  
Show the plugin with specified options.

`show(options, successCallback, errorCallback)`  
Show the plugin with specified options and callbacks.

This was the original way to call the plugin, and is kept for compatibility.
> Note: The `successCallback` and `errorCallback` respectively will be ignored if the `success` or `error` callback is provided on the `options` argument.

#### Options

| Name                | Type                | Default        | Android                    | iOS                        | |
|---------------------|---------------------|----------------|:--------------------------:|:--------------------------:|--------------------------|
| mode                | String              | `date`         | `date`, `time`, `datetime` | `date`, `time`, `datetime` | The display mode |
| date                | Date                |                | required                   | required                   | The initial date to display |
| allowOldDates       | boolean             | true           | ![Supported][supported]    | ![Supported][supported]    | Allow older dates to be selected |
| allowFutureDates    | boolean             | true           | ![Supported][supported]    | ![Supported][supported]    | Allow future dates to be selected |
| minDate             | Date                |                | ![Supported][supported]    | ![Supported][supported]    | Set the minimum date that can be selected |
| maxDate             | Date                |                | ![Supported][supported]    | ![Supported][supported]    | Set the maximum date that can be selected |
| minuteInterval      | int                 | 1              | >= Honeycomb               | ![Supported][supported]    | For minute spinner the number of minutes per step |
| locale              | String              | (user default) | -                          | ![Supported][supported]    | The locale to use for text and date/time |
| okText              | String              | (os default)   | ![Supported][supported]    | ![Supported][supported]    | The text to use for the ok button |
| cancelText          | String              | (os default)   | ![Supported][supported]    | ![Supported][supported]    | The text to use for the cancel button |
| clearText           | String              |                | ![Supported][supported]    | ![Supported][supported]    | The text to use for the clear button |
| titleText           | String              |                | Depends&#160;on&#160;theme | ![Supported][supported]    | The text to use for the dialog title |
| success             | Function(date)      | -              | ![Supported][supported]    | ![Supported][supported]    | The success callback |
| cancel              | Function()          | -              | ![Supported][supported]    | ![Supported][supported]    | The cancel callback |
| error               | Function(err)       | -              | ![Supported][supported]    | ![Supported][supported]    | The error callback |
| android             | Object              | {}             | optional                   | ignored                    | Android specific options |

> When providing the `clearText` property, an extra button is shown with intent to clear the current date. When the user taps this button, the `success` callback will be called with an `undefined` date. From a UI perspective, this button should be hidden by application code when no date is currently set by omitting the property, but this is up to you.

#### Android options

| Name                | Type                | Default     | Description               |
|---------------------|---------------------|-------------|---------------------------|
| theme               | int                 | [Theme_DeviceDefault_Dialog](https://developer.android.com/reference/android/R.style.html#Theme_DeviceDefault_Dialog)| android.R.style theme |
| is24HourView        | boolean             | true        | Use a 24 hour clock |

> On Lollipop and upwards the date and time pickers changed to calendar and radial pickers. If you want to use spinners (for example to use `minuteInterval`), use a built-in [android.R.style](https://developer.android.com/reference/android/R.style.html) theme that shows a date and time picker with spinners or read up here [how to customize this](./docs/Android_custom_theme_and_styling.md).

#### Example

```js
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {

    var myDate = new Date(); // From model.

    cordova.plugins.DateTimePicker.show({
        mode: "date",
        date: myDate,
        success: function(newDate) {
            // Handle new date.
            console.info(newDate);
            myDate = newDate;
        }
    });
}
```

### hide

`hide()`  
Hide the date time picker.

If the picker is currently being shown and a cancel-callback was provided in the options, the callback will be called when the picker is hidden.

#### Example

```js
cordova.plugins.DateTimePicker.hide();
```

## Changelog

For a list of all changes  [see here](./CHANGELOG.md).

## Build requirements

- Cordova 7 and higher
- Xcode 11 and higher (iOS)

### Contributors

- [skwasjer](https://github.com/skwasjer)
- [turshija](https://github.com/turshija)
- [emanfu](https://github.com/emanfu)
- [masimplo](https://github.com/masimplo)


[supported]: ./docs/res/check.svg "Supported"
[not-supported]: ./doc/res/close.svg "Not supported"
