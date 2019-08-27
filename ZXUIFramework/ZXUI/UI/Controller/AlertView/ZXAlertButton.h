//
//  ZXButton.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXTimerDisplay;

@interface ZXAlertButton : UIButton

typedef void (^ZXActionBlock)(void);
typedef BOOL (^ZXValidationBlock)(void);
typedef NSDictionary* (^CompleteButtonFormatBlock)(void);
typedef NSDictionary* (^ButtonFormatBlock)(void);

typedef NS_ENUM(NSInteger, ZXActionType){
    ZXNone,
    ZXSelector,
    ZXBlock
};

@property ZXActionType actionType;

@property (copy, nonatomic) ZXActionBlock actionBlock;

@property (copy, nonatomic) ZXValidationBlock validationBlock;

@property (copy, nonatomic) CompleteButtonFormatBlock completeButtonFormatBlock;

@property (copy, nonatomic) ButtonFormatBlock buttonFormatBlock;

@property (strong, nonatomic) UIColor *defaultBackgroundColor UI_APPEARANCE_SELECTOR;

@property id target;

@property SEL selector;

- (void)parseConfig:(NSDictionary *)buttonConfig;

@property (strong, nonatomic) ZXTimerDisplay *timer;

- (instancetype)initWithWindowWidth:(CGFloat)windowWidth;

- (void)adjustWidthWithWindowWidth:(CGFloat)windowWidth numberOfButtons:(NSUInteger)numberOfButtons;

@end
