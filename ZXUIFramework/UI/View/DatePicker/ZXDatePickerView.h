//
//  ZXDatePickerView.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/6/27.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  选择日期类型
 */
typedef NS_ENUM(NSInteger, ZXDateStyle) {
    ZXDateStyleShowYearMonthDayHourMinute  = 0,//年月日时分
    ZXDateStyleShowYearMonthDayHour,//年月日时
    ZXDateStyleShowMonthDayHourMinute,//月日时分
    ZXDateStyleShowYearMonthDay,//年月日
    ZXDateStyleShowYearMonth,//年月
    ZXDateStyleShowMonthDay,//月日
    ZXDateStyleShowHourMinute//时分
};

/**
 *  显示日期模式
 */
typedef NS_ENUM(NSInteger, ZXDateMode) {
    ZXDateModeWithoutPast  = 0,//默认不显示过去的时间
    ZXDateModeAll,//显示过去时间
};


typedef void(^CompleteBlock)(NSDate *date);

@protocol ZXDatePickerViewDelegate <NSObject>
@optional
/**
 选中时间回调
 */
- (void)didSelectDate:(NSDate *)date;
@end

@interface ZXDatePickerView : UIView

/**
 日期数据显示范围
 */
@property (nonatomic, assign) ZXDateMode showMode;

/**
 *  确定按钮颜色
 */
@property (nonatomic,strong)UIColor *doneButtonColor;
/**
 *  年-月-日-时-分
 */
@property (nonatomic,strong)UIColor *dateLabelColor;
/**
 *  滚轮日期颜色(默认黑色)
 */
@property (nonatomic,strong)UIColor *datePickerColor;

/**
 *  限制最大时间（默认2099）datePicker大于最大日期则滚动回最大限制日期
 */
@property (nonatomic, copy) NSDate *maxLimitDate;
/**
 *  限制最小时间（默认1000） datePicker小于最小日期则滚动回最小限制日期
 */
@property (nonatomic, copy) NSDate *minLimitDate;

/**
 *  大号年份字体颜色(默认灰色)想隐藏可以设置为clearColor
 */
@property (nonatomic, copy) UIColor *yearLabelColor;

/**
 *  隐藏背景年份文字
 */
@property (nonatomic, assign) BOOL hideBackgroundYearLabel;

/**
 代理
 */
@property (nonatomic, weak) id <ZXDatePickerViewDelegate> delegate;

/**
 默认滚动到当前时间
 */
-(instancetype)initWithDateStyle:(ZXDateStyle)datePickerStyle
                   completeBlock:(CompleteBlock)completeBlock;

/**
 滚动到指定的的日期
 */
-(instancetype)initWithDateStyle:(ZXDateStyle)datePickerStyle
                    scrollToDate:(NSDate *)scrollToDate
                   completeBlock:(CompleteBlock)completeBlock;

-(instancetype)initWithDateStyle:(ZXDateStyle)datePickerStyle
                    scrollToDate:(NSDate *)scrollToDate
                       extPicker:(UIPickerView *)extPicker
                   completeBlock:(CompleteBlock)completeBlock;

-(void)show;

@end
