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
	function onPluginError(err) {
		if (errorCallback)
			errorCallback(err);
		else
			console.error("DatePickerPlugin: " + err);
	};
	
	function onPluginSuccess(dateInTicks) {
		if (typeof dateInTicks !== "undefined" && dateInTicks != null) {
			if (typeof dateInTicks === "object") dateInTicks = dateInTicks.date;
			if (typeof dateInTicks === "string") dateInTicks = dateInTicks * 1;
		
			if (typeof dateInTicks === "number") {
				var resultDate = new Date(dateInTicks * 1);
				if (isDate(resultDate) && successCallback) {
					successCallback();
					return;
				}
			}
		}
		onPluginError("Unexpected result from plugin: " + JSON.stringify(arguments));
	};
	
	function isDate(val) {
		return Object.prototype.toString.call(val) === "[object Date]" && !isNaN(val.getTime());
	}
	
	var settings = {
		mode: "date",
		date: new Date(),
		allowOldDates: true,
		allowFutureDates: true,
		minuteInterval: 1,
		locale: "EN",
		okText: "Select",
		cancelText: "Cancel"
	};

	// Copy options into settings overwriting the defaults.
	for (var key in settings) {
		if (typeof options[key] !== "undefined")
			settings[key] = options[key];
	}
	
	// Check if date is valid.
	if (!isDate(settings.date)) {
		onPluginError("The date " + settings.date + "is invalid.");
		return;
	}
	
    exec(onPluginSuccess, onPluginError, "DateTimePicker", "show", [settings]);
};

module.exports = new DateTimePicker();