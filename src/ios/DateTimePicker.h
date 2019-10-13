#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "ModalPickerViewController.h"

enum DTPDateBounds {
    DDBIntervalFactor = 1000
};

@interface DateTimePicker : CDVPlugin <UIViewControllerTransitioningDelegate> {
}
    
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)hide:(CDVInvokedUrlCommand*)command;

@property (strong) ModalPickerViewController* modalPicker;

@end

