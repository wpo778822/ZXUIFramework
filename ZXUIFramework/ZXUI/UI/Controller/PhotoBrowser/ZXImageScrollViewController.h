//
//  ZXImageScrollViewController.h
//  ZXartApp
//
//  Created by Apple on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXImageScrollView;
typedef void(^ZXImageDownloadProgressHandler)(NSInteger receivedSize, NSInteger expectedSize);

@interface ZXImageScrollViewController : UIViewController

@property (nonatomic, assign) NSInteger page;

/**
 返回本地Image
 */
@property (nonatomic, copy) UIImage *(^fetchImageHandler)(void);

/**
 ImageView下载进度
 */
@property (nonatomic, copy) void (^configureImageViewWithDownloadProgressHandler)(UIImageView *imageView, ZXImageDownloadProgressHandler handler);

@property (nonatomic, strong, readonly) ZXImageScrollView *imageScrollView;

- (void)reloadData;

@end
