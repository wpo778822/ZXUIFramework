//
//  ZXPhotoPickerTheme.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 相册选择器的自定义UI类，单例使用
 */
@interface ZXPhotoPickerTheme : NSObject


@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *titleLabelTextColor;

@property (nonatomic, strong) UIColor *navigationBarTintColor;

@property (nonatomic, strong) UIColor *orderTintColor;

@property (nonatomic, strong) UIColor *orderLabelTextColor;

@property (nonatomic, strong) UIColor *cameraVeilColor;

@property (nonatomic, strong) UIColor *cameraIconColor;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, strong) UIFont *titleLabelFont;

@property (nonatomic, strong) UIFont *albumNameLabelFont;

@property (nonatomic, strong) UIFont *photosCountLabelFont;

@property (nonatomic, strong) UIFont *selectionOrderLabelFont;

+ (instancetype)sharedInstance;

- (void)reset;

@end
