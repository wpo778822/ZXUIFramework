//
//  UITextView+ZX.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/11.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "UITextView+ZX.h"
#import "ZXMacro.h"
@implementation UITextView (ZX)

- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (void)setTextKeepingSelectedRange:(NSString *)text {
    UITextRange *selectedTextRange = self.selectedTextRange;
    self.text = text;
    self.selectedTextRange = selectedTextRange;
}

- (void)setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText {
    UITextRange *selectedTextRange = self.selectedTextRange;
    self.attributedText = attributedText;
    self.selectedTextRange = selectedTextRange;
}

- (void)scrollCaretVisibleAnimated:(BOOL)animated {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    
    if (!CGRectIsValidated(caretRect)) {
        return;
    }
    
    CGFloat contentOffsetY;
    
    if (CGRectGetMinY(caretRect) == self.contentOffset.y + self.textContainerInset.top) {
        return;
    }
    
    if (CGRectGetMinY(caretRect) < self.contentOffset.y + self.textContainerInset.top) {
        contentOffsetY = CGRectGetMinY(caretRect) - self.textContainerInset.top - self.contentInset.top;
    } else if (CGRectGetMaxY(caretRect) > self.contentOffset.y + CGRectGetHeight(self.bounds) - self.textContainerInset.bottom - self.contentInset.bottom) {
        contentOffsetY = CGRectGetMaxY(caretRect) - CGRectGetHeight(self.bounds) + self.textContainerInset.bottom + self.contentInset.bottom;
    } else {
        return;
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffsetY) animated:animated];
}

@end
