#import "DateTimePicker.h"
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
    if (isVisible) return;
    
    self.callbackId = command.callbackId;
    
    NSMutableDictionary *optionsOrNil = [command.arguments objectAtIndex:command.arguments.count - 1];
        
    [self configureDatePicker:optionsOrNil datePicker:self.modalPicker.datePicker];
            
    // Present the view with our custom transition.
    [self.viewController presentViewController:self.modalPicker animated:YES completion:nil];
    
    isVisible = YES;
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
    ModalPickerViewController *picker = [[ModalPickerViewController alloc]
                                         initWithHeaderText:@""
                                         dismissText:@""
                                         cancelText:@""];
    
    picker.modalPresentationStyle = UIModalPresentationCustom;
    picker.transitioningDelegate = self;

    __weak ModalPickerViewController* weakPicker = picker;
    
    picker.headerBackgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.92f alpha:0.95f];
    
    picker.dismissedHandler = ^(id sender) {
        [self callbackSuccessWithJavascript:weakPicker.datePicker.date];
        isVisible = NO;
    };
    
    picker.cancelHandler = ^(id sender) {
        [self callbackCancelWithJavascript];
        isVisible = NO;
    };
    
    self.modalPicker = picker;
}

- (NSDate *)getRoundedDate:(NSDate *)inDate minuteInterval:(NSInteger)minuteInterval
{
    NSDate *truncatedDate = [self truncateSecondsForDate:inDate];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:truncatedDate];
    NSInteger minutes = [dateComponents minute];
    NSInteger minutesRounded = ( (NSInteger)(minutes / minuteInterval) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:truncatedDate];
    return roundedDate;
}

- (NSDate *)truncateSecondsForDate:(NSDate *)fromDate;
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *fromDateComponents = [gregorian components:unitFlags fromDate:fromDate ];
    return [gregorian dateFromComponents:fromDateComponents];
}

- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker;
{
    NSString *mode = [optionsOrNil objectForKey:@"mode"];
    long long ticks = [[optionsOrNil objectForKey:@"ticks"] longLongValue];
    NSString *localeString = [optionsOrNil objectForKey:@"locale"];
    NSString *okTextString = [optionsOrNil objectForKey:@"okText"];
    NSString *cancelTextString = [optionsOrNil objectForKey:@"cancelText"];
    BOOL allowOldDates = [[optionsOrNil objectForKey:@"allowOldDates"] intValue] == 1 ? YES : NO;
    BOOL allowFutureDates = [[optionsOrNil objectForKey:@"allowFutureDates"] intValue] == 1 ? YES : NO;
    NSInteger minuteInterval = [[optionsOrNil objectForKey:@"minuteInterval"] intValue];
    
    if (localeString == nil || localeString.length == 0) localeString = @"EN";
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:localeString];

    if (okTextString == nil || okTextString.length == 0) okTextString = @"Select";
    if (cancelTextString == nil || cancelTextString.length == 0) cancelTextString = @"Cancel";

    self.modalPicker.dismissText = okTextString;
    self.modalPicker.cancelText = cancelTextString;

    if (!allowOldDates) datePicker.minimumDate = [NSDate date];
    if (!allowFutureDates) datePicker.maximumDate = [NSDate date];
    
    if ([mode isEqualToString:@"date"])
        datePicker.datePickerMode = UIDatePickerModeDate;
    else if ([mode isEqualToString:@"time"])
        datePicker.datePickerMode = UIDatePickerModeTime;
    else
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    datePicker.minuteInterval = minuteInterval;
    
    // Set to something else first, to force an update.
    datePicker.date = [NSDate dateWithTimeIntervalSince1970:0];
    datePicker.date = [self getRoundedDate:[[NSDate alloc] initWithTimeIntervalSince1970:(ticks / 1000)] minuteInterval:minuteInterval];
}

// Sends the date to the plugin javascript handler.
- (void)callbackSuccessWithJavascript:(NSDate *)date
{
    long long ticks = ((long long)(int)[date timeIntervalSince1970]) * 1000;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithLongLong:ticks] forKey:@"ticks"];
    
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

