//
//  ZXPhotoNavigationController.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXPhotoNavigationController.h"

#import "ZXPhotoPickerTheme.h"

@interface ZXPhotoNavigationController ()

@end

@implementation ZXPhotoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [ZXPhotoPickerTheme sharedInstance].statusBarStyle;
}

@end
