//
//  ZXPhotoPickerViewController.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

#import "ZXPhotoPickerTheme.h"

@protocol ZXPhotoPickerViewControllerDelegate;

/**
 相册选择器：配合UIViewController+ZXPhotoHelper.h弹出视图与控制权限
 */
@interface ZXPhotoPickerViewController : UICollectionViewController

/**
 权限通知与完成选择代理
 */
@property (nonatomic, weak) id<ZXPhotoPickerViewControllerDelegate> delegate;


/**
 图片选择数量（默认1）
 */
@property (nonatomic, assign) NSUInteger numberOfPhotoToSelect;

/**
 UI主题（ZXPhotoPickerTheme sharedInstance）
 */
@property (nonatomic, readonly) ZXPhotoPickerTheme *theme;


/**
 控制选择单图代理返回（默认YES）
 YES：调用didFinishPickingImage返回UIImage对象
 NO：调用didFinishPickingImages返回PHAsset对象数组（元素1）
 */
@property (nonatomic, assign) BOOL shouldReturnImageForSingleSelection;


/**
 控制器标识
 */
@property (nonatomic, copy) NSString *mark;

@end


@protocol ZXPhotoPickerViewControllerDelegate <NSObject>

@required
/**
 获取相册权限失败反馈

 @param picker self
 */
- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(ZXPhotoPickerViewController *)picker;

/**
 获取摄像头权限失败反馈
 
 @param picker self
 */
- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(ZXPhotoPickerViewController *)picker;

@optional

/**
 相机或单张选择返回
 该方法不会dismiss自身，调用者自行处理
 @param picker self
 @param image 选中图片UIImage对象
 */
- (void)photoPickerViewController:(ZXPhotoPickerViewController *)picker didFinishPickingImage:(UIImage *)image;

/**
 相册返回大于等于一张图像信息数组
 该方法不会dismiss自身，调用者自行处理
 @param picker self
 @param photoAssets 选择的图片资源PHAsset的数组
 */
- (void)photoPickerViewController:(ZXPhotoPickerViewController *)picker didFinishPickingImages:(NSArray<PHAsset*> *)photoAssets;


/**
 取消按钮响应
 该方法会dismiss自身
 @param picker self
 */
- (void)photoPickerViewControllerDidCancel:(ZXPhotoPickerViewController *)picker;

@end
