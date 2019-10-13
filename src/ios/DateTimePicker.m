#import "DateTimePicker.h"
#import "Extensions.h"
#import "ModalPickerViewController.h"
#import "TransparentCoverVerticalAnimator.h"

@interface DateTimePicker() // (Private)

// Configures the UIDatePicker with the NSMutableDictionary options.
- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker;

@end


@implementation DateTimePicker {
    BOOL _isVisible;
    NSString *_callbackId;
}

#pragma mark - Public Methods

- (void)pluginInitialize {
    [self initPickerView:self.webView.superview];
}

- (void)show:(CDVInvokedUrlCommand*)command {
    if (_isVisible) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ILLEGAL_ACCESS_EXCEPTION messageAsString:@"A date/time picker dialog is already showing."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    _callbackId = command.callbackId;

    NSMutableDictionary *optionsOrNil = [command.arguments objectAtIndex:command.arguments.count - 1];

    [self configureDatePicker:optionsOrNil datePicker:self.modalPicker.datePicker];

    // Present the view with our custom transition.
    [self.viewController presentViewController:self.modalPicker animated:YES completion:nil];

    _isVisible = YES;
}

- (void)hide:(CDVInvokedUrlCommand*)command {
    if (_isVisible) {
        // Hide the view with our custom transition.
        [self.modalPicker dismissViewControllerAnimated:true completion:nil];
        [self callbackCancelWithJavascript];
        _isVisible = NO;
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    TransparentCoverVerticalAnimator *animator = [TransparentCoverVerticalAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TransparentCoverVerticalAnimator *animator = [TransparentCoverVerticalAnimator new];
    return animator;
}

#pragma mark - Private Methods

- (void)initPickerView:(UIView*)theWebView {
    ModalPickerViewController *picker = [[ModalPickerViewController alloc] init];

    picker.modalPresentationStyle = UIModalPresentationCustom;
    picker.transitioningDelegate = self;

    picker.doneHandler = ^(id sender) {
        ModalPickerViewController *modelPicker = (ModalPickerViewController *)sender;
        if (modelPicker == nil) {
            [self callbackSuccessWithJavascript:nil];
        } else {
            [self callbackSuccessWithJavascript:modelPicker.datePicker.date];
        }
        _isVisible = NO;
    };

    picker.cancelHandler = ^() {
        [self callbackCancelWithJavascript];
        _isVisible = NO;
    };

    self.modalPicker = picker;
}

- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker {
    
    // Mode (must be set first, otherwise minuteInterval > 1 acts wonky).
    NSString *mode = [optionsOrNil objectForKey:@"mode"];
    if ([mode isEqualToString:@"date"]) {
        datePicker.datePickerMode = UIDatePickerModeDate;
    } else if ([mode isEqualToString:@"time"]) {
        datePicker.datePickerMode = UIDatePickerModeTime;
    } else {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
   
    // Locale.
    NSString *localeString = [optionsOrNil objectForKeyNotNull:@"locale"];
    datePicker.locale = localeString.length > 0 ? [[NSLocale alloc] initWithLocaleIdentifier:localeString] : [NSLocale currentLocale];
    
    // Texts.
    self.modalPicker.doneText = [optionsOrNil objectForKeyNotNull:@"okText"];
    self.modalPicker.cancelText = [optionsOrNil objectForKeyNotNull:@"cancelText"];
    self.modalPicker.clearText = [optionsOrNil objectForKeyNotNull:@"clearText"];
    self.modalPicker.titleText = [optionsOrNil objectForKeyNotNull:@"titleText"];

    // Minute interval.
    NSInteger minuteInterval = [[optionsOrNil objectForKeyNotNull:@"minuteInterval"] ?: [NSNumber numberWithInt:1] intValue];
    datePicker.minuteInterval = minuteInterval;
    
    // Allow old/future dates.
    BOOL allowOldDates = [[optionsOrNil objectForKeyNotNull:@"allowOldDates"] ?: [NSNumber numberWithInt:1] boolValue];
    BOOL allowFutureDates = [[optionsOrNil objectForKeyNotNull:@"allowFutureDates"] ?: [NSNumber numberWithInt:1] boolValue];
    
    // Min/max dates.
    NSDate *today = [NSDate today];
    long long todayTicks = ((long long)[today timeIntervalSince1970]) * DDBIntervalFactor;
    long long endOfTodayTicks = ((long long)[[[today addDay:1] addSecond:-1] timeIntervalSince1970]) * DDBIntervalFactor;
    NSNumber *minDateTicks = [optionsOrNil objectForKeyNotNull:@"minDateTicks"] ?: allowOldDates ? nil : [NSNumber numberWithLongLong:(todayTicks)];
    NSNumber *maxDateTicks = [optionsOrNil objectForKeyNotNull:@"maxDateTicks"] ?: allowFutureDates ? nil : [NSNumber numberWithLongLong:(endOfTodayTicks)];

    if (minDateTicks) {
        datePicker.minimumDate = [[NSDate dateWithTimeIntervalSince1970:([minDateTicks longLongValue] / DDBIntervalFactor)] roundDownToMinuteInterval:minuteInterval];
    } else {
        datePicker.minimumDate = nil;
    }
    if (maxDateTicks) {
        datePicker.maximumDate = [[NSDate dateWithTimeIntervalSince1970:([maxDateTicks longLongValue] / DDBIntervalFactor)] roundUpToMinuteInterval:minuteInterval];
    } else {
        datePicker.maximumDate = nil;
    }
    
    // Selected date.
    long long ticks = [[optionsOrNil objectForKey:@"ticks"] longLongValue];
    [datePicker setDate:[[NSDate dateWithTimeIntervalSince1970:(ticks / DDBIntervalFactor)] roundToMinuteInterval:minuteInterval] animated:FALSE];
}

// Sends the date to the plugin javascript handler.
- (void)callbackSuccessWithJavascript:(NSDate *)date {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    // When date is nil, user clicked 'clear' button so we dispatch success without ticks in that case.
    if (date != nil) {
        long long ticks = ((long long)[date timeIntervalSince1970]) * DDBIntervalFactor;
        [result setObject:[NSNumber numberWithLongLong:ticks] forKey:@"ticks"];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
}

// Sends a cancellation notification to the plugin javascript handler.
- (void)callbackCancelWithJavascript {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithBool:YES] forKey:@"cancelled"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
}

@end
