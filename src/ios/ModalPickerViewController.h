#import <UIKit/UIKit.h>

@interface ModalPickerViewController : UIViewController {
}

- (id)init;

@property (strong) NSString *titleText;
@property (strong) NSString *doneText;
@property (strong) NSString *clearText;
@property (strong) UIDatePicker *datePicker;
@property (nonatomic, strong) void (^doneHandler)(id sender);
@property (nonatomic, strong) void (^clearHandler)(id sender);

@end
