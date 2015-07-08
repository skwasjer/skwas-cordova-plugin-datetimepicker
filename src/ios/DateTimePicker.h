//        Phonegap DatePicker Plugin
//        Copyright (c) Greg Allen 2011
//        MIT Licensed


#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "ModalPickerViewController.h"

#ifndef k_DATEPICKER_DATETIME_FORMAT
#define k_DATEPICKER_DATETIME_FORMAT @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#endif


@interface DateTimePicker : CDVPlugin <UIActionSheetDelegate, UIViewControllerTransitioningDelegate> {
    UIActionSheet *_datePickerSheet;
    UIDatePicker *_datePicker;
    NSDateFormatter *_isoDateFormatter;
    ModalPickerViewController *_modalPicker;
    BOOL isVisible;
    
//    CDVInvokedUrlCommand *_command;
    NSString *_callbackId;
}
    
    
@property (nonatomic, retain) UIActionSheet* datePickerSheet;
@property (nonatomic, retain) UIDatePicker* datePicker;
@property (nonatomic, retain) UISegmentedControl *datePickerCloseButton;
@property (nonatomic, retain) NSDateFormatter* isoDateFormatter;
@property (nonatomic, retain) ModalPickerViewController* modalPicker;

//- (void) show:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)show:(CDVInvokedUrlCommand*)command;
    
@end

