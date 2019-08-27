//
//  ZXPhotoPickerTheme.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXPhotoPickerTheme.h"

@implementation UIColor (ZXPhotoPickerTheme)

+ (UIColor *)systemBlueColor{
    static UIColor *systemBlueColor = nil;
    if (!systemBlueColor) {
        systemBlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    return systemBlueColor;
}

@end

@implementation ZXPhotoPickerTheme

+ (instancetype)sharedInstance{
    static ZXPhotoPickerTheme *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZXPhotoPickerTheme alloc] init];
        [instance reset];
    });
    return instance;
}

- (void)reset{
    self.tintColor = self.orderTintColor = self.cameraVeilColor = [UIColor systemBlueColor];
    self.orderLabelTextColor = self.navigationBarTintColor = self.cameraIconColor = [UIColor whiteColor];
    self.titleLabelTextColor = [UIColor blackColor];
    self.statusBarStyle = UIStatusBarStyleDefault;
    self.titleLabelFont = [UIFont systemFontOfSize:18.0];
    self.albumNameLabelFont = [UIFont italicSystemFontOfSize:18];
    self.photosCountLabelFont = [UIFont systemFontOfSize:18];
    self.selectionOrderLabelFont = [UIFont systemFontOfSize:17.0];
}

@end
