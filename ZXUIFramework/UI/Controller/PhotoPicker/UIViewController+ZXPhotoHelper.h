//
//  UIViewController+ZXPhotoHelper.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZXPhotoPickerViewController.h"

/**
 管理调起相册选择器
 */
@interface UIViewController (ZXPhotoHelper)

/**
 调起摄像头界面

 @param delegate UIImagePickerController delegate
 */
- (void)zx_presentCameraCaptureViewWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;

/**
 调起相册选择器（默认选择单张）

 @param delegate zxPhotoPickerViewController delegate
 */
- (void)zx_presentAlbumPhotoViewWithDelegate:(id<ZXPhotoPickerViewControllerDelegate>)delegate;

/**
 调起外部传入相册选择器

 @param pickerViewController zxPhotoPickerViewController init
 @param delegate zxPhotoPickerViewController delegate
 */
- (void)zx_presentCustomAlbumPhotoView:(ZXPhotoPickerViewController *)pickerViewController delegate:(id<ZXPhotoPickerViewControllerDelegate>)delegate;

@end
