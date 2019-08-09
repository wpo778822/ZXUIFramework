//
//  ZXScrollLabelView.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/8.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXScrollLabelView : UIScrollView

/**
 滚动模式
 - ZXScrollLabelViewTypeLeftRight: 自然方向
 - ZXScrollLabelViewTypeUpDown: 上下连续
 - ZXScrollLabelViewTypeFlipNoRepeat: 翻页效果
 */
typedef NS_ENUM(NSInteger, ZXScrollLabelViewType) {
    ZXScrollLabelViewTypeLeftRight = 0,
    ZXScrollLabelViewTypeUpDown,
    ZXScrollLabelViewTypeFold
};

#pragma mark - On Used Property

/** 滚动文字 */
@property (copy, nonatomic) NSString *text;
/** 文字数组 */
@property (copy, nonatomic) NSArray *scrollTexts;
/** ZXScrollLabelViewTypeLeftRight */
@property (assign, nonatomic) ZXScrollLabelViewType scrollType;
/** [0.1, 10]*/
@property (assign, nonatomic) NSTimeInterval scrollVelocity;
/** [UIColor whiteColor] */
@property (strong, nonatomic) UIColor *textColor;
/** UIEdgeInsetsMake(0, 5, 0, 5) */
@property (assign, nonatomic) UIEdgeInsets scrollInset;
/** 0.f */
@property (assign, nonatomic) CGFloat scrollSpace;
/** NSTextAlignmentCenter */
@property (assign, nonatomic) NSTextAlignment textAlignment;
/** [UIFont systemFontOfSize:14] */
@property (strong, nonatomic) UIFont *font;

#pragma mark - setupAttributeTitle

- (void)setupAttributeTitle:(NSAttributedString *)attributeTitle;

#pragma mark - Instance Methods

- (instancetype)initWithTitle:(NSString *)scrollTitle
                         type:(ZXScrollLabelViewType)scrollType
                     velocity:(NSTimeInterval)scrollVelocity
                        inset:(UIEdgeInsets)inset;

#pragma mark - Factory Methods

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle;

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(ZXScrollLabelViewType)scrollType;

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(ZXScrollLabelViewType)scrollType
                       velocity:(NSTimeInterval)scrollVelocity;

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(ZXScrollLabelViewType)scrollType
                       velocity:(NSTimeInterval)scrollVelocity
                          inset:(UIEdgeInsets)inset;

#pragma mark - Operation Methods
- (void) beginScrolling;
- (void) endScrolling;

@end

@interface ZXScrollLabelView (TitleArray)
/**
  数组显示
 （当scrollType == ZXScrollLabelViewTypeFold时一串一行，截断字符）
  scrollSpace无效
 */
+ (instancetype)scrollWithTextArray:(NSArray *)scrollTexts
                               type:(ZXScrollLabelViewType)scrollType
                           velocity:(NSTimeInterval)scrollVelocity
                              inset:(UIEdgeInsets)inset;

@end

