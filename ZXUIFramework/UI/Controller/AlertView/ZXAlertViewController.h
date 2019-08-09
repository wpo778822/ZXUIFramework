//
//  ZXAlertViewController.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXAlertButton.h"
#import "ZXTextFieldBorder.h"
#import "ZXTextViewBorder.h"
#import "ZXSwitchView.h"

typedef NSAttributedString* (^ZXAttributedFormatBlock)(NSString *value);
typedef void (^ZXDismissBlock)(void);
typedef void (^ZXDismissAnimationCompletionBlock)(void);
typedef void (^ZXShowAnimationCompletionBlock)(void);
typedef void (^ZXForceHideBlock)(void);

@interface ZXAlertViewController : UIViewController 


typedef NS_ENUM(NSInteger, ZXAlertViewStyle){
    ZXAlertViewStyleSuccess,
    ZXAlertViewStyleError,
    ZXAlertViewStyleNotice,
    ZXAlertViewStyleWarning,
    ZXAlertViewStyleInfo,
    ZXAlertViewStyleEdit,
    ZXAlertViewStyleWaiting,
    ZXAlertViewStyleQuestion,
    ZXAlertViewStyleCustom
};

typedef NS_ENUM(NSInteger, ZXAlertViewHideAnimation){
    ZXAlertViewHideAnimationFadeOut,
    ZXAlertViewHideAnimationSlideOutToBottom,
    ZXAlertViewHideAnimationSlideOutToTop,
    ZXAlertViewHideAnimationSlideOutToLeft,
    ZXAlertViewHideAnimationSlideOutToRight,
    ZXAlertViewHideAnimationSlideOutToCenter,
    ZXLAlertViewHideAnimationSlideOutFromCenter,
    ZXLAlertViewHideAnimationSimplyDisappear
};

typedef NS_ENUM(NSInteger, ZXAlertViewShowAnimation){
    ZXAlertViewShowAnimationFadeIn,
    ZXAlertViewShowAnimationSlideInFromBottom,
    ZXAlertViewShowAnimationSlideInFromTop,
    ZXAlertViewShowAnimationSlideInFromLeft,
    ZXAlertViewShowAnimationSlideInFromRight,
    ZXAlertViewShowAnimationSlideInFromCenter,
    ZXAlertViewShowAnimationSlideInToCenter,
    ZXAlertViewShowAnimationSimplyAppear
};

typedef NS_ENUM(NSInteger, ZXAlertViewBackground){
    ZXAlertViewBackgroundShadow,
    ZXAlertViewBackgroundBlur,
    ZXAlertViewBackgroundTransparent
};

/**
 圆角（ 无数据返回缺省 5.0f）
 */
@property (assign, nonatomic) CGFloat cornerRadius;

/**
 TintColor 顶部圆圈色 （默认值 ：YES，NO下穿backgroundColor）
 */
@property (assign, nonatomic) BOOL tintTopCircle;

/**
 标题
 */
@property (strong, nonatomic) UILabel *labelTitle;

/**
 提示信息TextView
 */
@property (strong, nonatomic) UITextView *viewText;

/**
 加载
 */
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

/**
 音效地址
 */
@property (strong, nonatomic) NSURL *soundURL;

/**
 富文本配置块
 */
@property (copy, nonatomic) ZXAttributedFormatBlock attributedFormatBlock;

/**
 默认确认按钮配置块
 */
@property (copy, nonatomic) CompleteButtonFormatBlock completeButtonFormatBlock;

/**
 自定义按钮配置块
 */
@property (copy, nonatomic) ButtonFormatBlock buttonFormatBlock;

/**
 隐藏动画 （默认 FadeOut）
 */
@property (nonatomic) ZXAlertViewHideAnimation hideAnimationType;

/**
 显示动画（默认 SlideInFromTop）
 */
@property (nonatomic) ZXAlertViewShowAnimation showAnimationType;

/**
 背景显示类型 （默认 shadow）
 */
@property (nonatomic) ZXAlertViewBackground backgroundType;

/**
 自定义颜色 （生效范围：button、topCircle、border）
 */
@property (strong, nonatomic) UIColor *customViewColor;

/**
 背景色 （缺省 white）
 */
@property (strong, nonatomic) UIColor *backgroundViewColor;

/**
 图标tintColor （缺省 无）
 */
@property (strong, nonatomic) UIColor *iconTintColor;

/**
 图标大小 （默认 20.0f）
 */
@property (nonatomic) CGFloat circleIconHeight;

/**
 横向显示button （默认 NO）
 */
@property (nonatomic) BOOL horizontalButtons;

/**
 执行done时dismiss自身（默认 YES）
 */
@property (nonatomic) BOOL dismissOnConfirm;

/**
 视图消失

 @param dismissBlock 返回块
 */
- (void)alertIsDismissed:(ZXDismissBlock)dismissBlock;

/**
 视图消失(动画完成时)

 @param dismissAnimationCompletionBlock 返回块
 */
- (void)alertDismissAnimationIsCompleted:(ZXDismissAnimationCompletionBlock)dismissAnimationCompletionBlock;

/**
 视图出现（动画完成）

 @param showAnimationCompletionBlock 返回块
 */
- (void)alertShowAnimationIsCompleted:(ZXShowAnimationCompletionBlock)showAnimationCompletionBlock;

/**
 隐藏视图
 */
- (void)hideView;

/**
 移除顶部圆圈
 */
- (void)removeTopCircle;

- (UIView *)addCustomView:(UIView *)customView;

- (ZXTextViewBorder *)addTextView:(NSString *)title;

- (ZXTextFieldBorder *)addTextField:(NSString *)title;

- (void)addCustomTextField:(UITextField *)textField;

- (ZXSwitchView *)addSwitchViewWithLabel:(NSString *)label;

- (void)addTimerToButtonIndex:(NSInteger)buttonIndex reverse:(BOOL)reverse;

- (void)setTitleFont:(UIFont *)titleFont;

- (void)setBodyTextFont:(UIFont *)bodyTextFont;

- (void)setButtonsTextFont:(UIFont *)buttonsFont;

- (ZXAlertButton *)addButton:(NSString *)title actionBlock:(ZXActionBlock)action;

- (ZXAlertButton *)addButton:(NSString *)title validationBlock:(ZXValidationBlock)validationBlock actionBlock:(ZXActionBlock)action;

- (ZXAlertButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector;

- (void)showSuccess:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showError:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showNotice:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showWarning:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showInfo:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showEdit:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showTitle:(NSString *)title subTitle:(NSString *)subTitle style:(ZXAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showCustom:(UIImage *)image color:(UIColor *)color title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showWaiting:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

- (void)showQuestion:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration;

@end
