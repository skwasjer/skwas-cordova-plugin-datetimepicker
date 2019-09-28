#import "DateTimePicker.h"
#import "Extensions.h"
#import "ModalPickerViewController.h"
#import "TransparentCoverVerticalAnimator.h"

@interface DateTimePicker() // (Private)


// Configures the UIDatePicker with the NSMutableDictionary options
- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker;


@property (readwrite, assign) BOOL isVisible;
@property (strong) NSString* callbackId;

@end


@implementation DateTimePicker


@synthesize isVisible, callbackId;


#pragma mark - Public Methods


- (void)pluginInitialize {
    [self initPickerView:self.webView.superview];
}

- (void)show:(CDVInvokedUrlCommand*)command
{
    if (isVisible) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ILLEGAL_ACCESS_EXCEPTION messageAsString:@"A date/time picker dialog is already showing."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    self.callbackId = command.callbackId;

    NSMutableDictionary *optionsOrNil = [command.arguments objectAtIndex:command.arguments.count - 1];

    [self configureDatePicker:optionsOrNil datePicker:self.modalPicker.datePicker];

    // Present the view with our custom transition.
    [self.viewController presentViewController:self.modalPicker animated:YES completion:nil];

    isVisible = YES;
}

- (void)hide:(CDVInvokedUrlCommand*)command
{
    if (isVisible) {
        // Hide the view with our custom transition.
        [self.modalPicker dismissViewControllerAnimated:true completion:nil];
        [self callbackCancelWithJavascript];
        isVisible = NO;
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onMemoryWarning
{
    // It could be better to close the datepicker before the system clears memory. But in reality, other non-visible plugins should be tidying themselves at this point. This could cause a fatal at runtime.
    if (isVisible) {
        return;
    }

    [super onMemoryWarning];
}


#pragma mark UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    TransparentCoverVerticalAnimator *animator = [TransparentCoverVerticalAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TransparentCoverVerticalAnimator *animator = [TransparentCoverVerticalAnimator new];
    return animator;
}

#pragma mark - Private Methods

- (void)initPickerView:(UIView*)theWebView
{
    ModalPickerViewController *picker = [[ModalPickerViewController alloc] init];

    picker.modalPresentationStyle = UIModalPresentationCustom;
    picker.transitioningDelegate = self;

    picker.dismissedHandler = ^(id sender) {
        ModalPickerViewController *modelPicker = (ModalPickerViewController *)sender;
        if (modelPicker == nil)
        {
            [self callbackSuccessWithJavascript:nil];
        }
        else
        {
            [self callbackSuccessWithJavascript:modelPicker.datePicker.date];
        }
        isVisible = NO;
    };

    picker.cancelHandler = ^() {
        [self callbackCancelWithJavascript];
        isVisible = NO;
    };

    self.modalPicker = picker;
}

- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker;
{
    long long ticks = [[optionsOrNil objectForKey:@"ticks"] longLongValue];
    
    // Locale
    NSString *localeString = [optionsOrNil objectForKeyNotNull:@"locale"];
    if (localeString.length > 0)
    {
        datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:localeString];
    }
    else
    {
        datePicker.locale = [NSLocale currentLocale];
    }
    
    // Texts
    self.modalPicker.dismissText = [optionsOrNil objectForKeyNotNull:@"okText"];
    self.modalPicker.cancelText = [optionsOrNil objectForKeyNotNull:@"cancelText"];
    self.modalPicker.clearText = [optionsOrNil objectForKeyNotNull:@"clearText"];
    self.modalPicker.titleText = [optionsOrNil objectForKeyNotNull:@"titleText"];

    // Minute interval
    NSInteger minuteInterval = [[optionsOrNil objectForKeyNotNull:@"minuteInterval"] ?: [NSNumber numberWithInt:1] intValue];
    datePicker.minuteInterval = minuteInterval;
    
    // Allow old/future dates
    BOOL allowOldDates = ([[optionsOrNil objectForKeyNotNull:@"allowOldDates"] ?: [NSNumber numberWithInt:1] intValue]) == 1 ? YES : NO;
    BOOL allowFutureDates = ([[optionsOrNil objectForKeyNotNull:@"allowFutureDates"] ?: [NSNumber numberWithInt:1] intValue]) == 1 ? YES : NO;
    
    // Min/max dates
    NSDate *today = [NSDate today];
    long long todayTicks = ((long long)[today timeIntervalSince1970]) * DDBIntervalFactor;
    long long endOfTodayTicks = ((long long)[[[today addDay:1] addSecond:-1] timeIntervalSince1970]) * DDBIntervalFactor;
    long long minDateTicks = [[optionsOrNil objectForKeyNotNull:@"minDateTicks"] ?: [NSNumber numberWithLong:(allowOldDates ? DDBMinDate : todayTicks)] longLongValue];
    long long maxDateTicks = [[optionsOrNil objectForKeyNotNull:@"maxDateTicks"] ?: [NSNumber numberWithLong:(allowFutureDates ? DDBMaxDate : endOfTodayTicks)] longLongValue];
    if (minDateTicks > maxDateTicks)
    {
        minDateTicks = DDBMinDate;
    }
    datePicker.minimumDate = [[NSDate dateWithTimeIntervalSince1970:(minDateTicks / DDBIntervalFactor)] roundDownToMinuteInterval:minuteInterval];
    datePicker.maximumDate = [[NSDate dateWithTimeIntervalSince1970:(maxDateTicks / DDBIntervalFactor)] roundUpToMinuteInterval:minuteInterval];
    
    // Mode
    NSString *mode = [optionsOrNil objectForKey:@"mode"];
    if ([mode isEqualToString:@"date"])
    {
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ([mode isEqualToString:@"time"])
    {
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else
    {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    [datePicker setDate:[[NSDate dateWithTimeIntervalSince1970:(ticks / DDBIntervalFactor)] roundToMinuteInterval:minuteInterval] animated:FALSE];
}

// Sends the date to the plugin javascript handler.
- (void)callbackSuccessWithJavascript:(NSDate *)date
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    // When date is nil, user clicked 'clear' button so we dispatch success without ticks in that case.
    if (date != nil)
    {
        long long ticks = ((long long)[date timeIntervalSince1970]) * DDBIntervalFactor;
        [result setObject:[NSNumber numberWithLongLong:ticks] forKey:@"ticks"];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

// Sends a cancellation notification to the plugin javascript handler.
- (void)callbackCancelWithJavascript
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithBool:YES] forKey:@"cancelled"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end
