//
//  ZXNoticeView.h
//  ZXartApp
//
//  Created by Apple on 2017/6/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZXNoticeView;
typedef void (^Completion)(void);
typedef NS_ENUM(NSInteger , ZXNoticeType) {
    ZXNoticeTypeSuccess = 0,
    ZXNoticeTypeFail,
    ZXNoticeTypeError,
    ZXNoticeTypeInfo,
    ZXNoticeTypeMessage
};
@protocol ZXNoticeViewDelegate <NSObject>
@optional
/**
 点击事件回调
 */
- (void)zxNoticeViewAction:(ZXNoticeView *)zxNoticeView;
/**
 动画开始代理
 */
- (void)zxNoticeViewWillAppear:(ZXNoticeView *)zxNoticeView;
@end

@interface ZXNoticeView : UIWindow
/**
 代理
 */
@property (nonatomic, weak) id <ZXNoticeViewDelegate> delegate;

/**
 默认通知
 动画时长 Default is 1.2 ，(停留时间=动画时长 * 1.5)。
 无代理事件
 @param string 文字
 @param type 通知类型
 @param completion 完成
 @return self
 */
+ (instancetype)showNoticeViewWithInfoString:(NSString *)string
                                        type:(ZXNoticeType)type
                                  completion:(Completion)completion;

/**
 自定义视图
 
 @param string 文字
 @param type 通知类型
 @param dunrationTime 动画时间
 @param residenceTime 停留时间
 @param delegate 代理
 @param completion 完成
 @return self
 */
+ (instancetype)showNoticeViewWithInfoString:(NSString *)string
                                        type:(ZXNoticeType)type
                               dunrationTime:(CGFloat)dunrationTime
                               residenceTime:(CGFloat)residenceTime
                                    delegate:(id<ZXNoticeViewDelegate>)delegate
                                  completion:(Completion)completion;
@end
