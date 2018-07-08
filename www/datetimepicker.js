/*
The MIT License (MIT)

Copyright (c) 2015 skwas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
var utils = require('cordova/utils'),
	exec = require('cordova/exec');

var modeRegex = /(date|time|datetime)/i,
	isValidMode = modeRegex.test.bind(modeRegex);

function noop() { };

function isDate(val) {
	return Object.prototype.toString.call(val) === "[object Date]" && !isNaN(val.getTime());
}

function is(value, type) {
	return typeof value === type;
}

function isUndefined(value) {
	return is(value, "undefined");
}

function isDefined(value) {
	return !isUndefined(value);
}

function isFunction(value) {
	return is(value, "function");
}

function isObject(value) {
	return is(value, "object");
}

function isString(value) {
	return is(value, "string");
}

function isNumber(value) {
	return is(value, "number");
}

function isMinuteInterval(i) {
	return isNumber(i) && i >= 1 && i <= 30 && (60 % i === 0);
}

/**
 * Returns an error handler that logs to console if no callback is provided.
 * @param {Function} callback The external callback to call on error.
 */
function getErrorHandler(callback) {
	return function(err) {
		if (callback && callback !== noop && isFunction(callback)) {
			callback.apply(this, [ err ]);
		} else {
			console.error("DatePickerPlugin: " + err);
		}
	};
}

function validate(test, obj, key, message) {
	if (!test(obj[key])) {
		throw Error("The value '" + obj[key] + "' for option '" + key + "' is invalid." + (message || ""));
	}
	return true;
}

/**
 * This represents the DateTimePicker, and provides methods to show the native DateTime picker.
 * @constructor
 */
function DateTimePicker() {
}

/**
 * Show the date time picker.
 *
 * @param {Function} successCallback The function to call when the datetime has changed.
 */
DateTimePicker.prototype.show = function(options, successCallback, errorCallback) {
	var settings = {
		mode: "date",
		date: new Date(),
		minDate: null,
		maxDate: null,
		allowOldDates: null,
		allowFutureDates: null,
		minuteInterval: 1,
		locale: "EN",
		okText: null,
		cancelText: null,
		android: {
			theme: undefined,	// If omitted/undefined, default theme will be used.
			calendar: false
		},
		success: undefined,
		cancel: undefined,
		error: undefined
	};

	// Copy options into settings overwriting the defaults.
	for (var key in settings) {
		if (isDefined(options[key]))
			settings[key] = options[key];
	}

	// Set default callbacks if not set, or no function provided.
	if (!isFunction(settings.success)) settings.success = successCallback || noop;
	if (!isFunction(settings.cancel)) settings.cancel = noop;
	if (!isFunction(settings.error)) settings.error = errorCallback || noop;

	var onPluginError = getErrorHandler(settings.error).bind(this),
		onPluginSuccess = function(result) {
			// The success handler expects the result to be:
			//
			// {
			//   "result": {
			//	   "ticks": a 64-bit int (ticks),
			//	   "cancelled": true|false
			//   }
			// }

			if (isDefined(result) && result !== null) {
				if (isObject(result)) {
					if (result.cancelled === true) {
						settings.cancel.apply(this);
					} else if (isNumber(result.ticks)) {
						var resultDate = new Date(result.ticks);
						if (isDate(resultDate)) {
							settings.success.apply(this, [ resultDate ]);
						}
					}
					return;
				}
			}

			onPluginError("Unexpected result from plugin: " + JSON.stringify(arguments));
		}.bind(this);

	try {
		validate(isValidMode, settings, "mode", " Expected a String: date, time, datetime.");

		// Validate if dates are valid, convert to ticks since epoch.
		if (validate(isDate, settings, "date", " Expected a Date.")) {
			settings.ticks = settings.date.valueOf();
		}
		if (!!settings.minDate && validate(isDate, settings, "minDate", " Expected a Date.")) {
			settings.minDate = settings.minDate.valueOf();
		}
		if (!!settings.maxDate && validate(isDate, settings, "maxDate", " Expected a Date.")) {
			settings.maxDate = settings.maxDate.valueOf();
		}

		!!settings.minuteInterval && validate(isMinuteInterval, settings, "minuteInterval", " Expected a Number which is a divisor of 60 (min 1, max 30).");
	} catch (e) {
		onPluginError(e.message);
		return;
	}

	exec(onPluginSuccess, onPluginError, "DateTimePicker", "show", [ settings ]);
};

/**
 * Hide the date time picker.
 *
 * If the picker is currently being shown and a cancel-callback is provided
 * in the options, the callback will be called when the picker is hidden.
 */
DateTimePicker.prototype.hide = function() {
	exec(null, getErrorHandler().bind(this), "DateTimePicker", "hide");
}

module.exports = new DateTimePicker();
