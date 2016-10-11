#import <UIKit/UIKit.h>

@interface ModalPickerViewController : UIViewController
{
}

- (id)initWithHeaderText:(NSString*)headerText
             dismissText:(NSString*)dismissText
             cancelText:(NSString*)cancelText;

@property (strong) UIColor *headerBackgroundColor;
@property (strong) UIColor *headerTextColor;
@property (strong) NSString *headerText;
@property (strong) NSString *dismissText;
@property (strong) NSString *cancelText;
@property (strong) UIDatePicker *datePicker;
@property (nonatomic, strong) void (^dismissedHandler)(id sender);
@property (nonatomic, strong) void (^cancelHandler)(id sender);

@end
