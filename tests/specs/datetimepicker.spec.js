/* eslint-env jasmine */
const sut = "../../www/datetimepicker";

const mock = require("mock-require");
mock("cordova/utils", {
    typeName: () => "Date"
});
mock("skwas-cordova-plugin-datetimepicker.utils", require("../../www/utils"));

let cbSuccessSpy;
let cbErrorSpy;
let cbCancelSpy;
let execSpy = jasmine.createSpy("exec");
mock("cordova/exec", execSpy);

let dateTimePicker = require(sut);

beforeEach(() => {
    cbSuccessSpy = jasmine.createSpy("success");
    cbErrorSpy = jasmine.createSpy("error");
    cbCancelSpy = jasmine.createSpy("cancel");
    execSpy = jasmine.createSpy("exec");

    spyOn(console, "debug");
    spyOn(console, "error");

    mock("cordova/exec", execSpy);
    dateTimePicker = mock.reRequire(sut);
});

describe("show", () => {
    describe("Given that options is not specified", () => {
        const fn = () => dateTimePicker.show();

        it("it should throw", () => {
            const expectedError = new Error("'options' is required.");

            expect(fn).toThrow(expectedError);
        });

        it("it should not cordova exec", () => {
            expect(fn).toThrow();
            expect(execSpy).not.toHaveBeenCalled();
        });
    });

    describe("With invalid options", () => {
        describe("Given that mode is invalid", () => {
            const expectedErrorMsg = "The value 'unknown' for option 'mode' is invalid. Expected a String: date, time, datetime.";

            describe("and error callback is not provided", () => {
                it("it should not cordova exec", () => {
                    dateTimePicker.show({ mode: "unknown" });

                    expect(console.error).toHaveBeenCalledWith(`DateTimePickerPlugin: ${expectedErrorMsg}`);
                    expect(execSpy).not.toHaveBeenCalled();
                });
            });

            describe("and error callback is provided", () => {
                it("it should not cordova exec", () => {
                    dateTimePicker.show({ mode: "unknown", error: cbErrorSpy });

                    expect(cbErrorSpy).toHaveBeenCalledWith(expectedErrorMsg);
                    expect(console.debug).toHaveBeenCalledWith(`DateTimePickerPlugin: ${expectedErrorMsg}`);
                    expect(execSpy).not.toHaveBeenCalled();
                });
            });
        });

        describe("Given that date is invalid", () => {
            const expectedErrorMsg = "The value '[object Object]' for option '{0}' is invalid. Expected a Date.";
            const dtNanMock = {
                getTime: () => NaN
            };
            const formatErrMsg = field => expectedErrorMsg.replace("{0}", field);
            const dateTestCases = ["date", "minDate", "maxDate"];

            describe("and error callback is not provided", () => {
                it("it should not cordova exec", () => {
                    dateTestCases.forEach(field => {
                        const opts = {};
                        opts[field] = dtNanMock;
                        dateTimePicker.show(opts);

                        expect(console.error).toHaveBeenCalledWith(`DateTimePickerPlugin: ${formatErrMsg(field)}`);
                        expect(execSpy).not.toHaveBeenCalled();
                    });
                });
            });

            describe("and error callback is provided", () => {
                it("it should not cordova exec", () => {
                    dateTestCases.forEach(field => {
                        const opts = { error: cbErrorSpy };
                        opts[field] = dtNanMock;
                        dateTimePicker.show(opts);

                        expect(cbErrorSpy).toHaveBeenCalledWith(formatErrMsg(field));
                        expect(console.debug).toHaveBeenCalledWith(`DateTimePickerPlugin: ${formatErrMsg(field)}`);
                        expect(execSpy).not.toHaveBeenCalled();
                    });
                });
            });
        });

        describe("Given that minute interval is invalid", () => {
            const expectedErrorMsg = "The value '17' for option 'minuteInterval' is invalid. Expected a Number which is a divisor of 60 (min 1, max 30).";

            describe("and error callback is not provided", () => {
                it("it should not cordova exec", () => {
                    dateTimePicker.show({ minuteInterval: 17 });

                    expect(console.error).toHaveBeenCalledWith(`DateTimePickerPlugin: ${expectedErrorMsg}`);
                    expect(execSpy).not.toHaveBeenCalled();
                });
            });

            describe("and error callback is provided", () => {
                it("it should not cordova exec", () => {
                    dateTimePicker.show({ minuteInterval: 17, error: cbErrorSpy });

                    expect(cbErrorSpy).toHaveBeenCalledWith(expectedErrorMsg);
                    expect(console.debug).toHaveBeenCalledWith(`DateTimePickerPlugin: ${expectedErrorMsg}`);
                    expect(execSpy).not.toHaveBeenCalled();
                });
            });
        });
    });

    describe("With valid options", () => {
        it("should call cordova exec", () => {
            // Act
            dateTimePicker.show({ mode: "date", success: cbSuccessSpy, error: cbErrorSpy });

            // Assert
            expect(console.debug).toHaveBeenCalledWith("DateTimePickerPlugin: Exec 'show' with:", jasmine.any(Object));
            expect(execSpy).toHaveBeenCalledOnceWith(jasmine.any(Function), jasmine.any(Function), "DateTimePicker", "show", jasmine.any(Array));
        });

        describe("with non-sanitized options", () => {
            it("should call cordova exec with sanitized options", () => {
                const dt = new Date(2020, 1, 2, 3, 4, 5);
                const dtMin = new Date(2019, 1, 2, 3, 4, 5);
                const dtMax = new Date(2021, 1, 2, 3, 4, 5);

                // Act
                dateTimePicker.show({
                    mode: "DATE",
                    date: dt,
                    minDate: dtMin,
                    maxDate: dtMax,
                    minuteInterval: "15",
                    success: cbSuccessSpy,
                    error: cbErrorSpy,
                    cancel: cbCancelSpy
                });

                // Assert
                expect(console.debug).toHaveBeenCalledWith("DateTimePickerPlugin: Exec 'show' with:", {
                    mode: "date",
                    date: dt,
                    ticks: dt.valueOf(),
                    minDate: dtMin,
                    minDateTicks: dtMin.valueOf(),
                    maxDate: dtMax,
                    maxDateTicks: dtMax.valueOf(),
                    minuteInterval: 15,
                    allowOldDates: null,
                    allowFutureDates: null,
                    locale: null,
                    okText: null,
                    cancelText: null,
                    clearText: null,
                    titleText: null,
                    android: {
                        theme: undefined,
                        calendar: false
                    },
                    success: cbSuccessSpy,
                    error: cbErrorSpy,
                    cancel: cbCancelSpy
                });
                expect(execSpy).toHaveBeenCalledOnceWith(jasmine.any(Function), jasmine.any(Function), "DateTimePicker", "show", jasmine.any(Array));
            });
        });

        describe("given that plugin returns an invalid result", () => {
            it("should not throw and call error callback", () => {
                execSpy.and.callFake(function (success) {
                    success(null);
                });

                // Act
                dateTimePicker.show({ mode: "date", success: cbSuccessSpy, error: cbErrorSpy, cancel: cbCancelSpy });

                // Assert
                expect(execSpy).toHaveBeenCalled();
                expect(cbSuccessSpy).not.toHaveBeenCalled();
                expect(cbErrorSpy).toHaveBeenCalledWith("Unexpected result from plugin: {\"0\":null}");
                expect(cbCancelSpy).not.toHaveBeenCalled();
            });
        });

        describe("given that user closes picker with OK button", () => {
            it("should call success callback with expected value", () => {
                const dt = new Date();
                execSpy.and.callFake(function (success) {
                    success({ ticks: dt.valueOf() });
                });

                // Act
                dateTimePicker.show({ mode: "date", success: cbSuccessSpy, error: cbErrorSpy, cancel: cbCancelSpy });

                // Assert
                expect(execSpy).toHaveBeenCalled();
                expect(cbSuccessSpy).toHaveBeenCalledWith(dt);
                expect(cbErrorSpy).not.toHaveBeenCalled();
                expect(cbCancelSpy).not.toHaveBeenCalled();
            });
        });

        describe("given that user closes picker with Cancel button", () => {
            it("should call success callback with expected value", () => {
                execSpy.and.callFake(function (success) {
                    success({ cancelled: true });
                });

                // Act
                dateTimePicker.show({ mode: "date", success: cbSuccessSpy, error: cbErrorSpy, cancel: cbCancelSpy });

                // Assert
                expect(execSpy).toHaveBeenCalled();
                expect(cbSuccessSpy).not.toHaveBeenCalledWith();
                expect(cbErrorSpy).not.toHaveBeenCalled();
                expect(cbCancelSpy).toHaveBeenCalled();
            });
        });

        describe("given that user closes picker with Clear button", () => {
            it("should call success callback with expected value", () => {
                execSpy.and.callFake(function (success) {
                    success({});
                });

                // Act
                dateTimePicker.show({ mode: "date", success: cbSuccessSpy, error: cbErrorSpy, cancel: cbCancelSpy });

                // Assert
                expect(execSpy).toHaveBeenCalled();
                expect(cbSuccessSpy).toHaveBeenCalledWith();
                expect(cbErrorSpy).not.toHaveBeenCalled();
                expect(cbCancelSpy).not.toHaveBeenCalled();
            });
        });
    });
});

describe("hide", () => {
    describe("When hiding date picker", () => {
        beforeEach(() => {
            dateTimePicker.hide();
        });

        it("it should log", () => {
            expect(console.debug).toHaveBeenCalledOnceWith("DateTimePickerPlugin: Exec 'hide'.");
        });

        it("it should cordova exec", () => {
            expect(execSpy).toHaveBeenCalledOnceWith(null, jasmine.any(Function), "DateTimePicker", "hide");
        });
    });
});
