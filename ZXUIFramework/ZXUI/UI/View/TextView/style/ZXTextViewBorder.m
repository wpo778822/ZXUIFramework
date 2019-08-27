//
//  ZXTextViewBorder.m
//  EasyHome
//
//  Created by mac on 2018/10/26.
//  Copyright © 2018 黄勤炜. All rights reserved.
//

#import "ZXTextViewBorder.h"
#define MIN_HEIGHT 120.0f

@implementation ZXTextViewBorder

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (void)setup{
    self.frame = CGRectMake(0.0f, 0.0f, 0.0f, MIN_HEIGHT);
    self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
}

@end
