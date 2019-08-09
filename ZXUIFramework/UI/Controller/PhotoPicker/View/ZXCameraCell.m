//
//  ZXCameraCell.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXCameraCell.h"

#import "ZXPhotoPickerTheme.h"

@interface ZXCameraCell()

@property (nonatomic, weak) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, weak) IBOutlet UIView *captureVeilView;
@property (nonatomic, weak) IBOutlet UIImageView *cameraImageView;

@end

@implementation ZXCameraCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.captureVeilView.backgroundColor = [ZXPhotoPickerTheme sharedInstance].cameraVeilColor;
    self.cameraImageView.image = [self.cameraImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cameraImageView.tintColor = [ZXPhotoPickerTheme sharedInstance].cameraIconColor;
}


@end
