//
//  ZXTimerDisplay.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXAlertButton.h"

@interface ZXTimerDisplay : UIView {
    CGFloat currentAngle;
    CGFloat currentTime;
    CGFloat timerLimit;
    CGFloat radius;
    CGFloat lineWidth;
    NSTimer *timer;
    ZXActionBlock completedBlock;
}

@property CGFloat currentAngle;
@property NSInteger buttonIndex;
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) BOOL reverse;

- (instancetype)initWithOrigin:(CGPoint)origin radius:(CGFloat)r;
- (instancetype)initWithOrigin:(CGPoint)origin radius:(CGFloat)r lineWidth:(CGFloat)width;
- (void)updateFrame:(CGSize)size;
- (void)cancelTimer;
- (void)stopTimer;
- (void)startTimerWithTimeLimit:(int)tl completed:(ZXActionBlock)completed;

@end
