/* eslint-dev: plugin:es/no-new-in-es2015 */

var cordovaUtils = require("cordova/utils");
var modeRegex = /^(date|time|datetime)$/i;

exports.isValidMode = modeRegex.test.bind(modeRegex);

var is = exports.is = function (value, type) {
    /* eslint-disable valid-typeof */
    return typeof value === type;
    /* eslint-enable valid-typeof */
};

exports.isDate = function (val) {
    return cordovaUtils.typeName(val) === "Date" && !isNaN(val.getTime());
};

var isUndefined = exports.isUndefined = function (value) {
    return is(value, "undefined");
};

exports.isDefined = function (value) {
    return !isUndefined(value);
};

var isFunction = exports.isFunction = function (value) {
    return is(value, "function");
};

exports.isObject = function (value) {
    return is(value, "object");
};

exports.isString = function (value) {
    return is(value, "string");
};

var isNumber = exports.isNumber = function (value) {
    return is(value, "number");
};

exports.isMinuteInterval = function (i) {
    i = is(i, "boolean") ? i : i * 1;
    return isNumber(i) && !isNaN(i) && i >= 1 && i <= 30 && (60 % i === 0);
};

/**
 * Returns an error handler that logs to console if no callback is provided.
 * @param {Function} callback The external callback to call on error.
 */
exports.getErrorHandler = function (callback) {
    return function (err) {
        if (callback && isFunction(callback)) {
            console.debug("DateTimePickerPlugin: " + err);
            callback.apply(this, [err]);
        } else {
            console.error("DateTimePickerPlugin: " + err);
        }
    };
};

/**
 * Validates obj[key] using the provided test. If the test fails, an Error is thrown.
 * @param {Function} test   The test to execute.
 * @param {Object} obj      The object to check a value on.
 * @param {String} key      The key of the value to test.
 * @param {String} message  The optional error message to append to the default error message.
 * @return                  true if the test passes. Never returns false (instead will throw).
 */
exports.validate = function (test, obj, key, message) {
    if (!test(obj[key])) {
        var msg = "The value '" + obj[key] + "' for option '" + key + "' is invalid.";
        if (message) {
            msg += " " + message;
        }
        throw Error(msg);
    }
    return true;
};
