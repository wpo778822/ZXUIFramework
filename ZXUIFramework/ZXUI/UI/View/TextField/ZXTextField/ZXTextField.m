//
//  ZXTextField.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXTextField.h"
#import "ZXTextField+category.h"
#import "NSString+category.h"

@interface _ZXTextFieldDelegator : NSObject <ZXTextFieldDelegate, UIScrollViewDelegate>

@property(nonatomic, weak) ZXTextField *textField;
- (void)handleTextChangeEvent:(ZXTextField *)textField;
@end

@interface ZXTextField ()

@property(nonatomic, strong) _ZXTextFieldDelegator *delegator;
@end

@implementation ZXTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.delegator = [[_ZXTextFieldDelegator alloc] init];
    self.delegator.textField = self;
    self.delegate = self.delegator;
    [self addTarget:self.delegator action:@selector(handleTextChangeEvent:) forControlEvents:UIControlEventEditingChanged];
    self.constraintEntryType = ZXTextFieldConstraintEntryTypeNone;
    self.shouldResponseToProgrammaticallyTextChanges = YES;
    self.maximumTextLength = NSUIntegerMax;
    self.canResign = YES;
}

- (void)dealloc {
    self.delegate = nil;
}

- (BOOL)canResignFirstResponder{
    return self.canResign;
}

/// 为给定的rect往内部缩小insets的大小
CG_INLINE CGRect
RectInsetEdges(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width -= GetHorizontalValue(insets);
    rect.size.height -= GetVerticalValue(insets);
    return rect;
}

/// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat
GetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
GetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

#pragma mark - Placeholder

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    if (self.placeholder) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    if (self.placeholderColor) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)updateAttributedPlaceholderIfNeeded {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
}

#pragma mark - TextInsets

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = RectInsetEdges(bounds, self.textInsets);
    CGRect resultRect = [super textRectForBounds:bounds];
    return resultRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = RectInsetEdges(bounds, self.textInsets);
    return [super editingRectForBounds:bounds];
}

#pragma mark - TextPosition

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 10.0, *)) {
        UIScrollView *scrollView = self.subviews.firstObject;
        if (![scrollView isKindOfClass:[UIScrollView class]]) {
            return;
        }
        
        if (scrollView.delegate) {
            return;
        }
        scrollView.delegate = self.delegator;
    }
}

- (void)setText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    [super setText:text];
    
    if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToString:text]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    NSAttributedString *textBeforeChange = self.attributedText;
    [super setAttributedText:attributedText];
    if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToAttributedString:attributedText]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)fireTextDidChangeEventForTextField:(ZXTextField *)textField {
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return string.length;
}

#pragma mark - set

- (void)setConstraintEntryType:(ZXTextFieldConstraintEntryType)constraintEntryType{
    _constraintEntryType = constraintEntryType;
    if (_constraintEntryType == ZXTextFieldConstraintEntryTypeNumber) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }else if (_constraintEntryType & ZXTextFieldConstraintEntryTypeNumber && _constraintEntryType & ZXTextFieldConstraintEntryTypePoint){
        self.keyboardType = UIKeyboardTypeDecimalPad;
    }else if (_constraintEntryType & ZXTextFieldConstraintEntryTypeNumber && _constraintEntryType & ZXTextFieldConstraintEntryTypeCharacter){
        self.keyboardType = UIKeyboardTypeASCIICapable;
    }
    else{
        self.keyboardType = UIKeyboardTypeDefault;
    }
}

@end

@implementation _ZXTextFieldDelegator

#pragma mark - <ZXTextFieldDelegate>

- (BOOL)textField:(ZXTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isEntry = NO;
    isEntry = isEntry ?: [string isNumber] && (textField.constraintEntryType & ZXTextFieldConstraintEntryTypeNumber);
    isEntry = isEntry ?: [string isChinese] && (textField.constraintEntryType & ZXTextFieldConstraintEntryTypeChinese);
    isEntry = isEntry ?: [string isCharacter] && (textField.constraintEntryType & ZXTextFieldConstraintEntryTypeCharacter);
    isEntry = isEntry ?: ([textField.text rangeOfString:@"."].location == NSNotFound) && [string isEqualToString:@"."] && (textField.constraintEntryType & ZXTextFieldConstraintEntryTypePoint);
    
    if(!isEntry && string.length > 0 && textField.constraintEntryType != ZXTextFieldConstraintEntryTypeNone) return NO;
    if (textField.maximumTextLength < NSUIntegerMax) {
        BOOL isDeleting = range.length > 0 && string.length <= 0;
        if (isDeleting || textField.markedTextRange) {
            return YES;
        }
        
        NSUInteger rangeLength = range.length;
        if ([textField lengthWithString:textField.text] - rangeLength + [textField lengthWithString:string] > textField.maximumTextLength) {
            NSInteger substringLength = textField.maximumTextLength - [textField lengthWithString:textField.text] + rangeLength;
            if (substringLength > 0 && [textField lengthWithString:string] > substringLength) {
                NSRange characterSequencesRange = [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(0, substringLength) string:string];
                NSString *allowedText = [string substringWithRange:characterSequencesRange];
                if ([textField lengthWithString:allowedText] <= substringLength) {
                    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:allowedText];
                    
                    if (!textField.shouldResponseToProgrammaticallyTextChanges) {
                        [textField fireTextDidChangeEventForTextField:textField];
                    }
                }
            }
            
            if ([textField.zxDelegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
                [textField.zxDelegate textField:textField didPreventTextChangeInRange:range replacementString:string];
            }
            return NO;
        }
    }
    
    return YES;
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


- (void)handleTextChangeEvent:(ZXTextField *)textField {
    if (!textField.markedTextRange) {
        if ([textField lengthWithString:textField.text] > textField.maximumTextLength) {
            NSRange characterSequencesRange = [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(0, textField.maximumTextLength) string:textField.text];
            textField.text = [textField.text substringWithRange:characterSequencesRange];
            if ([textField.zxDelegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
                [textField.zxDelegate textField:textField didPreventTextChangeInRange:textField.selectedRange replacementString:@""];
            }
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.textField.subviews.firstObject) {
        return;
    }
    
    CGFloat lineHeight = ((NSParagraphStyle *)self.textField.defaultTextAttributes[NSParagraphStyleAttributeName]).minimumLineHeight;
    lineHeight = lineHeight ?: ((UIFont *)self.textField.defaultTextAttributes[NSFontAttributeName]).lineHeight;
    if (scrollView.contentSize.height > ceil(lineHeight) && scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

@end
