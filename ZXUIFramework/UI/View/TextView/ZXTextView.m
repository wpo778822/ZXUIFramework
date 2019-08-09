//
//  ZXTextView.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/11.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXTextView.h"
#import "UITextView+ZX.h"
#import "ZXMacro.h"
const CGFloat kSystemTextViewDefaultFontPointSize = 12.0f;

const UIEdgeInsets kSystemTextViewFixTextInsets = {0, 5, 0, 5};

@interface _ZXTextViewDelegator : NSObject <ZXTextViewDelegate>

@property(nonatomic, weak) ZXTextView *textView;
@end

@interface ZXTextView ()

@property(nonatomic, assign) BOOL postInitializationMethodCalled;
@property(nonatomic, strong) _ZXTextViewDelegator *delegator;
@property(nonatomic, assign) BOOL shouldRejectSystemScroll;

@property(nonatomic, strong) UILabel *placeholderLabel;

@property(nonatomic, strong) UILabel *surplusTextNumberLabel;

@end

@implementation ZXTextView

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
    self.delegator = [[_ZXTextViewDelegator alloc] init];
    self.delegator.textView = self;
    self.delegate = self.delegator;
    
    self.scrollsToTop = NO;
    self.placeholderColor = [UIColor colorUsingHexString:@"#C7C7CD"];
    self.placeholderMargins = UIEdgeInsetsZero;
    self.maximumHeight = CGFLOAT_MAX;
    self.maximumTextLength = NSUIntegerMax;
    self.shouldResponseToProgrammaticallyTextChanges = YES;
    if (@available(iOS 11, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.font = UIFontWithSize(SCALE_SET(18));
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.font = UIFontWithSize(SCALE_SET(18));
    self.placeholderLabel.textColor = self.placeholderColor;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.alpha = 0;
    [self addSubview:self.placeholderLabel];
    self.surplusTextNumberLabel = [[UILabel alloc] init];
    self.surplusTextNumberLabel.font = UIFontWithSize(SCALE_SET(16));;
    self.surplusTextNumberLabel.textColor = self.placeholderLabel.textColor;
    self.surplusTextNumberLabel.numberOfLines = 0;
    self.surplusTextNumberLabel.alpha = 0;
    [self addSubview:self.surplusTextNumberLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.postInitializationMethodCalled = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; text.length: %@ | %@; markedTextRange: %@", [super description], @(self.text.length), @([self lengthWithString:self.text]), self.markedTextRange];
}

- (BOOL)isCurrentTextDifferentOfText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    if ([textBeforeChange isEqualToString:text] || (textBeforeChange.length == 0 && !text)) {
        return NO;
    }
    return YES;
}

- (void)setText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    BOOL textDifferent = [self isCurrentTextDifferentOfText:text];
    if (!textDifferent) {
        [super setText:text];
        return;
    }
    if (self.shouldResponseToProgrammaticallyTextChanges) {
        BOOL shouldChangeText = YES;
        if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            shouldChangeText = [self.delegate textView:self shouldChangeTextInRange:NSMakeRange(0, textBeforeChange.length) replacementText:text];
        }
        
        if (!shouldChangeText) {
            return;
        }
        
        [super setText:text];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
        
    } else {
        [super setText:text];
        [self handleTextChanged:self];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    NSString *textBeforeChange = self.attributedText.string;
    BOOL textDifferent = [self isCurrentTextDifferentOfText:attributedText.string];

    if (!textDifferent) {
        [super setAttributedText:attributedText];
        return;
    }
    if (self.shouldResponseToProgrammaticallyTextChanges) {
        BOOL shouldChangeText = YES;
        if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            shouldChangeText = [self.delegate textView:self shouldChangeTextInRange:NSMakeRange(0, textBeforeChange.length) replacementText:attributedText.string];
        }
        
        if (!shouldChangeText) {
            return;
        }
        
        [super setAttributedText:attributedText];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
        
    } else {
        [super setAttributedText:attributedText];
        [self handleTextChanged:self];
    }
}

- (void)setTypingAttributes:(NSDictionary<NSString *,id> *)typingAttributes {
    [super setTypingAttributes:typingAttributes];
    [self updatePlaceholderStyle];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updatePlaceholderStyle];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self updatePlaceholderStyle];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self updatePlaceholderStyle];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    if (@available(iOS 11, *)) {
    } else {
        [self setNeedsLayout];
    }
}


- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:_placeholder ?:@"" attributes:self.typingAttributes];
    if (self.placeholderColor) {
        self.placeholderLabel.textColor = self.placeholderColor;
    }
    [self sendSubviewToBack:self.placeholderLabel];
    [self setNeedsLayout];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = _placeholderColor;
}

-  (void)setShowSurplusTextNumber:(BOOL)showSurplusTextNumber{
    _showSurplusTextNumber = showSurplusTextNumber;
    if (_maximumTextLength < NSUIntegerMax) {
        self.surplusTextNumberLabel.alpha = _showSurplusTextNumber ? 1.0:.0;
    }
}

- (void)updatePlaceholderStyle {
    self.placeholder = self.placeholder;
}

- (void)handleTextChanged:(id)sender {
    if(self.placeholder.length > 0) {
        [self updatePlaceholderLabelHidden];
    }
    
    ZXTextView *textView = nil;
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (ZXTextView *)object;
        }
    } else if ([sender isKindOfClass:[ZXTextView class]]) {
        textView = (ZXTextView *)sender;
    }
    
    if (textView) {
        
        if ([textView.delegate respondsToSelector:@selector(textView:newHeightAfterTextChanged:)]) {
            
            CGFloat resultHeight = flat([textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.bounds), CGFLOAT_MAX)].height);
            
            if (resultHeight != flat(CGRectGetHeight(textView.bounds))) {
                if ([textView.zxDelegate respondsToSelector:@selector(textView:newHeightAfterTextChanged:)]) {
                    [textView.zxDelegate textView:textView newHeightAfterTextChanged:resultHeight];
                }
            }
        }
        
        if (!textView.window) {
            return;
        }
        
        textView.shouldRejectSystemScroll = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            textView.shouldRejectSystemScroll = NO;
            [textView scrollCaretVisibleAnimated:NO];
        });
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result.height = MIN(result.height, self.maximumHeight);
    return result;
}

- (void)setFrame:(CGRect)frame {
    if (self.postInitializationMethodCalled) {
        frame = CGRectSetHeight(frame, MIN(CGRectGetHeight(frame), self.maximumHeight));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.placeholder.length > 0) {
        UIEdgeInsets labelMargins = UIEdgeInsetsConcat(UIEdgeInsetsConcat(self.textContainerInset, self.placeholderMargins), kSystemTextViewFixTextInsets);
        CGFloat limitWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentInset) - UIEdgeInsetsGetHorizontalValue(labelMargins);
        CGFloat limitHeight = CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentInset) - UIEdgeInsetsGetVerticalValue(labelMargins);
        CGSize labelSize = [self.placeholderLabel sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
        labelSize.height = fmin(limitHeight, labelSize.height);
        self.placeholderLabel.frame = CGRectFlatMake(labelMargins.left, labelMargins.top, limitWidth, labelSize.height);
    }
    if (self.showSurplusTextNumber){
        if (self.maximumTextLength < NSUIntegerMax) {
            self.surplusTextNumberLabel.text = [NSString stringWithFormat:@"还可以输入%tu字",self.maximumTextLength - self.text.length];
        }
        CGSize labelSize = CGSizeMake(SCALE_SET(130), SCALE_SET(25));
        self.surplusTextNumberLabel.frame = CGRectMake(self.bounds.size.width - labelSize.width - 5, self.bounds.size.height - labelSize.height - 5, labelSize.width, labelSize.height);
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updatePlaceholderLabelHidden];
}

- (void)updatePlaceholderLabelHidden {
    if (self.text.length == 0 && self.placeholder.length > 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;
    }
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return string.length;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (!self.shouldRejectSystemScroll) {
        [super setContentOffset:contentOffset animated:animated];
    } else {
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if (!self.shouldRejectSystemScroll) {
        [super setContentOffset:contentOffset];
    } else {
    }
}

#pragma mark - <UIResponderStandardEditActions>

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL superReturnValue = [super canPerformAction:action withSender:sender];
    if (action == @selector(paste:) && self.canPerformPasteActionBlock) {
        return self.canPerformPasteActionBlock(sender, superReturnValue);
    }
    return superReturnValue;
}

- (void)paste:(id)sender {
    BOOL shouldCallSuper = YES;
    if (self.pasteBlock) {
        shouldCallSuper = self.pasteBlock(sender);
    }
    if (shouldCallSuper) {
        [super paste:sender];
    }
}

@end

@implementation _ZXTextViewDelegator

#pragma mark - <ZXTextViewDelegate>

- (BOOL)textView:(ZXTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([textView.zxDelegate respondsToSelector:@selector(textViewShouldReturn:)]) {
            BOOL shouldReturn = [textView.zxDelegate textViewShouldReturn:textView];
            if (shouldReturn) {
                return NO;
            }
        }
    }
    
    if (textView.maximumTextLength < NSUIntegerMax) {
        BOOL isDeleting = range.length > 0 && text.length <= 0;
        if (isDeleting || textView.markedTextRange) {
            return YES;
        }
        
        NSUInteger rangeLength = range.length;
        BOOL textWillOutofMaximumTextLength = [textView lengthWithString:textView.text] - rangeLength + [textView lengthWithString:text] > textView.maximumTextLength;
        if (textWillOutofMaximumTextLength) {
            if ([textView lengthWithString:textView.text] - rangeLength == textView.maximumTextLength && [text isEqualToString:@"\n"]) {
                return NO;
            }
            NSInteger substringLength = textView.maximumTextLength - [textView lengthWithString:textView.text] + rangeLength;
            
            if (substringLength > 0 && [textView lengthWithString:text] > substringLength) {
                NSRange characterSequencesRange = [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(0, substringLength) string:text];
                NSString *allowedText = [text substringWithRange:characterSequencesRange];
                if ([textView lengthWithString:allowedText] <= substringLength) {
                    textView.text = [textView.text stringByReplacingCharactersInRange:range withString:allowedText];
                    textView.selectedRange = NSMakeRange(range.location + substringLength, 0);
                    
                    if (!textView.shouldResponseToProgrammaticallyTextChanges && [textView.delegate respondsToSelector:@selector(textViewDidChange:)]) {
                        [textView.delegate textViewDidChange:textView];
                    }
                }
            }
            
            if ([textView.zxDelegate respondsToSelector:@selector(textView:didPreventTextChangeInRange:replacementText:)]) {
                [textView.zxDelegate textView:textView didPreventTextChangeInRange:range replacementText:text];
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(ZXTextView *)textView {
    if (!textView.markedTextRange) {
        if ([textView lengthWithString:textView.text] > textView.maximumTextLength) {
            NSRange characterSequencesRange = [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(0, textView.maximumTextLength) string:textView.text];
            textView.text = [textView.text substringWithRange:characterSequencesRange];
            if ([textView.zxDelegate respondsToSelector:@selector(textView:didPreventTextChangeInRange:replacementText:)]) {
                [textView.zxDelegate textView:textView didPreventTextChangeInRange:textView.selectedRange replacementText:nil];
            }
            
            if (textView.shouldResponseToProgrammaticallyTextChanges) {
                return;
            }
        }else{
            if (textView.surplusTextNumberLabel && textView.maximumTextLength < NSUIntegerMax) {
                textView.surplusTextNumberLabel.text = [NSString stringWithFormat:@"还可以输入%tu字",textView.maximumTextLength - textView.text.length];
            }
        }
    }
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
