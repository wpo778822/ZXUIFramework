//
//  ZXBadgeProtocol.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/30.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -- types definition

#define kBadgeBreatheAniKey     @"breathe"
#define kBadgeRotateAniKey      @"rotate"
#define kBadgeShakeAniKey       @"shake"
#define kBadgeScaleAniKey       @"scale"
#define kBadgeBounceAniKey      @"bounce"

//key for associative methods during runtime
static char badgeLabelKey;
static char badgeBgColorKey;
static char badgeFontKey;
static char badgeTextColorKey;
static char badgeAniTypeKey;
static char badgeFrameKey;
static char badgeCenterOffsetKey;
static char badgeMaximumBadgeNumberKey;
static char badgeRadiusKey;

/**
 显示样式

 - ZXBadgeStyleRedDot: 红点
 - ZXBadgeStyleNumber: 数字
 - ZXBadgeStyleText: 文本
 */
typedef NS_ENUM(NSUInteger, ZXBadgeStyle){
    ZXBadgeStyleRedDot = 0,
    ZXBadgeStyleNumber,
    ZXBadgeStyleText
};


#pragma mark -- protocol definition

@protocol ZXBadgeProtocol <NSObject>

@required

@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) UIFont *badgeFont;
@property (nonatomic, strong) UIColor *badgeBgColor;
@property (nonatomic, strong) UIColor *badgeTextColor;
@property (nonatomic, assign) CGRect badgeFrame;
@property (nonatomic, assign) CGPoint  badgeCenterOffset;
@property (nonatomic, assign) NSInteger badgeMaximumBadgeNumber;
@property (nonatomic, assign) CGFloat badgeRadius;

@end

