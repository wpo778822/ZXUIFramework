//
//  ZXSwitchView.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ZXSwitchViewLabelPosition){
    ZXSwitchViewLabelPositionLeft = 0,
    ZXSwitchViewLabelPositionRight,
};

@interface ZXSwitchView : UIView

@property (strong, nonatomic) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *labelColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *labelFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSString *labelText UI_APPEARANCE_SELECTOR;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, assign) CGFloat switchScale;
@property (nonatomic, assign) ZXSwitchViewLabelPosition labelPosition;
@end
