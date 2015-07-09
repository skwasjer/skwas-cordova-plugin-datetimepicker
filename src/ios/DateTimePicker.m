//        Phonegap DatePicker Plugin
//        Copyright (c) Greg Allen 2011
//        MIT Licensed
//
//  Additional refactoring by Sam de Freyssinet


#import "DateTimePicker.h"
#import "ModalPickerViewController.h"
#import "TransparentCoverVerticalAnimator.h"

@interface DateTimePicker (Private)


// Initialize the UIActionSheet with ID <UIActionSheetDelegate> delegate UIDatePicker datePicker (UISegmentedControl)closeButton
- (void)initActionSheet:(id <UIActionSheetDelegate>)delegateOrNil datePicker:(UIDatePicker *)datePicker closeButton:(UISegmentedControl *)closeButton;


// Creates the NSDateFormatter with NSString format and NSTimeZone timezone
- (NSDateFormatter *)createISODateFormatter:(NSString *)format timezone:(NSTimeZone *)timezone;


// Creates the UIDatePicker with NSMutableDictionary options
- (UIDatePicker *)createDatePicker:(CGRect)pickerFrame;


// Creates the UISegmentedControl with UIView parentView, NSString title, ID target and SEL action
- (UISegmentedControl *)createCloseButton:(NSString *)title target:(id)target action:(SEL)action;


// Configures the UIDatePicker with the NSMutableDictionary options
- (void)configureDatePicker:(NSMutableDictionary *)optionsOrNil datePicker:(UIDatePicker *)datePicker;


@end


@implementation DateTimePicker


@synthesize datePickerSheet = _datePickerSheet;
@synthesize datePicker = _datePicker;
@synthesize datePickerCloseButton = _datePickerCloseButton;
@synthesize isoDateFormatter = _isoDateFormatter;
@synthesize modalPicker = _modalPicker;


#pragma mark - Public Methods


- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView
{
    self = (DateTimePicker *)[super initWithWebView:theWebView];
    
    if (self)
    {
        self.isoDateFormatter = [self createISODateFormatter:k_DATEPICKER_DATETIME_FORMAT timezone:[NSTimeZone defaultTimeZone]];
        
        BOOL lessThenIOS7 = floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
        
        if (lessThenIOS7) {
            self.datePicker = [self createDatePicker:CGRectMake(0, 40, 0, 0)];
            
            _datePickerCloseButton = [self createCloseButton:@"" target:self action:@selector(dismissPicker:)];
            
            [self initActionSheet:self datePicker:self.datePicker closeButton:_datePickerCloseButton];
        } else {
            [self initPickerView:theWebView.superview];
        }
    }
    
    return self;
}

- (void)show:(CDVInvokedUrlCommand*)command
{
    if (isVisible) return;
    
    [self.commandDelegate runInBackground:^{
        NSMutableDictionary *optionsOrNil = [command.arguments objectAtIndex:command.arguments.count - 1];
        
        _callbackId = command.callbackId;
        
        if (self.datePickerSheet != nil) {
            UIView *webView = super.webView;
            
            [self configureDatePicker:optionsOrNil datePicker:self.datePicker];
            [self.datePickerSheet showInView:webView.superview];
            
            CGSize frameSize = webView.frame.size;
            BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
            if (!isPortrait) {
                frameSize.height = frameSize.width;
                frameSize.width = webView.frame.size.height;
            }
            
            [self.datePickerSheet setBounds:CGRectMake(0, 0, frameSize.width, frameSize.height + 30)];
        } else {
            [self configureDatePicker:optionsOrNil datePicker:_modalPicker.datePicker];
            
            // Present the view with our custom transition.
            _modalPicker.transitioningDelegate = self;
            _modalPicker.modalPresentationStyle = UIModalPresentationCustom;
            [self.viewController presentViewController:_modalPicker animated:YES completion:nil];
        }
    }];
    
    isVisible = YES;
}

- (void)dismissPicker:(id)sender
{
    [self.datePickerSheet dismissWithClickedButtonIndex:0 animated:YES];
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


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self callbackSuccessWithJavascript:self.datePicker.date];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    isVisible = NO;
}


#pragma mark - Private Methods

- (void)initPickerView:(UIView*)theWebView
{
    ModalPickerViewController *picker = [[ModalPickerViewController alloc]
                                         initWithPickerType:ModalPickerTypeDate
                                         headerText:@""
                                         dismissText:@""
                                         cancelText:@""
                                         parent:theWebView];
    
    __weak ModalPickerViewController *weakPicker = picker;
    
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

- (void)initActionSheet:(id <UIActionSheetDelegate>)delegateOrNil datePicker:(UIDatePicker *)datePicker closeButton:(UISegmentedControl *)closeButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:delegateOrNil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet addSubview:datePicker];
    [actionSheet addSubview:closeButton];
    
    self.datePickerSheet = actionSheet;
}


- (UIDatePicker *)createDatePicker:(CGRect)pickerFrame
{
    UIDatePicker *datePickerControl = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    return datePickerControl;
}

- (NSDateFormatter *)createISODateFormatter:(NSString *)format timezone:(NSTimeZone *)timezone;
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:format];
    return dateFormatter;
}

- (UISegmentedControl *)createCloseButton:(NSString *)title target:(id)target action:(SEL)action
{
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:title]];
    
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(230, 7.0f, 80, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    
    
    [closeButton addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    
    return closeButton;
}

- (NSDate *)getRoundedDate:(NSDate *)inDate minuteInterval:(NSInteger)minuteInterval
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:inDate];
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

    if (self.modalPicker != nil) {
        self.modalPicker.dismissText = okTextString;
        self.modalPicker.cancelText = cancelTextString;
    }
    else if (self.datePickerSheet != nil) {
        [self.datePickerCloseButton setTitle:okTextString forSegmentAtIndex:0];
    }

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
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
}

@end

