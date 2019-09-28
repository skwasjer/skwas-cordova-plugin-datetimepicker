#import "ModalPickerViewController.h"

@interface ModalPickerViewController()

@property (strong) UIView *internalView;

@property (strong) UIBarButtonItem *doneButton;
@property (strong) UIBarButtonItem *clearButton;
@property (strong) UIBarButtonItem *cancelButton;

@end

@implementation ModalPickerViewController


const float _headerBarHeight = 42;
const float _datePickerHeight = 200;

- (id)init
{
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self createControls];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_internalView removeFromSuperview];
    _internalView = nil;

    _doneButton = nil;
    _clearButton = nil;
    _cancelButton = nil;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)createControls {

    // Measurements of our internal view.
    CGRect viewFrame = self.view.frame;
    CGSize internalViewSize = CGSizeMake(viewFrame.size.width, _datePickerHeight + _headerBarHeight + 4);
    CGRect internalViewFrame = CGRectMake(0, viewFrame.size.height - internalViewSize.height, internalViewSize.width, internalViewSize.height);

    // Create a view that will host our controls.
    _internalView = [[UIView alloc] init];
    _internalView.frame = internalViewFrame;
    _internalView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _internalView.backgroundColor = [UIColor colorWithWhite:1 alpha:.85f];
    _internalView.opaque = FALSE;
    
    CGRect navBarFrame = CGRectMake(0, 1, viewFrame.size.width, _headerBarHeight);
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navigationBar.backgroundColor = [UIColor grayColor];
    navigationBar.translucent = YES;
    
    // Navigation item
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:_titleText];
    [navigationBar setItems:@[navItem]];
    
    // Right buttons
    if (_dismissText != (id)[NSNull null] && _dismissText.length > 0) {
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:_dismissText style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    }
    else {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    }
    [navItem setRightBarButtonItem:_doneButton animated:NO];
    
    if (_clearText != (id)[NSNull null] && _clearText.length > 0) {
        _clearButton = [[UIBarButtonItem alloc] initWithTitle:_clearText style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonTapped:)];
        [navItem setRightBarButtonItems:@[_doneButton, _clearButton] animated:NO];
    }
    
    // Left button
    if (_cancelText != (id)[NSNull null] && _cancelText.length > 0) {
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:_cancelText style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
    }
    else {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    }
    [navItem setLeftBarButtonItem:_cancelButton animated:NO];
    
    // Set the date picker.
    _datePicker.autoresizingMask = UIViewAutoresizingNone;
    _datePicker.frame = CGRectMake(0, navigationBar.frame.origin.y + navigationBar.frame.size.height + 3, internalViewSize.width, _datePickerHeight);
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _datePicker.backgroundColor = [UIColor whiteColor];

    [_internalView addSubview:_datePicker];
    [_internalView addSubview:navigationBar];

    [self.view addSubview:_internalView];
}


#pragma mark - Button handlers

- (void)doneButtonTapped:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:true completion:^(void) {
        // Call the callback.
        if (self.dismissedHandler != nil) [self dismissedHandler](self);
    }];
}

- (void)cancelButtonTapped:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:true completion:^(void) {
        // Call the callback.
        if (self.cancelHandler != nil) [self cancelHandler]();
    }];
}

- (void)clearButtonTapped:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:true completion:^(void) {
        // Call the callback.
        if (self.dismissedHandler != nil) [self dismissedHandler](nil);
    }];
}
@end
