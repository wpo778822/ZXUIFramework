//
//  ZXField.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//


#import "ZXInputField.h"
#import "NSString+validate.h"
#import <Masonry.h>

@interface NSString (category)
- (BOOL)isChinese;
- (BOOL)isNumber;
- (BOOL)isCharacter;
@end

@implementation NSString (category)
- (BOOL)isChinese{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isNumber{
    NSString *match = @"^\\d+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isCharacter{
    NSString *match = @"^[a-zA-Z]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

@end


@interface UIColor (ColorsConfig)

+ (UIColor *)borderColor;
+ (UIColor *)upperBorderColor;
+ (UIColor *)upperPlaceholderFontColor;
+ (UIColor *)tintColor;
+ (UIColor *)placeholderFontColor;
+ (UIColor *)textFontColor;
+ (UIColor *)underliningColor;

@end

@implementation UIColor (ColorsConfig)

+ (UIColor *)borderColor {
    return [UIColor colorWithRed:156.0f / 255.0f green:168.0f / 255.0f blue:173.0f / 255.0f alpha:1];
}

+ (UIColor *)upperBorderColor {
    return [UIColor colorWithRed:180.0f / 255.0f green:180.0f / 255.0f blue:180.0f / 255.0f alpha:1];
}

+ (UIColor *)upperPlaceholderFontColor {
    return [UIColor colorWithRed:180.0f / 255.0f green:180.0f / 255.0f blue:180.0f / 255.0f alpha:1];
}

+ (UIColor *)tintColor {
    return [UIColor colorWithRed:0.0f / 255.0f green:122.0f / 255.0f blue:255.0f / 255.0f alpha:1];
}

+ (UIColor *)placeholderFontColor {
    return [UIColor colorWithRed:80.0f / 255.0f green:80.0f / 255.0f blue:80.0f / 255.0f alpha:1];
}

+ (UIColor *)textFontColor {
    return [UIColor colorWithRed:80.0f / 255.0f green:80.0f / 255.0f blue:80.0f / 255.0f alpha:1];
}

+ (UIColor *)underliningColor {
    return [UIColor colorWithRed:180.0f / 255.0f green:180.0f / 255.0f blue:180.0f / 255.0f alpha:1];
}

@end

static const CGFloat kMarginBetweenTextFields = 4.0f;

@interface TextFieldWithTextInsets : UITextField
- (NSRange)downRoundRangeOfComposedCharacterSequencesForRange:(NSRange)range string:(NSString *)string;
@end

@implementation TextFieldWithTextInsets
- (void)setText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    [super setText:text];
    if (![textBeforeChange isEqualToString:text]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    NSAttributedString *textBeforeChange = self.attributedText;
    [super setAttributedText:attributedText];
    if (![textBeforeChange isEqualToAttributedString:attributedText]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)fireTextDidChangeEventForTextField:(UITextField *)textField {
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    if (self.leftView) {
        return CGRectInset(bounds, self.leftView.frame.size.width + kMarginBetweenTextFields, 0);
    }
    return CGRectInset(bounds, kMarginBetweenTextFields, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    if (self.leftView) {
        return CGRectInset(bounds, self.leftView.frame.size.width + kMarginBetweenTextFields, 0);
    }
    return CGRectInset(bounds, kMarginBetweenTextFields, 0);
}

- (NSRange)downRoundRangeOfComposedCharacterSequencesForRange:(NSRange)range string:(NSString *)string{
    if (range.length == 0) {
        return range;
    }
    
    NSRange resultRange = [string rangeOfComposedCharacterSequencesForRange:range];
    if (NSMaxRange(resultRange) > NSMaxRange(range)) {
        return [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(range.location, range.length - 1) string:string];
    }
    return resultRange;
}

@end

@interface ZXInputField () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIView *underlineView;
@property (nonatomic, strong) NSMutableArray<UITextField *> *textFields;
@property (weak, nonatomic)   UITextField *focusTextField;
@property (nonatomic, copy) NSString *tempText;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isMultifield;
@property (nonatomic, assign) BOOL isFinsh;
@property (nonatomic, assign) BOOL isAnimation;
@end

@implementation ZXInputField
//动画配置
static const CGFloat kUpAnimationDuration = 0.9f;
static const CGFloat kDownAnimationDuration = 0.35f;
static const CGFloat kChangeStateAnimationDuration = 0.2f;
static const CGFloat kScaleFactor = 0.75f;
static const CGFloat kDamping = 0.5f;
static const CGFloat kInitialVelocity = 0.0f;
static const NSUInteger kAnimationOptions = 7 << 16;

#pragma mark init 

- (instancetype)init {
    if (self = [super init]) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonSetup];
    }
    return self;
}

#pragma mark 视图加料

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.frame.size.width > 0 && !self.isFinsh) {
        self.isFinsh = YES;
        for (UITextField *textField in self.textFields) {
            CGSize size = [textField systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            CGAffineTransform concat = CGAffineTransformConcat(CGAffineTransformMakeScale(1 + 2 * kMarginBetweenTextFields / (self.frame.size.width - (self.textFields.count + 1) * kMarginBetweenTextFields) / self.textFields.count, 0.001), CGAffineTransformMakeTranslation(0, size.height / 2 - self.borderWidth));
            textField.transform = concat;
        }
        if(self.tempText) [self setText:self.tempText];
    }
}

#pragma mark Setup

- (void)commonSetup {
    self.isEditing = NO;
    self.isMultifield = NO;
    self.isFinsh = NO;
    self.isAnimation = NO;
    _isCorrect = ZXUndefined;
    self.textFields = [[NSMutableArray alloc] init];
    self.borderColor = [UIColor borderColor];
    self.upperBorderColor = [UIColor upperBorderColor];
    self.upperPlaceholderFontColor = [UIColor upperPlaceholderFontColor];
    self.tintColor = [UIColor tintColor];
    self.placeholderFontColor = [UIColor placeholderFontColor];
    self.textFontColor = [UIColor textFontColor];
    self.underliningColor = [UIColor underliningColor];
    self.borderWidth = 1.0f;
    UITapGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self addGestureRecognizer:viewTapGestureRecognizer];
}

#pragma mark UITextFieldDelegate

- (void)textFieldTextChanged:(TextFieldWithTextInsets *)textField {
    if (!textField.markedTextRange) {
        NSInteger index = [self.textFields indexOfObject:textField];
        if (textField.text.length > [self.dataSource numberOfCharactersInSection:index inTextField:self]) {
            NSRange characterSequencesRange = [textField downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(0, [self.dataSource numberOfCharactersInSection:index inTextField:self]) string:textField.text];
            textField.text = [textField.text substringWithRange:characterSequencesRange];
        }else{
            if (_constraintEntryType & ZXConstraintEntryTypeChinese) {
                NSString *str = textField.text;
                str = [str retainChinese];
                if (![str isEqualToString:textField.text]) {
                    textField.text = str;
                }
            }
        }
    }

    NSInteger index = [self.textFields indexOfObject:textField];
    if (textField.text.length == [self.dataSource numberOfCharactersInSection:index inTextField:self]) {
        if (index < self.textFields.count - 1) {
            [self.textFields[index + 1] becomeFirstResponder];
        }
    }
    if (textField.text.length == 0) {
        if (index > 0) {
            [self.textFields[index - 1] becomeFirstResponder];
        }
    }
    if ([self.delegate respondsToSelector:@selector(inputFieldTextChanged:)]) {
        [self.delegate inputFieldTextChanged:self];
    }
    [self validateInput];
}

- (BOOL)textField:(TextFieldWithTextInsets *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isDeleting = range.length > 0 && string.length <= 0;
    if (isDeleting || textField.markedTextRange) {
        return YES;
    }
    BOOL isEntry = NO;
    isEntry = isEntry ?: [string isNumber] && (_constraintEntryType & ZXConstraintEntryTypeNumber);
    isEntry = isEntry ?: [string isCharacter] && (_constraintEntryType & ZXConstraintEntryTypeCharacter);
    isEntry = isEntry ?: _constraintEntryType & ZXConstraintEntryTypeChinese;
    if(!isEntry && string.length > 0 && _constraintEntryType != ZXConstraintEntryTypeNone) return NO;
    NSInteger index = [self.textFields indexOfObject:textField];
    if ([textField.text isEqualToString:@""] && [string isEqualToString:@""]) {
        if (index > 0) {
            [self.textFields[index - 1] becomeFirstResponder];
        }
    }
    
    if (textField.text.length - range.length + string.length > [self.dataSource numberOfCharactersInSection:index inTextField:self]) {
        NSInteger substringLength = [self.dataSource numberOfCharactersInSection:index inTextField:self] - textField.text.length + range.length;
        if (substringLength > 0 && string.length > substringLength) {
            NSRange characterSequencesRange = [textField downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(0, substringLength) string:string];
            NSString *allowedText = [string substringWithRange:characterSequencesRange];
            if (allowedText.length <= substringLength) {
                textField.text = [textField.text stringByReplacingCharactersInRange:range withString:allowedText];
            }
            if (index < self.textFields.count - 1) {
                [self.textFields[index + 1] becomeFirstResponder];
            }
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField.text.length == 0)[self viewTapped];
    self.focusTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isEditing = NO;
    BOOL isEdited = NO;
    if(self.focusTextField && ![self.focusTextField isEqual:textField]) return YES;
    for (UITextField *textField in self.textFields) {
        if (textField.text.length > 0) {
            isEdited = YES;
            break;
        }
    }
    if (!isEdited) {
        [self collapse];
    } else {
        [self validateInput];
    }
    if ([self.delegate respondsToSelector:@selector(inputFieldHasEndedEditing:)]) {
        [self.delegate inputFieldHasEndedEditing:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark 正则判断

- (void)validateInput {
    if ([self.delegate respondsToSelector:@selector(inputField:containsValidText:)]) {
        BOOL isValid = [self.delegate inputField:self containsValidText:self.text];
        if (isValid) {
            _isCorrect = ZXCorrectContent;
        } else {
            _isCorrect = ZXIncorrectContent;
        }
        [self animateValidation:isValid];
    } else {
        _isCorrect = ZXUndefined;
    }
}

- (void)animateValidation:(BOOL)valid {
    UIColor *resultBorderColor;
    UIColor *resultPlaceholderLabelColor;
    UIColor *resultUpperUnderliningColor;
    NSString *resultLabelText;
    if (valid) {
        resultBorderColor = self.correctStateBorderColor ?: self.borderColor;
        resultPlaceholderLabelColor = self.correctStatePlaceholderLabelTextColor ?: self.placeholderFontColor;
        resultLabelText = self.correctLabelText ?: self.placeholderText;
    } else {
        resultBorderColor = self.incorrectStateBorderColor ?: self.borderColor;
        resultPlaceholderLabelColor = self.incorrectStatePlaceholderLabelTextColor ?: self.placeholderFontColor;
        resultLabelText = self.incorrectLabelText ?: self.placeholderText;
    }
    resultUpperUnderliningColor = valid ? self.upperUnderliningColor : resultPlaceholderLabelColor;
    void (^borderColorAnimation)(void) = ^void() {
        for (UITextField *currentTextField in self.textFields) {
            currentTextField.layer.borderColor = resultBorderColor.CGColor;
        }
    };
    
    void (^placeholderLabelAnimation)(void) = ^void() {
        self.placeholderLabel.text = resultLabelText;
        self.placeholderLabel.textColor = resultPlaceholderLabelColor;
        self.underlineView.backgroundColor = resultUpperUnderliningColor;
        [self easeInOutView:self.placeholderLabel];
    };
    
    [UIView animateWithDuration:kChangeStateAnimationDuration delay:0 options:kAnimationOptions animations:^{
        borderColorAnimation();
        placeholderLabelAnimation();
    } completion:nil];
}

#pragma mark 基本 transform 动画

- (void)easeInOutView:(UIView *)view {
    CATransition *transition = [CATransition animation];
    transition.duration = kChangeStateAnimationDuration;
    [transition setType:kCATransitionFade];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:
                                 kCAMediaTimingFunctionEaseInEaseOut];
    [transition setFillMode:@"extended"];
    [view.layer addAnimation:transition forKey:nil];
    [CATransaction commit];
}

#pragma mark 展开(聚焦)/收起(失焦) 动画

- (void)expansion{
    self.isEditing = YES;
    [self.textFields[0] becomeFirstResponder];
    void (^placeholderLabelAnimation)(void) = ^void() {
        self.placeholderLabel.textColor = self.upperPlaceholderFontColor;
        CGAffineTransform translation;
        switch (self.placeholderLabel.textAlignment) {
            case NSTextAlignmentCenter:
                translation = CGAffineTransformMakeTranslation(0, 0);
                break;
            case NSTextAlignmentLeft:
                translation = CGAffineTransformMakeTranslation(-1 * (1 - kScaleFactor) / 2 * self.placeholderLabel.frame.size.width + kMarginBetweenTextFields, 0);
                break;
            case NSTextAlignmentRight:
                translation = CGAffineTransformMakeTranslation((1 - kScaleFactor) / 2 * self.placeholderLabel.frame.size.width - 2 * kMarginBetweenTextFields, 0);
                break;
            default:
                translation = CGAffineTransformMakeTranslation(0, 0);
                break;
        }
        CGAffineTransform resultTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(kScaleFactor, kScaleFactor), translation);
        self.placeholderLabel.transform = resultTransform;
    };
    
    void (^textFieldsAnimation)(void) = ^void() {
        for (UITextField *currentTexField in self.textFields) {
            currentTexField.layer.borderColor = self.upperBorderColor.CGColor;
            currentTexField.transform = CGAffineTransformIdentity;
        }
    };
    
    void (^borderAndUnderliningAnimation)(void) = ^void() {
        if (self.borderColor) {
            self.underlineView.alpha = 0.0f;
        }else{
            self.underlineView.backgroundColor = self.upperUnderliningColor;
        }
    };
    
    [self.placeholderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(-self.frame.size.height);
    }];
    
    [self.underlineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.0);
        make.width.equalTo(self).offset( 2 *-kMarginBetweenTextFields);
    }];
    self.isAnimation = YES;
    [UIView animateWithDuration:kUpAnimationDuration delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialVelocity options:kAnimationOptions animations:^{
        placeholderLabelAnimation();
        borderAndUnderliningAnimation();
        textFieldsAnimation();
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isAnimation = NO;
    }];
}

- (void)collapse{
    void (^underliningAnimation)(void) = ^void() {
        self.underlineView.alpha = 1.0f;
        self.underlineView.backgroundColor = self.underliningColor;
    };
    
    void (^placeHolderLabelAnimation)(void) = ^void() {
        self.placeholderLabel.textColor = self.placeholderFontColor;
        self.placeholderLabel.text = self.placeholderText;
        self.placeholderLabel.transform = CGAffineTransformIdentity;
        [self easeInOutView:self.placeholderLabel];
    };
    
    void (^borderAnimation)(void) = ^void() {
        for (UITextField *currentTextField in self.textFields) {
            currentTextField.layer.borderColor = self.borderColor ? self.borderColor.CGColor : self.underliningColor.CGColor;
        }
    };
    
    void (^textFieldsAnimation)(void) = ^void() {
        for (UITextField *currentTextField in self.textFields) {
            currentTextField.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1 + 2 * kMarginBetweenTextFields / currentTextField.frame.size.width, 0.001), CGAffineTransformMakeTranslation(0, currentTextField.frame.size.height / 2 - self.borderWidth));
        }
    };
    
    [self.underlineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    [self.placeholderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
    }];
    [UIView animateWithDuration:kDownAnimationDuration delay:0 options:kAnimationOptions animations:^{
        underliningAnimation();
        placeHolderLabelAnimation();
        borderAnimation();
        textFieldsAnimation();
        [self layoutIfNeeded];
    }completion:nil];
}

#pragma mark self 手势事件

- (void)viewTapped {
    if(self.isAnimation) return;
    BOOL isEdited = NO;
    for (UITextField *textField in self.textFields) {
        if (textField.text.length > 0) {
            isEdited = YES;
            break;
        }
    }
    
    if (!self.isEditing && !isEdited) {
        [self expansion];
    }
}

#pragma mark 设置视图

- (void)updateTextFields {
    NSUInteger numberOfSections = [_dataSource numberOfSectionsInTextField:self];
    self.isMultifield = numberOfSections > 1;
    for (NSUInteger i = 0; i < numberOfSections; i++) {
        TextFieldWithTextInsets *textField = [TextFieldWithTextInsets new];
        [self setupTextField:textField];
        [self addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            if (i == 0) {
                make.leading.equalTo(self).offset(1 * kMarginBetweenTextFields);
            }
            if (i > 0) {
                make.leading.equalTo(self.textFields[i - 1].mas_trailing).offset(kMarginBetweenTextFields);
                make.width.equalTo(self.textFields[0]);
            }
            if (i == numberOfSections - 1) {
                make.trailing.equalTo(self).offset(-kMarginBetweenTextFields);
            }
        }];
        [self.textFields addObject:textField];
    }
}

- (void)updateUnderliningView {
    self.underlineView = [UIView new];
    self.underlineView.backgroundColor = self.borderColor ? self.borderColor : self.underliningColor;
    [self addSubview:self.underlineView];
    [self.underlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.centerX.bottom.equalTo(self);
        make.width.equalTo(self);
    }];
}

- (void)setLeftView:(UIView *)leftView{
    _leftView = leftView;
    [self updateLeftView];
}

- (void)updateLeftView {
    if (!self.isMultifield) {
        [self.textFields firstObject].leftView = self.leftView;
        [[self.textFields firstObject] setLeftViewMode:UITextFieldViewModeAlways];
    }
}

- (void)updatePlaceholderLabel {
    self.placeholderLabel = [UILabel new];
    [self addSubview:self.placeholderLabel];
    self.placeholderLabel.textColor = self.placeholderFontColor;
    self.placeholderLabel.font = self.placeholderFont;
    self.placeholderLabel.text = self.placeholderText;
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.centerY.equalTo(self);
    }];
    self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setupTextField:(UITextField *)textField {
    textField.textColor = self.textFontColor;
    textField.font = self.textFont;
    textField.layer.borderColor = self.borderColor.CGColor;
    textField.layer.borderWidth = self.borderWidth;
    textField.tintColor = self.tintColor;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self;
    [textField addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark 设置 placeholder

- (void)setupPlaceholderPositionWithAlignment:(ZXInputFieldPlaceholderAlignment)alignment {
    self.placeholderAlignment = alignment;
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = placeholderText;
    self.placeholderLabel.text = placeholderText;
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    self.placeholderLabel.font = placeholderFont;
}

- (void)setPlaceholderFontColor:(UIColor *)placeholderFontColor {
    _placeholderFontColor = placeholderFontColor;
    self.placeholderLabel.textColor = placeholderFontColor;
}

- (void)setPlaceholderAlignment:(ZXInputFieldPlaceholderAlignment)placeholderAlignment{
    _placeholderAlignment = placeholderAlignment;
    switch (placeholderAlignment) {
        case ZXInputFieldPlaceholderAlignmentCenter: {
            self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
        case ZXInputFieldPlaceholderAlignmentLeft: {
            self.placeholderLabel.textAlignment = NSTextAlignmentLeft;
        }
            break;
        case ZXInputFieldPlaceholderAlignmentRight: {
            self.placeholderLabel.textAlignment = NSTextAlignmentRight;
        }
            break;
        default: {
            self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
    }
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.textAlignment = self.isMultifield ? NSTextAlignmentCenter : self.placeholderLabel.textAlignment;
    }
}

#pragma mark 设置 textField

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.font = textFont;
    }
}

- (void)setTextFontColor:(UIColor *)textFontColor {
    _textFontColor = textFontColor;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.textColor = textFontColor;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.tintColor = tintColor;
    }
}

#pragma mark 设置 textFieldsBorder

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.layer.borderWidth = borderWidth;
    }
}


#pragma mark 设置 keyboard
- (void)setKeyboardType:(UIKeyboardType)keyboardType{
    _keyboardType = keyboardType;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.keyboardType = keyboardType;
    }
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType{
    _returnKeyType = returnKeyType;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.returnKeyType = returnKeyType;
    }
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry{
    _secureTextEntry = secureTextEntry;
    for (UITextField *currentTextField in self.textFields) {
        currentTextField.secureTextEntry = secureTextEntry;
    }
}

- (void)setAccessoryViewMode:(ZXAccessoryViewMode)accessoryViewMode{
    _accessoryViewMode = accessoryViewMode;
    self.accessoryView = _accessoryView;
}

- (void)setAccessoryView:(UIView *)accessoryView{
    _accessoryView = accessoryView;
    if(!_accessoryView) return;
    if (self.accessoryViewMode == ZXAccessoryViewModeAlways) {
        for (UITextField *currentTextField in self.textFields) {
            currentTextField.inputAccessoryView = accessoryView;
        }
    }else{
        self.textFields.lastObject.inputAccessoryView = accessoryView;
    }
}

- (void)setConstraintEntryType:(ZXConstraintEntryType)constraintEntryType{
    _constraintEntryType = constraintEntryType;
    if (_constraintEntryType == ZXConstraintEntryTypeNumber) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }else if (_constraintEntryType & ZXConstraintEntryTypeNumber && _constraintEntryType & ZXConstraintEntryTypeCharacter){
        self.keyboardType = UIKeyboardTypeASCIICapable;
    }
    else{
        self.keyboardType = UIKeyboardTypeDefault;
    }
}

#pragma mark text

- (NSString *)text {
    NSMutableString *concat = [[NSMutableString alloc] init];
    for (UITextField *textField in self.textFields) {
        [concat appendString:textField.text];
    }
    return concat;
}

- (void)setText:(NSString *)text{
    if(!self.isFinsh){
        self.tempText = text;
        return;
    }
    for (UITextField *textField in self.textFields) {
        textField.text = @"";
    }
    [self viewTapped];
    NSUInteger numberOfSections = self.textFields.count;
    if(numberOfSections == 0) return;
    NSUInteger lengthOfSections[numberOfSections];
    NSUInteger summLength = 0;
    for (NSUInteger i = 0; i < numberOfSections; ++i) {
        lengthOfSections[i] = [_dataSource numberOfCharactersInSection:i inTextField:self];
        summLength += lengthOfSections[i];
    }
    if (summLength < text.length) {
        text = [text substringToIndex:summLength];
    }
    for (NSUInteger i = 0; i < numberOfSections; ++i) {
        self.textFields[i].text = [text substringToIndex:(lengthOfSections[i] < text.length) ? lengthOfSections[i] : text.length];
        text = [text substringFromIndex:(lengthOfSections[i] < text.length) ? lengthOfSections[i] : text.length];
    }
    [self validateInput];
    [self resignFirstResponder];
}

#pragma mark 重置方法

- (void)reload {
    NSString *currentText = self.text;
    self.textFields = [[NSMutableArray alloc] init];
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self.isFinsh = NO;
    [self updatePlaceholderLabel];
    [self updateTextFields];
    [self updateUnderliningView];
    [self updateLeftView];
    if (currentText.length > 0) {
        self.text = currentText;
    }
}

- (void)resetInput{
    [self.textFields enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.text = @"";
        [self collapse];
    }];
}

#pragma mark 响应

- (BOOL)isFirstResponder {
    for (UITextField *textField in self.textFields) {
        if ([textField isFirstResponder]) {
            return YES;
        }
    }
    return NO;
}

- (void)_becomeFirstResponder {
    BOOL needResponding = YES;
    for (UITextField *currentTexField in self.textFields) {
        if (currentTexField.text.length != [self.dataSource numberOfCharactersInSection:[self.textFields indexOfObject:currentTexField] inTextField:self]) {
            [currentTexField becomeFirstResponder];
            needResponding = NO;
            break;
        }
    }
    if (needResponding) {
        [[self.textFields lastObject] becomeFirstResponder];
    }
}

- (void)_resignFirstResponder {
    for (UITextField *textField in self.textFields) {
        [textField resignFirstResponder];
    }
}

#pragma mark 类实例化

+ (ZXInputField *)borderedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                delegate:(id<ZXFieldDelegate>)delegate
                                   block:(Complete)block{
    ZXInputField *field = [[ZXInputField alloc]init];
    field.dataSource = dataSource;
    field.delegate = delegate;
    [field reload];
    if(block)block(field);
    return field;
}

+ (ZXInputField *)underlinedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                  delegate:(id<ZXFieldDelegate>)delegate
                                     block:(Complete)block{
    ZXInputField *field = [[ZXInputField alloc]init];
    field.dataSource = dataSource;
    field.delegate = delegate;
    field.borderColor = nil;
    field.borderWidth = 0.f;
    [field reload];
    if(block)block(field);
    return field;
}

+ (ZXInputField *)borderedFieldWithWithDataSource:(id<ZXFieldDataSource> )dataSource
                                    delegate:(id<ZXFieldDelegate>)delegate
                             placeholderText:(NSString *)placeholderText
                                       block:(Complete)block{
    ZXInputField *field = [[ZXInputField alloc]init];
    field.dataSource = dataSource;
    field.delegate = delegate;
    field.placeholderText = placeholderText;
    [field reload];
    if(block)block(field);
    return field;
}

+ (ZXInputField *)borderedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                delegate:(id<ZXFieldDelegate>)delegate
                         placeholderText:(NSString *)placeholderText
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(UIColor *)borderColor
                        upperBorderColor:(UIColor *)upperBorderColor
                                   block:(Complete)block{
    ZXInputField *field = [[ZXInputField alloc]init];
    field.dataSource = dataSource;
    field.delegate = delegate;
    field.placeholderText = placeholderText;
    field.borderWidth = borderWidth;
    field.borderColor = borderColor;
    field.upperBorderColor = upperBorderColor;
    [field reload];
    if(block)block(field);
    return field;
}

+ (ZXInputField *)underlinedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                  delegate:(id<ZXFieldDelegate>)delegate
                         underliningHeight:(CGFloat)underliningHeight
                          underliningColor:(UIColor *)underliningColor
                                     block:(Complete)block{
    ZXInputField *field = [[ZXInputField alloc]init];
    field.dataSource = dataSource;
    field.delegate = delegate;
    field.borderWidth = underliningHeight;
    field.underliningColor = underliningColor;
    field.borderColor = nil;
    field.borderWidth = 0.f;
    [field reload];
    if(block)block(field);
    return field;
}

@end
