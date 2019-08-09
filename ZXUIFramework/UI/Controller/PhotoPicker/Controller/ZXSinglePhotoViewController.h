//
//  ZXSinglePhotoViewController.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

/**
 单图预览
 */
@interface ZXSinglePhotoViewController : UIViewController

/**
 实例化

 @param asset 图片资源对象
 @param manager 图片管理对象
 @param dismissalHandler 点击回调
 @return self
 */
- (instancetype)initWithPhotoAsset:(PHAsset *)asset
                      imageManager:(PHImageManager *)manager
                  dismissalHandler:(void (^)(BOOL selected))dismissalHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
