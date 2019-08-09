//
//  ZXPhotoBrowserViewController.h
//  ZXartApp
//
//  Created by Apple on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class ZXPhotoBrowserViewController;

#pragma mark - ZXPhotoBrowserViewControllerDataSource

@protocol ZXPhotoBrowserViewControllerDataSource <NSObject>

/**
 图片显示数量
 */
- (NSInteger)numberOfPagesInViewController:(ZXPhotoBrowserViewController *)viewController;

@optional

/**
 本地图片
 */
- (nullable UIImage *)viewController:(ZXPhotoBrowserViewController *)viewController imageForPageAtIndex:(NSInteger)index;
/**
 网络获取图片
 */
- (void)viewController:(ZXPhotoBrowserViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger receivedSize, NSInteger expectedSize))progressHandler;
/**
 返回位置(实际视图提供)
 */
- (nullable UIView *)thumbViewForPageAtIndex:(NSInteger)index viewController:(ZXPhotoBrowserViewController *)viewController;

/**
 返回infoText(实际视图提供)
 */
- (nullable NSString *)infoTextForPageAtIndex:(NSInteger)index viewController:(ZXPhotoBrowserViewController *)viewController;
@end

#pragma mark - ZXPhotoBrowserViewControllerDelegate

@protocol ZXPhotoBrowserViewControllerDelegate <NSObject>

@optional

/**
 单击
 */
- (void)viewController:(ZXPhotoBrowserViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage;


/**
 长按
 */
- (void)viewController:(ZXPhotoBrowserViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage;

/**
 didmiss
 */
- (void)viewController:(ZXPhotoBrowserViewController *)viewController didDisMissAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage;


/**
 willmiss
 */
- (void)viewController:(ZXPhotoBrowserViewController *)viewController willDisMissAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage;

@end


#pragma mark - ZXPhotoBrowserViewController

@interface ZXPhotoBrowserViewController : UIPageViewController

@property (nonatomic, weak) id<ZXPhotoBrowserViewControllerDataSource> zxDataSource;
@property (nonatomic, weak) id<ZXPhotoBrowserViewControllerDelegate> zxDelegate;

/**
 初始位置
 */
@property (nonatomic, assign) NSInteger startPage;
@property (nonatomic, assign) BOOL isNeedAlpha;
@property (nonatomic, assign, readonly) NSInteger numberOfPages;
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, weak) UIView *currentThumbView;

@property (nonatomic, copy) NSString *ID;

/**
 重载（至1）
 */
- (void)reload;

/**
 重载指定
 */
- (void)reloadWithCurrentPage:(NSInteger)index;

/**
 更新数量
 */
- (void)refreshPageNumber;

/**
 是否启用磨砂背景 Default is YES
 */
@property (nonatomic, assign , getter=isBlurBackgroundShowing) BOOL isShowBlurBackground;

/**
 返回视图原隐藏 Default is YES
 */
@property (nonatomic, assign , getter=isThumbViewHidden) BOOL isHiddenThumbView;

@end
NS_ASSUME_NONNULL_END
