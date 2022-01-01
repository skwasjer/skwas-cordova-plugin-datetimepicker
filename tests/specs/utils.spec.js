/* eslint-env jasmine */
const sut = "../../www/utils";

const mock = require("mock-require");
mock("cordova/utils", {
    typeName: () => "undefined"
});

let utils = require(sut);

const testCases = {
    string: "string",
    bool: true,
    number: 0,
    date: new Date(),
    object: {},
    undefined: undefined,
    function: function () { }
};

const getTestCases = condition => {
    return Object.keys(testCases)
        .filter(v => typeof condition === "undefined" || condition(v))
        .map(k => testCases[k]);
};

const getTestCasesOnly = function () {
    return getTestCases(v => [...arguments].some(e => e === v));
};

const getTestCasesExcept = function () {
    return getTestCases(v => ![...arguments].some(e => e === v));
};

beforeEach(function () {
    spyOn(console, "debug");
    spyOn(console, "error");
});

describe("isValidMode", () => {
    describe("When value is a valid mode", () => {
        it("should return true", () => {
            ["date", "time", "datetime", "Date", "TIME", "DateTime"].forEach(value => {
                expect(utils.isValidMode(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is a not valid mode", () => {
        it("should return true", () => {
            ["dates", "none", "stime", "datetimes"].forEach(value => {
                expect(utils.isValidMode(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("is", () => {
    describe("When value is the expected type", () => {
        it("should return true", () => {
            expect(utils.is("i am a string", "string")).toBeTrue();
        });
    });

    describe("When value is not the expected type", () => {
        it("should return false", () => {
            expect(utils.is("i am a string", "bool")).toBeFalse();
        });
    });
});

describe("isDate", () => {
    describe("When value is not a date", () => {
        beforeEach(() => {
            mock("cordova/utils", {
                typeName: () => "undefined"
            });
            utils = mock.reRequire(sut);
        });

        it("should return false", () => {
            expect(utils.isDate("not a date")).toBeFalse();
        });
    });

    describe("When value is a date", () => {
        beforeEach(() => {
            mock("cordova/utils", {
                typeName: () => "Date"
            });
            utils = mock.reRequire(sut);
        });

        it("should return true", () => {
            expect(utils.isDate(new Date())).toBeTrue();
        });
    });

    describe("When getTime() is not a number", () => {
        beforeEach(() => {
            mock("cordova/utils", {
                typeName: () => "Date"
            });
            utils = mock.reRequire(sut);
        });

        it("should return false", () => {
            const nan = new Date("nan");

            expect(utils.isDate(nan)).toBeFalse();
        });
    });
});

describe("isUndefined", () => {
    describe("When value is undefined", () => {
        it("should return true", () => {
            expect(utils.isUndefined(undefined)).toBeTrue();
        });
    });

    describe("When value is defined", () => {
        it("should return false", () => {
            getTestCasesExcept("undefined").forEach(value => {
                expect(utils.isUndefined(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("isDefined", () => {
    describe("When value is undefined", () => {
        it("should return true", () => {
            getTestCasesExcept("undefined").forEach(value => {
                expect(utils.isDefined(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is defined", () => {
        it("should return false", () => {
            expect(utils.isDefined(undefined)).toBeFalse();
        });
    });
});

describe("isFunction", () => {
    describe("When value is a function", () => {
        it("should return true", () => {
            getTestCasesOnly("function").forEach(value => {
                expect(utils.isFunction(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is not a function", () => {
        it("should return false", () => {
            getTestCasesExcept("function").forEach(value => {
                expect(utils.isFunction(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("isObject", () => {
    describe("When value is an object", () => {
        it("should return true", () => {
            getTestCasesOnly("object", "date").forEach(value => {
                expect(utils.isObject(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is not an object", () => {
        it("should return false", () => {
            getTestCasesExcept("object", "date").forEach(value => {
                expect(utils.isObject(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("isObject", () => {
    describe("When value is a string", () => {
        it("should return true", () => {
            getTestCasesOnly("string").forEach(value => {
                expect(utils.isString(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is not a string", () => {
        it("should return false", () => {
            getTestCasesExcept("string", "date").forEach(value => {
                expect(utils.isString(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("isNumber", () => {
    describe("When value is a number", () => {
        it("should return true", () => {
            getTestCasesOnly("number").forEach(value => {
                expect(utils.isNumber(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is not a number", () => {
        it("should return false", () => {
            getTestCasesExcept("number", "date").forEach(value => {
                expect(utils.isNumber(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("isMinuteInterval", () => {
    describe("When value is a minute interval", () => {
        it("should return true", () => {
            [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, "1", "30"].forEach(value => {
                expect(utils.isMinuteInterval(value)).toBeTrue(`failed on: ${value}`);
            });
        });
    });

    describe("When value is not a minute interval", () => {
        it("should return false", () => {
            [-1, -10, 7, 17, 1.1, true, false, "", {}].forEach(value => {
                expect(utils.isMinuteInterval(value)).toBeFalse(`failed on: ${value}`);
            });
        });
    });
});

describe("getErrorHandler", () => {
    const error = new Error();

    describe("When calling handler without callback", () => {
        it("should log as error", () => {
            const handler = utils.getErrorHandler();

            // Act
            handler(error);

            // Assert
            expect(console.error).toHaveBeenCalledWith("DateTimePickerPlugin: " + error);
        });
    });

    describe("When calling handler with callback", () => {
        const callback = jasmine.createSpy("spy");

        beforeEach(() => {
            const handler = utils.getErrorHandler(callback);
            handler(error);
        });

        it("should log as debug", () => {
            expect(console.debug).toHaveBeenCalledWith("DateTimePickerPlugin: " + error);
        });

        it("should call callback", () => {
            expect(callback).toHaveBeenCalledWith(error);
        });
    });
});

describe("validate", () => {
    const testObject = {
        myField: 123
    };

    describe("When validating succeeds", () => {
        it("should return true", () => {
            const actual = utils.validate(utils.isNumber, testObject, "myField");

            expect(actual).toBeTrue();
        });
    });

    describe("When validating fails", () => {
        it("should throw", () => {
            const expectedError = new Error("The value '123' for option 'myField' is invalid.");
            const fn = () => utils.validate(utils.isString, testObject, "myField");

            expect(fn).toThrow(expectedError);
        });

        it("should throw with custom message", () => {
            const expectedError = new Error("The value '123' for option 'myField' is invalid. custom message");
            const fn = () => utils.validate(utils.isString, testObject, "myField", "custom message");

            expect(fn).toThrow(expectedError);
        });
    });
});
