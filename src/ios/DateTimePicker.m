#import "DateTimePicker.h"
#import "ModalPickerViewController.h"
#import "TransparentCoverVerticalAnimator.h"

@interface DateTimePicker() // (Private)


// Creates the NSDateFormatter with NSString format and NSTimeZone timezone
- (NSDateFormatter *)createISODateFormatter:(NSString *)format timezone:(NSTimeZone *)timezone;

// Configures the UIDatePicker with the NSMutableDictionary options
- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker;


@property (readwrite, assign) BOOL isVisible;
@property (strong) NSString* callbackId;

@end


@implementation DateTimePicker


@synthesize isVisible, callbackId;


#pragma mark - Public Methods


- (void)pluginInitialize {
    self.isoDateFormatter = [self createISODateFormatter:k_DATEPICKER_DATETIME_FORMAT timezone:[NSTimeZone defaultTimeZone]];
    
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
        isVisible = NO;
    };
    
    self.modalPicker = picker;
}

- (NSDateFormatter *)createISODateFormatter:(NSString *)format timezone:(NSTimeZone *)timezone;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:format];
    return dateFormatter;
}

- (NSDate *)getRoundedDate:(NSDate *)inDate minuteInterval:(NSInteger)minuteInterval
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:inDate];
    NSInteger minutes = [dateComponents minute];
    NSInteger minutesRounded = ( (NSInteger)(minutes / minuteInterval) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded - minutes) sinceDate:inDate];
    return roundedDate;
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Set the date picker's value (and the selected date on the UI display) to
    // the rounded date.
    /*      if ([roundedDate isEqualToDate:inDate])
     {
     // We need to set the date picker's value to something different than
     // the rounded date, because the second call to set the date picker's
     // date with the same value is ignored. Which could be bad since the
     // call above to set the date picker's minute interval can leave the
     // date picker with the wrong selected date (the whole reason why we are
     // doing this).
     NSDate *diffrentDate = [[NSDate alloc] initWithTimeInterval:60 sinceDate:roundedDate];
     returnDate = diffrentDate;
     //[diffrentDate release];
     }
     
     returnDate = roundedDate;
     return returnDate;*/
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
    
    // Lastly, set to something else first, to force an update.
    datePicker.date = [NSDate dateWithTimeIntervalSince1970:0];
   // datePicker.date = [self getRoundedDate:[self.isoDateFormatter dateFromString:dateString]  minuteInterval:minuteInterval];
    datePicker.date = [self getRoundedDate:[[NSDate alloc] initWithTimeIntervalSince1970:(ticks / 1000)] minuteInterval:minuteInterval];
}

// Sends the date to the plugin javascript handler.
- (void)callbackSuccessWithJavascript:(NSDate *)date {
    long long ticks = ((long long)(int)[date timeIntervalSince1970]) * 1000;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithLongLong:ticks] forKey:@"ticks"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end

