#import "ModalPickerViewController.h"

@interface ModalPickerViewController()

@property (strong) UILabel* headerLabel;
@property (strong) UIButton *doneButton;
@property (strong) UIButton *cancelButton;
@property (strong) UIView *internalView;

@end

@implementation ModalPickerViewController


const float _headerBarHeight = 38;
const float _datePickerHeight = 200;

const CGSize _doneButtonSize = { 80, 30 };
const CGSize _cancelButtonSize = { 80, 30 };
const float _buttonMargin = 10;


- (id)initWithHeaderText:(NSString*)headerText
             dismissText:(NSString*)dismissText
             cancelText:(NSString*)cancelText {
    self.headerBackgroundColor = [UIColor whiteColor];
    self.headerTextColor = [UIColor blackColor];
    self.headerText = headerText;
    self.dismissText = dismissText;
    self.cancelText = cancelText;

    [self createControls];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _internalView.backgroundColor = _headerBackgroundColor;
    _headerLabel.textColor = _headerTextColor;
    _headerLabel.text = _headerText;
    
    [_doneButton setTitle:_dismissText forState:UIControlStateNormal];
    [_cancelButton setTitle:_cancelText forState:UIControlStateNormal];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)createControls {
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    
    // Measurements of our internal view.
    CGRect viewFrame = self.view.frame;
    CGSize internalViewSize = CGSizeMake(viewFrame.size.width, _datePickerHeight + _headerBarHeight);
    CGRect internalViewFrame = CGRectMake(0, viewFrame.size.height - internalViewSize.height, internalViewSize.width, internalViewSize.height);

    // Create header label.
    float labelWidth = internalViewSize.width - _doneButtonSize.width - _cancelButtonSize.width - _buttonMargin * 2;
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((internalViewSize.width - labelWidth) / 2, 0, labelWidth, _headerBarHeight)];
    _headerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
   // _headerLabel.backgroundColor = self.headerBackgroundColor;
    _headerLabel.adjustsFontSizeToFitWidth = NO;
    _headerLabel.textAlignment = NSTextAlignmentCenter;
    _headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    // Create done button.
    _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _doneButton.frame = CGRectMake(internalViewFrame.size.width - _doneButtonSize.width - _buttonMargin, _buttonMargin / 2, _doneButtonSize.width, _doneButtonSize.height);
    _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _doneButton.backgroundColor = [UIColor clearColor];
    _doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize] * 1.1];
    [_doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create cancel button.
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton.frame = CGRectMake(_buttonMargin, _buttonMargin / 2, _cancelButtonSize.width, _cancelButtonSize.height);
    _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _cancelButton.backgroundColor = [UIColor clearColor];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] * 1.1];
    [_cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create the date picker.
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _datePicker.frame = CGRectMake(0, _headerBarHeight, internalViewSize.width, _datePickerHeight);
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _datePicker.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85f];

    // Create a view that will host our controls.
    _internalView = [[UIView alloc] init];
    _internalView.frame = internalViewFrame;
    _internalView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;

    [_internalView addSubview:_datePicker];
    [_internalView addSubview:_headerLabel];
    [_internalView addSubview:_doneButton];
    [_internalView addSubview:_cancelButton];
    
    [self.view addSubview:_internalView];
}


#pragma mark - Button handlers

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
    // Call the callback.
    if (self.dismissedHandler != nil) [self dismissedHandler](self);
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
    // Call the callback.
    if (self.cancelHandler != nil) [self cancelHandler](self);
}

@end
