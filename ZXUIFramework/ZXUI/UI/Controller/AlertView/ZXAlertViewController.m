//
//  ZXAlertViewController.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXAlertViewController.h"
#import "ZXAlertViewStyleKit.h"
#import "ZXTimerDisplay.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define KEYBOARD_HEIGHT 80
#define PREDICTION_BAR_HEIGHT 40
#define ADD_BUTTON_PADDING 10.0f
#define DEFAULT_WINDOW_WIDTH 240

#define UIFontWithSize(x) [UIFont systemFontOfSize:x]
#define UIBOLDFontWithSize(x) [UIFont boldSystemFontOfSize:x]
#define UIColorWithRGB16Radix(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

@interface ZXAlertViewController ()  <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *inputs;
@property (strong, nonatomic) NSMutableArray *customViews;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) UIImageView *circleIconImageView;
@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) UIView *circleViewBackground;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UIWindow *ZXAlertWindow;
@property (copy, nonatomic) ZXDismissBlock dismissBlock;
@property (copy, nonatomic) ZXDismissAnimationCompletionBlock dismissAnimationCompletionBlock;
@property (copy, nonatomic) ZXShowAnimationCompletionBlock showAnimationCompletionBlock;
@property (weak, nonatomic) UIViewController *rootViewController;
@property (assign, nonatomic) SystemSoundID soundID;
@property (assign, nonatomic) BOOL canAddObservers;
@property (assign, nonatomic) BOOL keyboardIsVisible;
@property (nonatomic) CGFloat backgroundOpacity;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *bodyFont;
@property (nonatomic, strong) UIFont *buttonsFont;
@property (nonatomic) CGFloat windowHeight;
@property (nonatomic) CGFloat windowWidth;
@property (nonatomic) CGFloat titleHeight;
@property (nonatomic) CGFloat subTitleHeight;
@property (nonatomic) CGFloat subTitleY;

@end

@implementation ZXAlertViewController

CGFloat kCircleHeight;
CGFloat kCircleTopPosition;
CGFloat kCircleBackgroundTopPosition;
CGFloat kCircleHeightBackground;
CGFloat kActivityIndicatorHeight;
CGFloat kTitleTop;


NSTimer *durationTimer;
ZXTimerDisplay *buttonTimer;

#pragma mark - Initialization

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupViewWindowWidth:DEFAULT_WINDOW_WIDTH];
        [self setupNewWindow];
    }
    return self;
}

- (void)dealloc{
    [self removeObservers];
}

- (void)addObservers{
    if(_canAddObservers){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _canAddObservers = NO;
    }
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Setup view

- (void)setupViewWindowWidth:(CGFloat)windowWidth{
    // Default values
    kCircleBackgroundTopPosition = -31.0f;
    kCircleHeight = 56.0f;
    kCircleHeightBackground = 62.0f;
    kActivityIndicatorHeight = 40.0f;
    kTitleTop = 30.0f;
    self.titleHeight = 40.0f;
    self.subTitleY = 70.0f;
    self.subTitleHeight = 90.0f;
    self.circleIconHeight = 20.0f;
    self.windowWidth = windowWidth;
    self.windowHeight = 178.0f;
    self.canAddObservers = YES;
    self.keyboardIsVisible = NO;
    self.hideAnimationType =  ZXAlertViewHideAnimationFadeOut;
    self.showAnimationType = ZXAlertViewShowAnimationSlideInFromTop;
    self.backgroundType = ZXAlertViewBackgroundShadow;
    self.tintTopCircle = YES;
    self.dismissOnConfirm = YES;
    
    // Font
    _titleFont = UIFontWithSize(20);
    _bodyFont = UIFontWithSize(14);
    _buttonsFont = UIBOLDFontWithSize(14);
    
    // Init
    _labelTitle = [[UILabel alloc] init];
    _viewText = [[UITextView alloc] init];
    _contentView = [[UIView alloc] init];
    _circleView = [[UIView alloc] init];
    _circleViewBackground = [[UIView alloc] init];
    _circleIconImageView = [[UIImageView alloc] init];
    _backgroundView = [[UIImageView alloc] initWithFrame:[self mainScreenFrame]];
    _buttons = [[NSMutableArray alloc] init];
    _inputs = [[NSMutableArray alloc] init];
    _customViews = [[NSMutableArray alloc] init];
    
    // Add Subviews
    [self.view addSubview:_contentView];
    [self.view addSubview:_circleViewBackground];
    
    // Circle View
    CGFloat x = (kCircleHeightBackground - kCircleHeight) / 2;
    _circleView.frame = CGRectMake(x, x, kCircleHeight, kCircleHeight);
    _circleView.layer.cornerRadius = _circleView.frame.size.height / 2;
    
    // Circle Image View
    _circleIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [_circleViewBackground addSubview:_circleView];
    [_circleView addSubview:_circleIconImageView];
    
    // Title
    _labelTitle.numberOfLines = 2;
    _labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.font = _titleFont;
    
    // View text
    _viewText.editable = NO;
    _viewText.allowsEditingTextAttributes = YES;
    _viewText.textAlignment = NSTextAlignmentCenter;
    _viewText.font = _bodyFont;
    _viewText.textContainerInset = UIEdgeInsetsZero;
    _viewText.textContainer.lineFragmentPadding = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;

    // Content View
    [_contentView addSubview:_viewText];
    [_contentView addSubview:_labelTitle];
    
    // Colors
    self.backgroundViewColor = [UIColor whiteColor];
    _labelTitle.textColor = UIColorWithRGB16Radix(0x4D4D4D); //Dark Grey
    _viewText.textColor = UIColorWithRGB16Radix(0x4D4D4D); //Dark Grey
    _contentView.layer.borderColor = UIColorWithRGB16Radix(0xCCCCCC).CGColor; //Light Grey
}

- (void)setupNewWindow {
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[self mainScreenFrame]];
    alertWindow.windowLevel = UIWindowLevelAlert;
    alertWindow.backgroundColor = [UIColor clearColor];
    alertWindow.rootViewController = [UIViewController new];
    alertWindow.accessibilityViewIsModal = YES;
    self.ZXAlertWindow = alertWindow;
}

#pragma mark - View Cycle
- (void)setAlertFrame{
    CGSize sz = [self mainScreenFrame].size;
    
    self.view.frame = CGRectMake((sz.width-_windowWidth)/2, (sz.height-_windowHeight)/2, _windowWidth, _windowHeight);
    
    CGRect newBackgroundFrame = self.backgroundView.frame;
    newBackgroundFrame.size = sz;
    self.backgroundView.frame = newBackgroundFrame;
    
    _contentView.frame = CGRectMake(0.0f, 0.0f, _windowWidth, _windowHeight);
    _contentView.layer.cornerRadius = self.cornerRadius ? self.cornerRadius : 5.0f;
    _circleViewBackground.frame = CGRectMake(_windowWidth / 2 - kCircleHeightBackground / 2, kCircleBackgroundTopPosition, kCircleHeightBackground, kCircleHeightBackground);
    _circleViewBackground.layer.cornerRadius = _circleViewBackground.frame.size.height / 2;
    _circleView.layer.cornerRadius = _circleView.frame.size.height / 2;
    _circleIconImageView.frame = CGRectMake(kCircleHeight / 2 - _circleIconHeight / 2, kCircleHeight / 2 - _circleIconHeight / 2, _circleIconHeight, _circleIconHeight);
    _labelTitle.frame = CGRectMake(12.0f, kTitleTop, _windowWidth - 24.0f, _titleHeight);
    
    CGFloat y = (_labelTitle.text == nil) ? kTitleTop : (_titleHeight - 10.0f) + _labelTitle.frame.size.height;
    _viewText.frame = CGRectMake(12.0f, y, _windowWidth - 24.0f, _subTitleHeight);
    
    y += _subTitleHeight + 14.0f;
    for (ZXTextFieldBorder *textField in _inputs) {
        textField.frame = CGRectMake(12.0f, y, _windowWidth - 24.0f, textField.frame.size.height);
        textField.layer.cornerRadius = 3.0f;
        y += textField.frame.size.height + 10.0f;
    }
    
    for (UIView *view in _customViews) {
        view.frame = CGRectMake(12.0f, y, view.frame.size.width, view.frame.size.height);
        y += view.frame.size.height + 10.0f;
    }
    
    CGFloat x = 12.0f;
    for (ZXAlertButton *btn in _buttons) {
        btn.frame = CGRectMake(x, y, btn.frame.size.width, btn.frame.size.height);
        
        if (_horizontalButtons) {
            x += btn.frame.size.width + 10.0f;
        } else {
            y += btn.frame.size.height + 10.0f;
        }
    }
    
}

#pragma mark - Custom Fonts

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    self.labelTitle.font = titleFont;
}

- (void)setBodyTextFont:(UIFont *)bodyTextFont{
    _bodyFont = bodyTextFont;
    self.viewText.font = bodyTextFont;
}

- (void)setButtonsTextFont:(UIFont *)buttonsFont{
    _buttonsFont = buttonsFont;
}

#pragma mark - Background Color

- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor{
    _backgroundViewColor = backgroundViewColor;
    _circleViewBackground.backgroundColor = _backgroundViewColor;
    _contentView.backgroundColor = _backgroundViewColor;
    _viewText.backgroundColor = _backgroundViewColor;
}

#pragma mark - Sound

- (void)setSoundURL:(NSURL *)soundURL{
    _soundURL = soundURL;
    
    AudioServicesDisposeSystemSoundID(_soundID);
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)_soundURL, &_soundID);
    
    AudioServicesPlaySystemSound(_soundID);
}

#pragma mark - Subtitle Height

- (void)setSubTitleHeight:(CGFloat)value{
    _subTitleHeight = value;
}

#pragma mark - ActivityIndicator

- (void)addActivityIndicatorView{
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.frame = CGRectMake(kCircleHeight / 2 - kActivityIndicatorHeight / 2, kCircleHeight / 2 - kActivityIndicatorHeight / 2, kActivityIndicatorHeight, kActivityIndicatorHeight);
    [_circleView addSubview:_activityIndicatorView];
}

#pragma mark - UICustomView

- (UIView *)addCustomView:(UIView *)customView{
    self.windowHeight += customView.bounds.size.height + 10.0f;
    
    [_contentView addSubview:customView];
    [_customViews addObject:customView];
    
    return customView;
}

#pragma mark - SwitchView

- (ZXSwitchView *)addSwitchViewWithLabel:(NSString *)label{
    ZXSwitchView *switchView = [[ZXSwitchView alloc] initWithFrame:CGRectMake(0, 0, self.windowWidth, 31.0f)];
    
    self.windowHeight += switchView.bounds.size.height + 10.0f;
    
    if (label != nil){
        switchView.labelText = label;
    }
    
    [_contentView addSubview:switchView];
    [_inputs addObject:switchView];
    
    return switchView;
}

- (ZXTextViewBorder *)addTextView:(NSString *)title{
    ZXTextViewBorder *txt = [[ZXTextViewBorder alloc] init];
    txt.font = _bodyFont;
    
    self.windowHeight += txt.bounds.size.height + 10.0f;
    
    if (title != nil)
    {
        txt.placeholder = title;
    }
    
    [_contentView addSubview:txt];
    [_inputs addObject:txt];
    return txt;
}

#pragma mark - TextField

- (ZXTextFieldBorder *)addTextField:(NSString *)title{
    [self addObservers];
    
    ZXTextFieldBorder *txt = [[ZXTextFieldBorder alloc] init];
    txt.font = _bodyFont;
    txt.delegate = self;
    
    self.windowHeight += txt.bounds.size.height + 10.0f;
    
    if (title != nil){
        txt.placeholder = title;
    }
    
    [_contentView addSubview:txt];
    [_inputs addObject:txt];
    
    if (_inputs.count > 1){
        NSUInteger indexOfCurrentField = [_inputs indexOfObject:txt];
        ZXTextFieldBorder *priorField = _inputs[indexOfCurrentField - 1];
        priorField.returnKeyType = UIReturnKeyNext;
    }
    return txt;
}

- (void)addCustomTextField:(UITextField *)textField{
    self.windowHeight += textField.bounds.size.height + 10.0f;
    
    [_contentView addSubview:textField];
    [_inputs addObject:textField];
    
    if (_inputs.count > 1)
    {
        NSUInteger indexOfCurrentField = [_inputs indexOfObject:textField];
        UITextField *priorField = _inputs[indexOfCurrentField - 1];
        priorField.returnKeyType = UIReturnKeyNext;
    }
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _inputs.lastObject){
        [textField resignFirstResponder];
    }
    else {
        NSUInteger indexOfCurrentField = [_inputs indexOfObject:textField];
        UITextField *nextField = _inputs[indexOfCurrentField + 1];
        [nextField becomeFirstResponder];
    }
    return NO;
}

- (void)keyboardWillShow:(NSNotification *)notification{
    if(_keyboardIsVisible) return;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect f = self.view.frame;
        f.origin.y -= KEYBOARD_HEIGHT + PREDICTION_BAR_HEIGHT;
        self.view.frame = f;
    }];
    _keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    if(!_keyboardIsVisible) return;
    [UIView animateWithDuration:0.2f animations:^{
        CGRect f = self.view.frame;
        f.origin.y += KEYBOARD_HEIGHT + PREDICTION_BAR_HEIGHT;
        self.view.frame = f;
    }];
    _keyboardIsVisible = NO;
}

#pragma mark - Buttons

- (ZXAlertButton *)addButton:(NSString *)title{
    ZXAlertButton *btn = [[ZXAlertButton alloc] initWithWindowWidth:self.windowWidth];
    btn.layer.masksToBounds = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = _buttonsFont;
    
    [_contentView addSubview:btn];
    [_buttons addObject:btn];
    
    if (_horizontalButtons) {
        for (ZXAlertButton *bttn in _buttons) {
            [bttn adjustWidthWithWindowWidth:self.windowWidth numberOfButtons:[_buttons count]];
        }
        
        if (!([_buttons count] > 1)) {
            self.windowHeight += (btn.frame.size.height + ADD_BUTTON_PADDING);
        }
    } else {
        self.windowHeight += (btn.frame.size.height + ADD_BUTTON_PADDING);
    }
    
    return btn;
}

- (ZXAlertButton *)addDoneButtonWithTitle:(NSString *)title{
    ZXAlertButton *btn = [self addButton:title];
    
    if (_completeButtonFormatBlock != nil){
        btn.completeButtonFormatBlock = _completeButtonFormatBlock;
    }
    
    [btn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (ZXAlertButton *)addButton:(NSString *)title actionBlock:(ZXActionBlock)action{
    ZXAlertButton *btn = [self addButton:title];
    
    if (_buttonFormatBlock != nil){
        btn.buttonFormatBlock = _buttonFormatBlock;
    }
    btn.actionType = ZXBlock;
    btn.actionBlock = action;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (ZXAlertButton *)addButton:(NSString *)title validationBlock:(ZXValidationBlock)validationBlock actionBlock:(ZXActionBlock)action{
    ZXAlertButton *btn = [self addButton:title actionBlock:action];
    btn.validationBlock = validationBlock;
    
    return btn;
}

- (ZXAlertButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector{
    ZXAlertButton *btn = [self addButton:title];
    btn.actionType = ZXSelector;
    btn.target = target;
    btn.selector = selector;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)buttonTapped:(ZXAlertButton *)btn{
    [buttonTimer cancelTimer];
    
    if (btn.validationBlock && !btn.validationBlock()) {
        return;
    }
    
    if (btn.actionType == ZXBlock){
        if (btn.actionBlock)
            btn.actionBlock();
    }
    else if (btn.actionType == ZXSelector){
        UIControl *ctrl = [[UIControl alloc] init];
        [ctrl sendAction:btn.selector to:btn.target forEvent:nil];
    }
    [self hideView];
}

#pragma mark - Button Timer

- (void)addTimerToButtonIndex:(NSInteger)buttonIndex reverse:(BOOL)reverse{
    buttonIndex = MAX(buttonIndex, 0);
    buttonIndex = MIN(buttonIndex, [_buttons count]);
    
    buttonTimer = [[ZXTimerDisplay alloc] initWithOrigin:CGPointMake(5, 5) radius:13 lineWidth:4];
    buttonTimer.buttonIndex = buttonIndex;
    buttonTimer.reverse = reverse;
}

#pragma mark - Show Alert

- (void)showTitle:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle duration:(NSTimeInterval)duration completeText:(NSString *)completeText style:(ZXAlertViewStyle)style{
    self.backgroundView.frame = _ZXAlertWindow.bounds;
    
    [_ZXAlertWindow.rootViewController addChildViewController:self];
    [_ZXAlertWindow.rootViewController.view addSubview:_backgroundView];
    [_ZXAlertWindow.rootViewController.view addSubview:self.view];

    self.view.alpha = 0.0f;
    [self setBackground];
    
    UIColor *viewColor;
    UIImage *iconImage;
    
    switch (style){
        case ZXAlertViewStyleSuccess:
            viewColor = UIColorWithRGB16Radix(0x22B573);
            iconImage = ZXAlertViewStyleKit.imageOfCheckmark;
            break;
        case ZXAlertViewStyleError:
            viewColor = UIColorWithRGB16Radix(0xC1272D);
            iconImage = ZXAlertViewStyleKit.imageOfCross;
            break;
        case ZXAlertViewStyleNotice:
            viewColor = UIColorWithRGB16Radix(0x727375);
            iconImage = ZXAlertViewStyleKit.imageOfNotice;
            break;
        case ZXAlertViewStyleWarning:
            viewColor = UIColorWithRGB16Radix(0xFFD110);
            iconImage = ZXAlertViewStyleKit.imageOfWarning;
            break;
        case ZXAlertViewStyleInfo:
            viewColor = UIColorWithRGB16Radix(0x2866BF);
            iconImage = ZXAlertViewStyleKit.imageOfInfo;
            break;
        case ZXAlertViewStyleEdit:
            viewColor = UIColorWithRGB16Radix(0xA429FF);
            iconImage = ZXAlertViewStyleKit.imageOfEdit;
            break;
        case ZXAlertViewStyleWaiting:
            viewColor = UIColorWithRGB16Radix(0x6c125d);
            break;
        case ZXAlertViewStyleQuestion:
            viewColor = UIColorWithRGB16Radix(0x727375);
            iconImage = ZXAlertViewStyleKit.imageOfQuestion;
            break;
        case ZXAlertViewStyleCustom:
            viewColor = color;
            iconImage = image;
            self.circleIconHeight *= 2.0f;
            break;
    }
    
    if(_customViewColor){
        viewColor = _customViewColor;
    }
    CGSize reckonSize = CGSizeMake(_windowWidth - 24.0f, CGFLOAT_MAX);

    if (title != nil) {
        self.labelTitle.text = title;

        CGSize size = [_labelTitle sizeThatFits:reckonSize];

        CGFloat ht = ceilf(size.height);
        if (ht > _titleHeight) {
            self.windowHeight += (ht - _titleHeight);
            self.titleHeight = ht;
            self.subTitleY += 20;
        }
    } else {
        self.windowHeight -= _titleHeight;
        self.titleHeight = 0.f;
        [_labelTitle removeFromSuperview];
        _labelTitle = nil;
        
        _subTitleY = kCircleHeight - 20;
    }
    
    if (subTitle != nil) {
        if (_attributedFormatBlock == nil) {
            _viewText.text = subTitle;
        } else {
            self.viewText.font = _bodyFont;
            _viewText.attributedText = self.attributedFormatBlock(subTitle);
        }
        
        CGSize size = [_viewText sizeThatFits:reckonSize];
        
        CGFloat ht = ceilf(size.height);
        if (ht < _subTitleHeight) {
            self.windowHeight -= (_subTitleHeight - ht);
            self.subTitleHeight = ht;
        } else {
            self.windowHeight += (ht - _subTitleHeight);
            self.subTitleHeight = ht;
        }
    } else {
        self.windowHeight -= _subTitleHeight;
        self.subTitleHeight = 0.0f;
        [_viewText removeFromSuperview];
        _viewText = nil;
    }
    
    if(completeText != nil){
        [self addDoneButtonWithTitle:completeText];
    }
    
    self.circleView.backgroundColor = self.tintTopCircle ? viewColor : _backgroundViewColor;
    
    if (style == ZXAlertViewStyleWaiting){
        [self.activityIndicatorView startAnimating];
    }
    else{
        if (self.iconTintColor) {
            self.circleIconImageView.tintColor = self.iconTintColor;
            iconImage  = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        self.circleIconImageView.image = iconImage;
    }
    
    for (ZXTextFieldBorder *textField in _inputs){
        textField.layer.borderColor = viewColor.CGColor;
    }
    
    for (ZXAlertButton *btn in _buttons){
        if (style == ZXAlertViewStyleWarning){
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        if (!btn.defaultBackgroundColor) {
            btn.defaultBackgroundColor = viewColor;
        }
        
        if (btn.completeButtonFormatBlock != nil){
            [btn parseConfig:btn.completeButtonFormatBlock()];
        }
        else if (btn.buttonFormatBlock != nil){
            [btn parseConfig:btn.buttonFormatBlock()];
        }
    }
    
    if (duration > 0) {
        [durationTimer invalidate];
        if (buttonTimer && _buttons.count > 0){
            ZXAlertButton *btn = _buttons[buttonTimer.buttonIndex];
            btn.timer = buttonTimer;
            [buttonTimer startTimerWithTimeLimit:duration completed:^{
                [self buttonTapped:btn];
            }];
        }
        else {
            durationTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                             target:self
                                                           selector:@selector(hideView)
                                                           userInfo:nil
                                                            repeats:NO];
        }
    }
    
    [_ZXAlertWindow makeKeyAndVisible];
    [self showView];
}

#pragma mark - Show using new window

- (void)showSuccess:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleSuccess];
}

- (void)showError:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleError];
}

- (void)showNotice:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleNotice];
}

- (void)showWarning:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleWarning];
}

- (void)showInfo:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleInfo];
}

- (void)showEdit:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleEdit];
}

- (void)showTitle:(NSString *)title subTitle:(NSString *)subTitle style:(ZXAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:style];
}

- (void)showCustom:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:image color:color title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleCustom];
}

- (void)showWaiting:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self addActivityIndicatorView];
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleWaiting];
}

- (void)showQuestion:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration{
    [self showTitle:nil color:nil title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:ZXAlertViewStyleQuestion];
}

#pragma mark - Visibility

- (void)removeTopCircle{
    [_circleViewBackground removeFromSuperview];
    [_circleView removeFromSuperview];
}

- (void)alertIsDismissed:(ZXDismissBlock)dismissBlock{
    self.dismissBlock = dismissBlock;
}

- (void)alertDismissAnimationIsCompleted:(ZXDismissAnimationCompletionBlock)dismissAnimationCompletionBlock{
    self.dismissAnimationCompletionBlock = dismissAnimationCompletionBlock;
}

- (void)alertShowAnimationIsCompleted:(ZXShowAnimationCompletionBlock)showAnimationCompletionBlock{
    self.showAnimationCompletionBlock = showAnimationCompletionBlock;
}

- (CGRect)mainScreenFrame{
    return UIScreen.mainScreen.bounds;
}

#pragma mark - Background Effects

- (void)makeShadowBackground{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.7f;
    _backgroundOpacity = 0.7f;
}

- (void)makeBlurBackground{
    UIVisualEffectView *effect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effect.frame = _backgroundView.frame;
    [_backgroundView addSubview:effect];
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)makeTransparentBackground{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)setBackground{
    switch (_backgroundType){
        case ZXAlertViewBackgroundShadow:
            [self makeShadowBackground];
            break;
        case ZXAlertViewBackgroundBlur:
            [self makeBlurBackground];
            break;
        case ZXAlertViewBackgroundTransparent:
            [self makeTransparentBackground];
            break;
    }
}

#pragma mark - Show Alert

- (void)showView{
    [self setAlertFrame];
    switch (_showAnimationType){
        case ZXAlertViewShowAnimationFadeIn:
            [self fadeIn];
            break;
        case ZXAlertViewShowAnimationSlideInFromBottom:
            [self slideInFromBottom];
            break;
        case ZXAlertViewShowAnimationSlideInFromTop:
            [self slideInFromTop];
            break;
        case ZXAlertViewShowAnimationSlideInFromLeft:
            [self slideInFromLeft];
            break;
        case ZXAlertViewShowAnimationSlideInFromRight:
            [self slideInFromRight];
            break;
        case ZXAlertViewShowAnimationSlideInFromCenter:
            [self slideInFromCenter];
            break;
        case ZXAlertViewShowAnimationSlideInToCenter:
            [self slideInToCenter];
            break;
        case ZXAlertViewShowAnimationSimplyAppear:
            [self simplyAppear];
            break;
    }
}

#pragma mark - Hide Alert

- (void)hideView{
    if (!_dismissOnConfirm) {
        return;
    }
    switch (_hideAnimationType){
        case ZXAlertViewHideAnimationFadeOut:
            [self fadeOut];
            break;
        case ZXAlertViewHideAnimationSlideOutToBottom:
            [self slideOutToBottom];
            break;
        case ZXAlertViewHideAnimationSlideOutToTop:
            [self slideOutToTop];
            break;
        case ZXAlertViewHideAnimationSlideOutToLeft:
            [self slideOutToLeft];
            break;
        case ZXAlertViewHideAnimationSlideOutToRight:
            [self slideOutToRight];
            break;
        case ZXAlertViewHideAnimationSlideOutToCenter:
            [self slideOutToCenter];
            break;
        case ZXLAlertViewHideAnimationSlideOutFromCenter:
            [self slideOutFromCenter];
            break;
        case ZXLAlertViewHideAnimationSimplyDisappear:
            [self simplyDisappear];
            break;
    }
    if (_activityIndicatorView){
        [_activityIndicatorView stopAnimating];
    }
    
    if (durationTimer){
        [durationTimer invalidate];
    }
    
    if (self.dismissBlock){
        self.dismissBlock();
    }

    for (ZXAlertButton *btn in _buttons){
        btn.actionBlock = nil;
        btn.target = nil;
        btn.selector = nil;
    }
}

#pragma mark - Hide Animations

- (void)fadeOut{
    [self fadeOutWithDuration:0.3f];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration{
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.alpha = 0.0f;
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self.backgroundView removeFromSuperview];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [self.ZXAlertWindow setHidden:YES];
        self.ZXAlertWindow = nil;
        
        if (self.dismissAnimationCompletionBlock){
            self.dismissAnimationCompletionBlock();
        }
    }];
}

- (void)slideOutToBottom{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y += self.backgroundView.frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToTop{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y -= self.backgroundView.frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToLeft{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x -= self.backgroundView.frame.size.width;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToRight{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x += self.backgroundView.frame.size.width;
        self.view.frame = frame;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutToCenter{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform =
        CGAffineTransformConcat(CGAffineTransformIdentity,
                                CGAffineTransformMakeScale(0.1f, 0.1f));
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)slideOutFromCenter{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform =
        CGAffineTransformConcat(CGAffineTransformIdentity,
                                CGAffineTransformMakeScale(3.0f, 3.0f));
        self.view.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self fadeOut];
    }];
}

- (void)simplyDisappear{
    self.backgroundView.alpha = self.backgroundOpacity;
    self.view.alpha = 1.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fadeOutWithDuration:0];
    });
}


#pragma mark - Show Animations

- (void (^)(BOOL))animationCompletionBlock {
    return ^(BOOL finished) {
        if (self.showAnimationCompletionBlock){
            self.showAnimationCompletionBlock();
        }
    };
}

- (void)fadeIn{
    self.backgroundView.alpha = 0.0f;
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.backgroundView.alpha = self.backgroundOpacity;
                         self.view.alpha = 1.0f;
                     }
                     completion:[self animationCompletionBlock]];
}

- (void)slideInFromTop{
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = -self.backgroundView.frame.size.height;
        self.view.frame = frame;
        
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:0 animations:^{
            self.backgroundView.alpha = self.backgroundOpacity;
            CGRect frame = self.backgroundView.frame;
            frame.origin.y = 0.0f;
            self.view.frame = frame;
            self.view.alpha = 1.0f;
        }
       completion:[self animationCompletionBlock]];
}

- (void)slideInFromBottom{
    CGRect frame = self.backgroundView.frame;
    frame.origin.y = self.backgroundView.frame.size.height;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = self.backgroundOpacity;
        
        CGRect frame = self.backgroundView.frame;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = self.backgroundView.center;
        }  completion:[self animationCompletionBlock]];
    }];
}

- (void)slideInFromLeft{
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = -self.backgroundView.frame.size.width;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = self.backgroundOpacity;
        
        CGRect frame = self.backgroundView.frame;
        frame.origin.x = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = self.backgroundView.center;
        }   completion:[self animationCompletionBlock]];

    }];
}

- (void)slideInFromRight{
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = self.backgroundView.frame.size.width;
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = self.backgroundOpacity;
        
        CGRect frame = self.backgroundView.frame;
        frame.origin.x = 0.0f;
        self.view.frame = frame;
        
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = self.backgroundView.center;
        }        completion:[self animationCompletionBlock]];

    }];
}

- (void)slideInFromCenter{
    self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                  CGAffineTransformMakeScale(3.0f, 3.0f));
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = self.backgroundOpacity;
        
        self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                      CGAffineTransformMakeScale(1.0f, 1.0f));
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = self.backgroundView.center;
        }  completion:[self animationCompletionBlock]];
    }];
}

- (void)slideInToCenter{
    self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                  CGAffineTransformMakeScale(0.1f, 0.1f));
    self.view.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = self.backgroundOpacity;
        
        self.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                      CGAffineTransformMakeScale(1.0f, 1.0f));
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = self.backgroundView.center;
        }  completion:[self animationCompletionBlock]];
    }];
}

- (void)simplyAppear{
    self.backgroundView.alpha = 0.0f;
    self.view.alpha = 0.0f;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backgroundView.alpha = self.backgroundOpacity;
        self.view.alpha = 1.0f;
        if ( self.showAnimationCompletionBlock ){
            self.showAnimationCompletionBlock();
        }
    });
}

@end
