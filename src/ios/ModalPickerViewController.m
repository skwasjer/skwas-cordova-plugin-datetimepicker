#import "ModalPickerViewController.h"
#import "Extensions.h"

static const float kHeaderBarHeight = 44;
static const float kHeaderBarHeightSmall = 32;
static const float kDatePickerHeight = 200;

@interface ModalPickerViewController()

@end

@implementation ModalPickerViewController {
    UIView *_internalView;

    UINavigationBar *_navigationBar;
    UINavigationItem *_navigationItem;

    UIBarButtonItem *_doneButton;
    UIBarButtonItem *_clearButton;
    UIBarButtonItem *_cancelButton;

    NSLayoutConstraint *_navBarHeight;
    
    UIColor *lightBackgroundColor;
    UIColor *lightDatePickerBackgroundColor;
    UIColor *lightButtonLabelColor;
    UIColor *darkBackgroundColor;
    UIColor *darkDatePickerBackgroundColor;
    UIColor *darkButtonLabelColor;
}

- (id)init {
    if ((self = [super init])) {
        _datePicker = [[UIDatePicker alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    
    [self createSwatches];
    [self createControls];
}

- (void)didReceiveMemoryWarning {
    if (!(self.isViewLoaded && self.view.window)) {
        [_navigationBar removeFromSuperview];
        [_internalView removeFromSuperview];
        [_datePicker removeFromSuperview];
        // Do NOT reset datepicker ref.
        _navigationBar = nil;
        _navigationItem = nil;
        _internalView = nil;
    
        _doneButton = nil;
        _clearButton = nil;
        _cancelButton = nil;
        
        lightBackgroundColor = nil;
        darkBackgroundColor = nil;
        lightDatePickerBackgroundColor = nil;
        darkDatePickerBackgroundColor = nil;
        lightButtonLabelColor = nil;
        darkButtonLabelColor = nil;
        
        _navBarHeight = nil;
    }
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!_internalView) {
        [self createSwatches];
        [self createControls];
    }
    
    // Update texts.
    _navigationItem.title = _titleText;

    _doneButton.title = _doneText != (id)[NSNull null] && _doneText.length > 0 ? _doneText : UIKitLocalizedString(@"Done");
    _cancelButton.title = _cancelText != (id)[NSNull null] && _cancelText.length > 0 ? _cancelText : UIKitLocalizedString(@"Cancel");
    
    // Show clear button when clear text is set
    if (_clearText != (id)[NSNull null] && _clearText.length > 0) {
        _clearButton.title = _clearText;
        [_navigationItem setRightBarButtonItems:@[_doneButton, _clearButton] animated:NO];
    } else {
        _clearButton.title = nil;
        [_navigationItem setRightBarButtonItems:@[_doneButton] animated:NO];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillLayoutSubviews {
    [self updateStyles];
    [super viewWillLayoutSubviews];
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [self updateStyles];
    [super traitCollectionDidChange: previousTraitCollection];
}

#pragma mark - Controls/styling

- (void)createControls {
    // Create a view that will host our controls.
    _internalView = [[UIView alloc] init];
    _internalView.opaque = FALSE;
    
    // Nav bar
    _navigationBar = [[UINavigationBar alloc] init];
    _navigationBar.translucent = TRUE;
    _navigationBar.opaque = FALSE;
    
    _navigationItem = [[UINavigationItem alloc] init];
    [_navigationBar setItems:@[_navigationItem]];

    // Right buttons
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    [_navigationItem setRightBarButtonItem:_doneButton animated:NO];

    _clearButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonTapped:)];
    
    // Left button
    _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
    [_navigationItem setLeftBarButtonItem:_cancelButton animated:NO];

    // Custom hairline above header.
    addHairLine(_internalView.layer, CGSizeMake(0, -1));

    // Add to view
    [_internalView addSubview:_datePicker];
    [_internalView addSubview:_navigationBar];
    [self.view addSubview:_internalView];

    // Set constraints.
    _internalView.translatesAutoresizingMaskIntoConstraints = FALSE;
    _datePicker.translatesAutoresizingMaskIntoConstraints = FALSE;
    _navigationBar.translatesAutoresizingMaskIntoConstraints = FALSE;
        
    NSLayoutConstraint *viewWidth = [NSLayoutConstraint constraintWithItem:_internalView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *viewHeight = [NSLayoutConstraint constraintWithItem:_internalView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kHeaderBarHeight + kDatePickerHeight];
    NSLayoutConstraint *viewBottom = [NSLayoutConstraint constraintWithItem:_internalView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];

    NSLayoutConstraint *navBarTop = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_internalView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *navBarWidth = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_internalView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    _navBarHeight = [NSLayoutConstraint constraintWithItem:_navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:kHeaderBarHeightSmall];

    NSLayoutConstraint *datePickerTop = [NSLayoutConstraint constraintWithItem:_datePicker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_navigationBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *datePickerBottom = [NSLayoutConstraint constraintWithItem:_datePicker attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_internalView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *datePickerWidth = [NSLayoutConstraint constraintWithItem:_datePicker attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_internalView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

    [NSLayoutConstraint activateConstraints:@[
        viewWidth, viewBottom, viewHeight,
        navBarTop, navBarWidth, _navBarHeight,
        datePickerTop, datePickerBottom, datePickerWidth
    ]];
}

- (void)createSwatches {
    lightBackgroundColor = [UIColor colorWithR:240 G:240 B:240 A:1];
    darkBackgroundColor = [UIColor colorWithR:67 G:67 B:67 A:1];
    lightDatePickerBackgroundColor = [UIColor colorWithR:209 G:212 B:217 A:1];
    darkDatePickerBackgroundColor = [UIColor colorWithR:87 G:87 B:87 A:1];
    if (@available(iOS 13, *)) {
        lightButtonLabelColor = [UIColor linkColor];
        darkButtonLabelColor = [UIColor labelColor];
    } else {
        lightButtonLabelColor = [UIColor systemBlueColor];
        darkButtonLabelColor = [UIColor whiteColor];
    }
}

- (void)updateStyles {
    // System font may have changed.
    CGFloat buttonFontSize = [UIFont systemFontSize] * 1.05;
    CGFloat largeButtonFontSize = buttonFontSize * 1.15;
    [_doneButton setFont:[UIFont boldSystemFontOfSize:buttonFontSize] highlightedFont:[UIFont boldSystemFontOfSize:largeButtonFontSize]];
    [_clearButton setFont:[UIFont systemFontOfSize:buttonFontSize] highlightedFont:[UIFont systemFontOfSize:largeButtonFontSize]];
    [_cancelButton setFont:[UIFont systemFontOfSize:buttonFontSize] highlightedFont:[UIFont systemFontOfSize:largeButtonFontSize]];

    // Switch between large/small navbar height depending on orientation.
    BOOL isPortrait = self.view.bounds.size.width < self.view.bounds.size.height;
    _navBarHeight.constant = isPortrait ? kHeaderBarHeight : kHeaderBarHeightSmall;

    // Switching light/dark mode.
    UIColor *backgroundColor = lightBackgroundColor;
    UIColor *datePickerBackgroundColor = lightDatePickerBackgroundColor;
    UIColor *buttonLabelColor = lightButtonLabelColor;

    if (@available(iOS 12, *)) {
        BOOL isDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        if (isDarkMode) {
            backgroundColor = darkBackgroundColor;
            datePickerBackgroundColor = darkDatePickerBackgroundColor;
            buttonLabelColor = darkButtonLabelColor;
        }
    }

    _internalView.backgroundColor = backgroundColor;
    _navigationBar.tintColor = buttonLabelColor;
    _datePicker.backgroundColor = datePickerBackgroundColor;
}

#pragma mark - Utils

NSString *UIKitLocalizedString(NSString *key) {
    return [[NSBundle bundleForClass:UIApplication.class] localizedStringForKey:key value:nil table:nil];
}

void addHairLine(CALayer *layer, CGSize shadowOffset) {
//    CGSize scaledOffset = CGSizeMake(shadowOffset.width / UIScreen.mainScreen.scale, shadowOffset.height / UIScreen.mainScreen.scale);
    layer.shadowOffset = shadowOffset;
    layer.shadowRadius = 0;
    layer.shadowColor = [[UIColor colorWithR:128 G:128 B:128 A:1] CGColor];
    layer.shadowOpacity = 0.3f;
}

#pragma mark - Button handlers

- (void)doneButtonTapped:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:true completion:^(void) {
        // Call the callback.
        if (self.doneHandler != nil) [self doneHandler](self);
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
        if (self.doneHandler != nil) [self doneHandler](nil);
    }];
}
@end
