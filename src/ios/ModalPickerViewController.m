//
//  ModalPickerViewController.m
//  Qlinx
//
//  Created by Qlinx Mini on 26/09/14.
//
//

#import "ModalPickerViewController.h"


@implementation ModalPickerViewController

UILabel *_headerLabel;
UIButton *_doneButton;
UIButton *_cancelButton;
UIView *_parent;
UIView *_internalView;

ModalPickerType _pickerType;

const float _headerBarHeight = 38;

- (id)initWithPickerType:(ModalPickerType)pickerType
              headerText:(NSString*)headerText
             dismissText:(NSString*)dismissText
             cancelText:(NSString*)cancelText
                  parent:(UIView*)parent {
    self.headerBackgroundColor = [UIColor whiteColor];
    self.headerTextColor = [UIColor blackColor];
    self.headerText = headerText;
    self.dismissText = dismissText;
    self.cancelText = cancelText;
    self.pickerType = pickerType;
    
    _parent = parent;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self show:false];
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (fromInterfaceOrientation != UIDeviceOrientationUnknown)
    {
        [self show:true];
        [self.view setNeedsDisplay];
    }
}

- (void)show:(BOOL)onRotate {
    CGSize doneButtonSize = CGSizeMake(80, 30);
    CGSize cancelButtonSize = CGSizeMake(80, 30);
    
    CGSize parentFrameSize = _parent.frame.size;
    NSInteger width = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? parentFrameSize.width : parentFrameSize.height;
    // OS reports width 568 in landscape and not 320 so previous line actually takes incorrect dimension.
    width = parentFrameSize.width;
    
    // NSLog(@"Parent frame: %f, %f", parentFrameSize.width, parentFrameSize.height);
    
    CGSize internalViewSize = CGSizeMake(0, 0);
    UIView *currentView = nil;
    switch(self.pickerType)
    {
        case ModalPickerTypeDate:
            currentView = self.datePicker;
            break;
            
            
        case ModalPickerTypeCustom:
            currentView = self.pickerView;
            break;
        default:
            break;
    }
    if (currentView != nil) {
        currentView.frame = CGRectMake(0, 0, 0, 0);
        internalViewSize = CGSizeMake(width, currentView.frame.size.height + _headerBarHeight);
    }
    
    CGRect internalViewFrame = CGRectMake(0, 0, 0, 0);
    CGRect viewFrame = self.view.frame;
    CGRect viewBounds = self.view.bounds;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        if (onRotate)
        {
            internalViewFrame = CGRectMake(0, viewFrame.size.height - internalViewSize.height,
                                               internalViewSize.width, internalViewSize.height);
        }
        else
        {
            internalViewFrame = CGRectMake(0, viewBounds.size.height - internalViewSize.height,
                                               internalViewSize.width, internalViewSize.height);
        }
    }
    else
    {
        if (onRotate)
        {
            internalViewFrame = CGRectMake(0, viewFrame.size.width - internalViewSize.height,
                                               internalViewSize.width, internalViewSize.height);
        }
        else
        {
            internalViewFrame = CGRectMake(0, viewBounds.size.width - internalViewSize.height,
                                               internalViewSize.width, internalViewSize.height);
        }
    }
    _internalView.frame = internalViewFrame;
    
    CGRect pickerFrame;
    switch(self.pickerType)
    {
        case ModalPickerTypeDate:
            pickerFrame = CGRectMake(self.datePicker.frame.origin.x, _headerBarHeight, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
            break;
        case ModalPickerTypeCustom:
            pickerFrame = CGRectMake(self.pickerView.frame.origin.x, _headerBarHeight, _internalView.frame.size.width, self.pickerView.frame.size.height);
            break;
        default:
            break;
    }
    currentView.frame = pickerFrame;
    
    _headerLabel.frame = CGRectMake(10, 4, _parent.frame.size.width - 100, 35);
    _doneButton.frame = CGRectMake(internalViewFrame.size.width - doneButtonSize.width - 10, 5, doneButtonSize.width, doneButtonSize.height);
    _cancelButton.frame = CGRectMake(10, 5, cancelButtonSize.width, cancelButtonSize.height);
    
    //[currentView release];
}

- (void)initializeControls {
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    
    _internalView = [[UIView alloc] init];
    
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320/2, 44)];
    _headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
   // _headerLabel.backgroundColor = self.headerBackgroundColor;
    _headerLabel.textColor = self.headerTextColor;
    _headerLabel.text = self.headerText;
    _headerLabel.hidden = YES;
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    //[_doneButton setTitleColor:self.headerTextColor forState:UIControlStateNormal];
    _doneButton.backgroundColor = [UIColor clearColor];
    [_doneButton setTitle:self.dismissText forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize] * 1.1];
    [_doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton.backgroundColor = [UIColor clearColor];
    [_cancelButton setTitle:self.cancelText forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] * 1.1];
    [_cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    switch(self.pickerType)
    {
        case ModalPickerTypeDate:
            self.datePicker.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85f];
            [_internalView addSubview:[self datePicker]];
            break;
        case ModalPickerTypeCustom:
            self.pickerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85f];
            [_internalView addSubview:[self pickerView]];
            break;
        default:
            break;
    }
    _internalView.backgroundColor = self.headerBackgroundColor;
    
    [_internalView addSubview:_headerLabel];
    [_internalView addSubview:_doneButton];
    [_internalView addSubview:_cancelButton];
    
    [self.view addSubview:_internalView];
}

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

- (ModalPickerType)pickerType {
    return _pickerType;
}

- (void)setPickerType:(ModalPickerType)pickerType {
    switch (pickerType)
    {
        case ModalPickerTypeDate:
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            self.pickerView = nil;
            break;
        case ModalPickerTypeCustom:
            self.datePicker = nil;
            self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            break;
        default:
            break;
    }
    
    _pickerType = pickerType;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
