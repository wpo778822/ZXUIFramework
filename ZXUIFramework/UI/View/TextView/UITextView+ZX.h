//
//  UITextView+ZX.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/11.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextView (ZX)


- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange;

- (void)setTextKeepingSelectedRange:(NSString *)text;

- (void)setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;

- (void)scrollCaretVisibleAnimated:(BOOL)animated;

@end
