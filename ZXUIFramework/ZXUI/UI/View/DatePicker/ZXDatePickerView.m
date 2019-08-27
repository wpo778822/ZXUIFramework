//
//  ZXDatePickerView.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/6/27.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXDatePickerView.h"
#import "NSDate+Extension.h"
#import "ZXMacro.h"
#import "UIView+ZXUI.h"
#import <Masonry.h>
#define FULL_FARME_HEIGHT 200
#define OFFSET 20
#define BUTTON_FARME_HEIGHT 50
#define EXT_FARME_HEIGHT 100

@interface ZXDatePickerView ()<UIPickerViewDelegate,UIPickerViewDataSource> {
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    NSString *_dateFormatter;
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    
    NSInteger preRow;
    
    NSDate *_startDate;
}


//view
@property (nonatomic,strong) UILabel      *showYearView;
@property (nonatomic,strong) UIPickerView *datePicker;
@property (nonatomic,strong) UIPickerView *extPicker;
@property (nonatomic,strong) UIButton     *doneBtn;

//some
@property (nonatomic, copy ) NSDate       *scrollToDate;//滚到指定日期
@property (nonatomic,strong) CompleteBlock    doneBlock;
@property (nonatomic,assign) ZXDateStyle  datePickerStyle;
@end

@implementation ZXDatePickerView

-(instancetype)initWithDateStyle:(ZXDateStyle)datePickerStyle scrollToDate:(NSDate *)scrollToDate extPicker:(UIPickerView *)extPicker completeBlock:(CompleteBlock)completeBlock{
    _extPicker = extPicker;
    return [self initWithDateStyle:datePickerStyle scrollToDate:scrollToDate completeBlock:completeBlock];
}

/**
 默认滚动到当前时间
 */
-(instancetype)initWithDateStyle:(ZXDateStyle)datePickerStyle
                   completeBlock:(CompleteBlock)completeBlock {
    return [self initWithDateStyle:datePickerStyle scrollToDate:nil completeBlock:completeBlock];
}

/**
 滚动到指定的的日期
 */
-(instancetype)initWithDateStyle:(ZXDateStyle)datePickerStyle
                    scrollToDate:(NSDate *)scrollToDate
                   completeBlock:(CompleteBlock)completeBlock {
    self = [super init];
    if (self) {
        self.datePickerStyle = datePickerStyle;
        self.scrollToDate = scrollToDate ?: self.forNowDate;
        if(scrollToDate) self.showMode = ZXDateModeAll;
        switch (datePickerStyle) {
            case ZXDateStyleShowYearMonthDayHourMinute:
                _dateFormatter = @"yyyy-MM-dd HH:mm";
                break;
            case ZXDateStyleShowYearMonthDayHour:
                _dateFormatter = @"yyyy-MM-dd HH";
                break;
            case ZXDateStyleShowMonthDayHourMinute:
                _dateFormatter = @"MM-dd HH:mm";
                break;
            case ZXDateStyleShowYearMonthDay:
                _dateFormatter = @"yyyy-MM-dd";
                break;
            case ZXDateStyleShowYearMonth:
                _dateFormatter = @"yyyy-MM";
                break;
            case ZXDateStyleShowMonthDay:
                _dateFormatter = @"yyyy-MM-dd";
                break;
            case ZXDateStyleShowHourMinute:
                _dateFormatter = @"HH:mm";
                break;
            default:
                _dateFormatter = @"yyyy-MM-dd HH:mm";
                break;
        }
        
        [self setupUI];
        [self defaultConfig];
        self.doneBlock = completeBlock;
    }
    return self;
}

-(void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:tap];
    [self addSubview:self.showYearView];
    [self.showYearView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(OFFSET);
        make.trailing.equalTo(self).offset(-OFFSET);
    }];
    [self.showYearView addSubview:self.datePicker];
    [self.showYearView addSubview:self.doneBtn];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@FULL_FARME_HEIGHT);
        make.top.leading.equalTo(self.showYearView);
        make.trailing.equalTo(self.showYearView.mas_trailing).offset(-10);
    }];
    if (_extPicker) {
        [self.showYearView addSubview:self.extPicker];
        [self.extPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.datePicker.mas_bottom);
            make.trailing.leading.equalTo(self.showYearView);
            make.height.equalTo(@EXT_FARME_HEIGHT);
        }];
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.extPicker.mas_bottom);
            make.height.equalTo(@BUTTON_FARME_HEIGHT);
            make.trailing.bottom.leading.equalTo(self.showYearView);
        }];
        [self.showYearView bringSubviewToFront:self.doneBtn];
    }else{
        [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.datePicker.mas_bottom);
            make.height.equalTo(@BUTTON_FARME_HEIGHT);
            make.trailing.bottom.leading.equalTo(self.showYearView);
        }];
    }
}

-(void)defaultConfig {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.alpha = 0.f;
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year - self.minYear) * 12 + self.scrollToDate.month - 1;
    _dateLabelColor =  ZXRemarkColor;
    if(!_showMode)self.showMode = ZXDateModeWithoutPast;

    //滚动限制
    if (!self.maxLimitDate) {
        self.maxLimitDate = [NSDate date:@"2099-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"];
    }
    //最小限制
    if (!self.minLimitDate) {
        self.minLimitDate = [NSDate date:@"1000-01-01 00:00" WithFormat:@"yyyy-MM-dd HH:mm"];
    }
}


- (NSMutableArray *)setArray:(id)mutableArray{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

-(void)setYearLabelColor:(UIColor *)yearLabelColor {
    self.showYearView.textColor = yearLabelColor;
}

- (void)setYearLabelText{
    self.showYearView.text = [NSString stringWithFormat:@"%@",_yearArray[yearIndex]];
}

-(void)addLabelWithName:(NSArray *)nameArr{
    [nameArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelX = (SCREEN_WIDTH - OFFSET * 2) /(nameArr.count * 2) + 18 + (SCREEN_WIDTH - OFFSET * 2)/nameArr.count * idx;
        if([obj isEqualToString:@"年"]) labelX += 5;
        if([obj isEqualToString:@"分"]) labelX -= 5;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelX, FULL_FARME_HEIGHT /2-15/2.0, 15, 15)];
        label.text = obj;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor =  self.dateLabelColor;
        label.backgroundColor = [UIColor clearColor];
        [self.showYearView addSubview:label];
    }];
}


- (void)makeDateData{
    //设置年月日时分数据
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _hourArray = [self setArray:_hourArray];
    _minuteArray = [self setArray:_minuteArray];
    //制作年份
    for (NSInteger i = self.minYear; i<= self.maxYear; i++) {
        NSString *num = [NSString stringWithFormat:@"%ld",(long)i];
        [_yearArray addObject:num];
    }
    //制作其他
    for (NSInteger i = 0; i < 60; i++) {
        NSString *num = [NSString stringWithFormat:@"%02ld",(long)i];
        if (0 < i && i <= 12) [_monthArray addObject:num];
        if (i < 24) [_hourArray addObject:num];
        [_minuteArray addObject:num];
    }
    
    [self getNowDate:self.scrollToDate animated:NO];
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if ([_extPicker isEqual:pickerView]) {
        return 1;
    }
    NSArray *arr;
    switch (self.datePickerStyle) {
        case ZXDateStyleShowYearMonthDayHourMinute:
            arr = @[@"年",@"月",@"日",@"时",@"分"];
            break;
        case ZXDateStyleShowYearMonthDayHour:
            arr = @[@"年",@"月",@"日",@"时"];
            break;
        case ZXDateStyleShowMonthDayHourMinute:
            arr = @[@"月",@"日",@"时",@"分"];
            break;
        case ZXDateStyleShowYearMonthDay:
            arr = @[@"年",@"月",@"日"];
            break;
        case ZXDateStyleShowYearMonth:
            arr = @[@"年",@"月"];
            break;
        case ZXDateStyleShowMonthDay:
            arr = @[@"月",@"日"];
            break;
        case ZXDateStyleShowHourMinute:
            arr = @[@"时",@"分"];
            break;
        default:
            break;
    }
    [self addLabelWithName:arr];
    return arr.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}

-(NSArray *)getNumberOfRowsInComponent {
    NSInteger yearNum = _yearArray.count;
    if(ZXDateStyleShowMonthDayHourMinute == self.datePickerStyle)_yearArray = nil;
    NSInteger monthNum = [self setmonthArray];
    NSInteger dayNum = [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
    NSInteger hourNum = _hourArray.count;
    NSInteger minuteNUm = _minuteArray.count;
    NSInteger timeInterval = self.maxYear - self.minYear;
    
    switch (self.datePickerStyle) {
        case ZXDateStyleShowYearMonthDayHourMinute:
            return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum),@(minuteNUm)];
            break;
        case ZXDateStyleShowYearMonthDayHour:
            return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum)];
            break;
        case ZXDateStyleShowMonthDayHourMinute:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum),@(minuteNUm)];
            break;
        case ZXDateStyleShowYearMonthDay:
            return @[@(yearNum),@(monthNum),@(dayNum)];
            break;
        case ZXDateStyleShowYearMonth:
            return @[@(yearNum),@(monthNum)];
            break;
        case ZXDateStyleShowMonthDay:
            return @[@(monthNum*timeInterval),@(dayNum)];
            break;
        case ZXDateStyleShowHourMinute:
            return @[@(hourNum),@(minuteNUm)];
            break;
        default:
            return @[];
            break;
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view {
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:17]];
    }
    NSString *title;
    
    switch (self.datePickerStyle) {
        case ZXDateStyleShowYearMonthDayHourMinute:
        case ZXDateStyleShowYearMonthDayHour:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            if (component==3) {
                title = _hourArray[row];
            }
            if (component==4) {
                title = _minuteArray[row];
            }
            break;
        case ZXDateStyleShowYearMonthDay:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            break;
        case ZXDateStyleShowYearMonth:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            break;
        case ZXDateStyleShowMonthDayHourMinute:
            if (component==0) {
                title = _monthArray[row%12];
            }
            if (component==1) {
                title = _dayArray[row];
            }
            if (component==2) {
                title = _hourArray[row];
            }
            if (component==3) {
                title = _minuteArray[row];
            }
            break;
        case ZXDateStyleShowMonthDay:
            if (component==0) {
                title = _monthArray[row%12];
            }
            if (component==1) {
                title = _dayArray[row];
            }
            break;
        case ZXDateStyleShowHourMinute:
            if (component==0) {
                title = _hourArray[row];
            }
            if (component==1) {
                title = _minuteArray[row];
            }
            break;
        default:
            title = @"";
            break;
    }

    customLabel.text = title;
    if (!_datePickerColor) {
        _datePickerColor = [UIColor blackColor];
    }
    customLabel.textColor = _datePickerColor;
    return customLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (self.datePickerStyle) {
        case ZXDateStyleShowYearMonthDayHourMinute:
        case ZXDateStyleShowYearMonthDayHour:{
            if (component == 0) {
                yearIndex = row;
                [self setYearLabelText];
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 3) {
                hourIndex = row;
            }
            if (component == 4) {
                minuteIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
                
            }
        }
            break;
        case ZXDateStyleShowYearMonthDay:{
            
            if (component == 0) {
                yearIndex = row;
                [self setYearLabelText];
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
        }
            break;
        case ZXDateStyleShowYearMonth:{
            dayIndex = 0;
            if (component == 0) {
                yearIndex = row;
                [self setYearLabelText];
            }
            if (component == 1) {
                monthIndex = row;
            }
        }
            break;
        case ZXDateStyleShowMonthDayHourMinute:{
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 2) {
                hourIndex = row;
            }
            if (component == 3) {
                minuteIndex = row;
            }
            if (component == 0) {
                [self yearChange:row];
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        }
            break;
        case ZXDateStyleShowMonthDay:{
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 0) {
                
                [self yearChange:row];
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        }
            break;
        case ZXDateStyleShowHourMinute:{
            if (component == 0) {
                hourIndex = row;
            }
            if (component == 1) {
                minuteIndex = row;
            }
        }
            break;
        default:
            break;
    }
    [pickerView reloadAllComponents];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex]];
    
    self.scrollToDate = [[NSDate date:dateStr WithFormat:@"yyyy-MM-dd HH:mm"] dateWithFormatter:_dateFormatter];
    
    if ([self.scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        self.scrollToDate = self.minLimitDate;
        [self getNowDate:self.minLimitDate animated:YES];
    }else if ([self.scrollToDate compare:self.maxLimitDate] == NSOrderedDescending){
        self.scrollToDate = self.maxLimitDate;
        [self getNowDate:self.maxLimitDate animated:YES];
    }
    _startDate = self.scrollToDate;
    ZX_SAFE_SEND_MESSAGE(_delegate, didSelectDate:){
        [_delegate didSelectDate:self.scrollToDate];
    }
}

-(void)yearChange:(NSInteger)row {
    monthIndex = row%12;
    //年份状态变化
    if (row-preRow <12 && row-preRow>0 && [_monthArray[monthIndex] integerValue] < [_monthArray[preRow%12] integerValue]) {
        yearIndex ++;
    } else if(preRow-row <12 && preRow-row > 0 && [_monthArray[monthIndex] integerValue] > [_monthArray[preRow%12] integerValue]) {
        yearIndex --;
    }else {
        NSInteger interval = (row-preRow)/12;
        yearIndex += interval;
    }
    
    [self setYearLabelText];
    preRow = row;
}


#pragma mark - Action
- (void)show {
    [kWindow addSubview:self];
    [UIView animateWithDuration:0.4 delay:0.f usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }];
}

- (void)doneAction:(UIButton *)btn {
    _startDate = [self.scrollToDate dateWithFormatter:_dateFormatter];
    ZX_SAFE_BLOCK(self.doneBlock, _startDate);
    [self dismiss];
}

#pragma mark - tools
//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            return [self setdayArray:31];
        }
        case 4:case 6:case 9:case 11:{
            return [self setdayArray:30];
        }
        case 2:{
            if (isrunNian) {
               return [self setdayArray:29];
            }else{
               return [self setdayArray:28];
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每年月份数
- (NSUInteger)setmonthArray{
    NSInteger month = (_showMode == ZXDateModeWithoutPast) && ([_yearArray[yearIndex] integerValue] == [self forNowDate].year) ? [self forNowDate].month : 1;
    [_monthArray removeAllObjects];
    for (NSInteger i = month; i <= 12; i++) {
        NSString *num = [NSString stringWithFormat:@"%02ld",(long)i];
        [_monthArray addObject:num];
    }
    if(monthIndex >= _monthArray.count) monthIndex = 0;
    return _monthArray.count;
}

//设置每月的天数数组
- (NSUInteger)setdayArray:(NSInteger)num{
    NSInteger day = (_showMode == ZXDateModeWithoutPast) && ([_yearArray[yearIndex] integerValue] == [self forNowDate].year) && ([_monthArray[monthIndex] integerValue] == [self forNowDate].month) ? [self forNowDate].day : 1;
    [_dayArray removeAllObjects];
    for (NSInteger i = day; i<= num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02ld",(long)i]];
    }
    return _dayArray.count;
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated{
    if (!date) {
        date = [NSDate date];
    }
    
    [self DaysfromYear:date.year andMonth:date.month];
    
    yearIndex = date.year - self.minYear;
    monthIndex = date.month - (_showMode == ZXDateModeWithoutPast ? [self forNowDate].month : 1);
    dayIndex = date.day - (_showMode == ZXDateModeWithoutPast ? [self forNowDate].day : 1);
    hourIndex = date.hour;
    minuteIndex = date.minute;
    
    //显示行数
    preRow = (self.scrollToDate.year - self.minYear ) * 12 + self.scrollToDate.month - 1;
    
    NSArray *indexArray;
    
    if (self.datePickerStyle == ZXDateStyleShowYearMonthDayHourMinute)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == ZXDateStyleShowYearMonthDayHour) {
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex)];
    }
    if (self.datePickerStyle == ZXDateStyleShowYearMonthDay)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex)];
    if (self.datePickerStyle == ZXDateStyleShowYearMonth)
        indexArray = @[@(yearIndex),@(monthIndex)];
    if (self.datePickerStyle == ZXDateStyleShowMonthDayHourMinute)
        indexArray = @[@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == ZXDateStyleShowMonthDay)
        indexArray = @[@(monthIndex),@(dayIndex)];
    if (self.datePickerStyle == ZXDateStyleShowHourMinute)
        indexArray = @[@(hourIndex),@(minuteIndex)];
    
    [self setYearLabelText];

    [self.datePicker reloadAllComponents];
    for (int i = 0; i < indexArray.count; i++) {
        if ((self.datePickerStyle == ZXDateStyleShowMonthDayHourMinute || self.datePickerStyle == ZXDateStyleShowMonthDay)&& i==0) {
            NSInteger mIndex = [indexArray[i] integerValue] + ( 12 * (self.scrollToDate.year - self.minYear));
            [self.datePicker selectRow:mIndex inComponent:i animated:animated];
        } else {
            [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        }
        
    }
}


#pragma mark - getter / setter

-(UIPickerView *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] init];
        _datePicker.showsSelectionIndicator = YES;
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc] init];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn setBackgroundColor:ZXBlueColor];
        [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UILabel *)showYearView {
    if (!_showYearView) {
        _showYearView = [[UILabel alloc] init];
        _showYearView.userInteractionEnabled = YES;
        _showYearView.numberOfLines = 0;
        _showYearView.textColor = [UIColor colorUsingHexString:@"#e9edf2"];
        _showYearView.backgroundColor = [UIColor whiteColor];
        _showYearView.font = [UIFont systemFontOfSize:110];
        _showYearView.textAlignment = NSTextAlignmentCenter;
        [_showYearView addShadowWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] radius:2.5 offset:CGSizeMake(0, 3) opacity:0.8 bounds:NO];
    }
    return _showYearView;
}

- (NSUInteger)maxYear{
    return 2099;
}

- (NSUInteger)minYear{
    return _showMode == ZXDateModeWithoutPast ? [self forNowDate].year : 1900;
}

- (NSDate *)forNowDate{
    return [NSDate date];
}

-(void)setMinLimitDate:(NSDate *)minLimitDate {
    _minLimitDate = minLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        _scrollToDate = self.minLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:NO];
}

-(void)setDoneButtonColor:(UIColor *)doneButtonColor {
    _doneButtonColor = doneButtonColor;
    self.doneBtn.backgroundColor = doneButtonColor;
}

-(void)setHideBackgroundYearLabel:(BOOL)hideBackgroundYearLabel {
    _showYearView.textColor = [UIColor clearColor];
}

- (void)setShowMode:(ZXDateMode)showMode{
    _showMode = showMode;
    [self makeDateData];
}

@end
