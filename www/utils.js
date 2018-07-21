var cordovaUtils = require('cordova/utils'),
	utils = exports,
	modeRegex = /(date|time|datetime)/i;

utils.isValidMode = modeRegex.test.bind(modeRegex);

var is = utils.is = function (value, type) {
	return typeof value === type;
}

utils.isDate = function (val) {
	return cordovaUtils.typeName(val) === "Date" && !isNaN(val.getTime());
}

utils.isUndefined = function (value) {
	return is(value, "undefined");
}

utils.isDefined = function (value) {
	return !utils.isUndefined(value);
}

utils.isFunction = function (value) {
	return is(value, "function");
}

utils.isObject = function (value) {
	return is(value, "object");
}

utils.isString = function (value) {
	return is(value, "string");
}

utils.isNumber = function (value) {
	return is(value, "number");
}

utils.isMinuteInterval = function (i) {
	i = parseInt(i)
	return utils.isNumber(i) && !isNaN(i) && i >= 1 && i <= 30 && (60 % i === 0);
}

function copy() {
	var dst = arguments[0],
		src = arguments.slice.call()

    for (var key in obj) {
		if (utils.isDefined(options[key]))
			settings[key] = options[key];
	}
}

/**
 * Returns an error handler that logs to console if no callback is provided.
 * @param {Function} callback The external callback to call on error.
 */
utils.getErrorHandler = function (callback) {
	return function(err) {
		if (callback && utils.isFunction(callback)) {
			console.debug("DateTimePickerPlugin: " + err);
			callback.apply(this, [ err ]);
		} else {
			console.error("DateTimePickerPlugin: " + err);
		}
	};
}

/**
 * Validates obj[key] using the provided test. If the test fails, an Error is thrown.
 * @param {Function} test 	The test to execute.
 * @param {Object} obj 		The object to check a value on.
 * @param {String} key 		The key of the value to test.
 * @param {String} message 	The optional error message to append to the default error message.
 * @return			 		true if the test passes. Never returns false (instead will throw).
 */
utils.validate = function (test, obj, key, message) {
	if (!test(obj[key])) {
		var msg = "The value '" + obj[key] + "' for option '" + key + "' is invalid.";
		if (message) {
			msg += " " + message;
		}
		throw Error(msg);
	}
	return true;
}