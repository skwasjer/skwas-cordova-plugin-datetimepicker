#import <UIKit/UIKit.h>

@interface ModalPickerViewController : UIViewController
{
}

- (id)init;

@property (strong) NSString *titleText;
@property (strong) NSString *dismissText;
@property (strong) NSString *cancelText;
@property (strong) NSString *clearText;
@property (strong) UIDatePicker *datePicker;
@property (nonatomic, strong) void (^dismissedHandler)(id sender);
@property (nonatomic, strong) void (^cancelHandler)();

@end
