//
//  ModalPickerViewController.h
//  Qlinx
//
//  Created by Qlinx Mini on 26/09/14.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    ModalPickerTypeDate = 0,
    ModalPickerTypeCustom = 1
} ModalPickerType;

@interface ModalPickerViewController : UIViewController
{
  //  void (^_dismissedHandler)(id sender);
}

- (id)initWithPickerType:(ModalPickerType)pickerType
              headerText:(NSString*)headerText
             dismissText:(NSString*)dismissText
             cancelText:(NSString*)cancelText
                  parent:(UIView*)parent;

@property (strong) UIColor *headerBackgroundColor;
@property (strong) UIColor *headerTextColor;
@property (strong) NSString *headerText;
@property (strong) NSString *dismissText;
@property (strong) NSString *cancelText;
@property (strong) UIDatePicker *datePicker;
@property (strong) UIPickerView *pickerView;
@property ModalPickerType pickerType;
@property (nonatomic, strong) void (^dismissedHandler)(id sender);
@property (nonatomic, strong) void (^cancelHandler)(id sender);

//    self.dismissedHandler = ^(void) {
//
// };

@end
