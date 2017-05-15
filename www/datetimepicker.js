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
var argscheck = require('cordova/argscheck'),
	utils = require('cordova/utils'),
	exec = require('cordova/exec');

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
	function noop() {};

	var settings = {
		mode: "date",
		date: new Date(),
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

	function onPluginError(err) {
		if (settings.error !== noop)
			settings.error(err);
		else
			console.error("DatePickerPlugin: " + err);
	};

	function onPluginSuccess(result) {
		// The plugin expects the result to be:
		//
		// {
		//	 "result": {
		//	   "ticks": a 64-bit int (ticks),
		//	   "cancelled": true|false
		//	 }
		// }

		if (typeof result !== "undefined" && result !== null) {
			if (typeof result === "object") {
				if (result.cancelled === true) {
					settings.cancel();
				} else if (typeof result.ticks === "number") {
					var resultDate = new Date(result.ticks);
					if (isDate(resultDate)) {
						settings.success(resultDate);
					}
				}
				return;
			}
		}
		onPluginError("Unexpected result from plugin: " + JSON.stringify(arguments));
	};
	
	function isDate(val) {
		return Object.prototype.toString.call(val) === "[object Date]" && !isNaN(val.getTime());
	}

	function checkDate(obj, key, onError) {
		if (!isDate(obj[key])) {
			onError("The value " + obj[key] + " for " + key + " is invalid.");
			return false;
		}
		return true;
	}

	// Copy options into settings overwriting the defaults.
	for (var key in settings) {
		if (typeof options[key] !== "undefined")
			settings[key] = options[key];
	}

	// Set default callbacks if not set, or no function provided.
	if (typeof settings.success !== "function") settings.success = successCallback || noop;
	if (typeof settings.cancel !== "function") settings.cancel = noop;
	if (typeof settings.error !== "function") settings.error = errorCallback || noop;

	// Check if dates are valid and convert to ticks since epoch.
	if (!checkDate(settings, "date", onPluginError)) {
		return;
	}
	settings.ticks = settings.date.valueOf();
	
	exec(onPluginSuccess, onPluginError, "DateTimePicker", "show", [settings]);
};

module.exports = new DateTimePicker();