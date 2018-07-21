#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "ModalPickerViewController.h"

enum DTPDateBounds {
    DDBMinDate = -8640000000000000,
    DDBMaxDate = 8640000000000000,
    DDBIntervalFactor = 1000
};

@interface DateTimePicker : CDVPlugin <UIViewControllerTransitioningDelegate> {
   
}
    
@property (strong) ModalPickerViewController* modalPicker;

- (void)show:(CDVInvokedUrlCommand*)command;

- (void)hide:(CDVInvokedUrlCommand*)command;

@end

