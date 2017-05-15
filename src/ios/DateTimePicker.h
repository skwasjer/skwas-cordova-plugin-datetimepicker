#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "ModalPickerViewController.h"

#ifndef k_DATEPICKER_DATETIME_FORMAT
#define k_DATEPICKER_DATETIME_FORMAT @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#endif


@interface DateTimePicker : CDVPlugin <UIViewControllerTransitioningDelegate> {
   
}
    
@property (strong) ModalPickerViewController* modalPicker;

- (void)show:(CDVInvokedUrlCommand*)command;
    
@end

