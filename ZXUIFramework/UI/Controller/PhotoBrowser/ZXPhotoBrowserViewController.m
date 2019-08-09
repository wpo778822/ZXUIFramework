//
//  ZXPhotoBrowserViewController.m
//  ZXartApp
//
//  Created by Apple on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//
#import "ZXPhotoBrowserViewController.h"
#import "ZXImageScrollViewController.h"
#import "ZXImageScrollView.h"
#import "ZXImageScrollView+internal.h"
#import "ZXPresentAnimatedTransitioningController.h"
#import <Masonry.h>

#define WeakSelf(weakSelf) __weak __typeof(&*self)weakSelf = self;
static const NSUInteger reusable_page_count = 3;

@interface ZXPhotoBrowserViewController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    UIViewControllerTransitioningDelegate
>

@property (nonatomic, strong) NSArray<ZXImageScrollViewController *> *reusableImageScrollerViewControllers;
@property (nonatomic, assign ,readwrite) NSInteger numberOfPages;
@property (nonatomic, assign ,readwrite) NSInteger currentPage;

/**
 指示器引用 (二选一)
 */
@property (nonatomic, weak) UIView *indicator;
/**
 count > 9
 */
@property (nonatomic, strong) UILabel *indicatorLabel;
/**
 count <= 9
 */
@property (nonatomic, strong) UIPageControl *indicatorPageControl;

/**
 配图文字
 */
@property (nonatomic, strong) UILabel *infoTextLabel;

/**
 背景视图
 */
@property (nonatomic, strong) UIView *blurBackgroundView;

/**
 手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;


/**
 转场
 */
@property (nonatomic, strong) ZXPresentAnimatedTransitioningController *transitioningController;

@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, weak) UIView *lastThumbView;

@end

@implementation ZXPhotoBrowserViewController

- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

#pragma mark - respondsToSelector

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary *)options {
    NSMutableDictionary *dict = [(options ?: @{}) mutableCopy];
    [dict setObject:@(20) forKey:UIPageViewControllerOptionInterPageSpacingKey];
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:navigationOrientation
                                  options:dict];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        self.transitioningDelegate  = self;
        _isShowBlurBackground       = YES;
        _isHiddenThumbView          = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setNumberOfPages];
    [self _setCurrentPresentPageAnimated: NO];
    [self _addIndicator];
    [self _addInfoTextLabel];
    [self _addBlurBackgroundView];
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self _setupTransitioningController];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self _updateIndicator];
    [self _updateInfoText];
    [self _updateBlurBackgroundView];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)deviceOrientationDidChange{
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
            [self orientationChange:UIInterfaceOrientationPortrait];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            [self orientationChange:UIInterfaceOrientationLandscapeLeft];
            break;
        case UIDeviceOrientationLandscapeRight:
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            [self orientationChange:UIInterfaceOrientationLandscapeRight];
            break;
        default:
            break;
    }
}

- (void)orientationChange:(UIInterfaceOrientation)landscape{
    CGFloat rotation = 0.f;
    switch (landscape) {
        case UIInterfaceOrientationPortrait:{
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:{
            rotation = M_PI_2;
            break;
        }
        case UIInterfaceOrientationLandscapeRight:{
            rotation = - M_PI_2;
            break;
        }
        default:
            return;
            break;
    }
    WeakSelf(weakSelf)
    [UIView animateWithDuration:0.3f animations:^{
        self.view.transform = CGAffineTransformMakeRotation(rotation);
        self.view.bounds = [UIScreen mainScreen].bounds;
        [weakSelf.reusableImageScrollerViewControllers enumerateObjectsUsingBlock:^(ZXImageScrollViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZXImageScrollView *imageScrollView = obj.imageScrollView;
            [imageScrollView _updateUserInterfaces];
        }];
    }];
}

#pragma mark - Nontification
- (void)verticalScreen {
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    [self orientationChange:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Public method
-(void)setStartPage:(NSInteger)startPage{
    _startPage   = startPage;
    _currentPage = startPage;
}

- (void)reload {
    [self reloadWithCurrentPage:0];
}

- (void)reloadWithCurrentPage:(NSInteger)index {
    self.startPage = index;
    [self _setNumberOfPages];
    NSAssert(index < _numberOfPages, @"index(%@) beyond boundary.", @(index));
    [self _setCurrentPresentPageAnimated: YES];
    [self _updateIndicator];
    [self _updateBlurBackgroundView];
    [self _updateInfoText];
    [self _hideThumbView];
}

- (void)refreshPageNumber{
    [self _setNumberOfPages];
    [self _updateIndicator];
}

#pragma mark - Private methods

- (void)_setNumberOfPages { 
    if ([self.zxDataSource conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDataSource)] &&
        [self.zxDataSource respondsToSelector:@selector(numberOfPagesInViewController:)]) {
        self.numberOfPages = [self.zxDataSource numberOfPagesInViewController:self];
    }
}

- (void)_setCurrentPresentPageAnimated:(BOOL)animated {
    self.currentPage = 0 < self.currentPage && self.currentPage < self.numberOfPages ? self.currentPage : 0;
    ZXImageScrollViewController *firstImageScrollerViewController = [self _imageScrollerViewControllerForPage:self.currentPage];
    if (firstImageScrollerViewController) {
        [self setViewControllers:@[firstImageScrollerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
    }
//    [firstImageScrollerViewController reloadData];
}

- (void)_addInfoTextLabel{
    [self.view addSubview:self.infoTextLabel];
    [self.infoTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-40);
    }];

}
- (void)_addIndicator {
    if (self.numberOfPages == 1) {
        return;
    }
    if (self.numberOfPages <= 9) {
        [self.view addSubview:self.indicatorPageControl];
        self.indicator = self.indicatorPageControl;
    } else {
        [self.view addSubview:self.indicatorLabel];
        self.indicator = self.indicatorLabel;
    }
    self.indicator.layer.zPosition = 1024;
}

- (void)_updateIndicator {
    if (!self.indicator) {
        return;
    }
    if (self.indicator == _indicatorPageControl && self.numberOfPages > 9) {
        [_indicatorPageControl removeFromSuperview];
        _indicatorPageControl = nil;
        [self _addIndicator];
    }
    if (self.numberOfPages <= 9) {
        self.indicatorPageControl.numberOfPages = self.numberOfPages;
        self.indicatorPageControl.currentPage = self.currentPage;
        [self.indicatorPageControl sizeToFit];
        self.indicatorPageControl.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0f,
                                                       CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorPageControl.bounds) / 2.0f);
    } else {
        NSString *indicatorText = [NSString stringWithFormat:@"%@/%@", @(self.currentPage + 1), @(self.numberOfPages)];
        self.indicatorLabel.text = indicatorText;
        [self.indicatorLabel sizeToFit];
        self.indicatorLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0f,
                                                 CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorLabel.bounds));
    }
}

- (void)_updateInfoText {
    self.infoTextLabel.text = self.infoText;
}

- (void)_addBlurBackgroundView {
    [self.view addSubview:self.blurBackgroundView];
    [self.view sendSubviewToBack:self.blurBackgroundView];
    [self.blurBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self.view);
    }];

}

- (void)_updateBlurBackgroundView {
    self.blurBackgroundView.frame = self.view.bounds;
}

- (void)_hideStatusBarIfNeeded {
    self.presentingViewController.view.window.windowLevel = UIWindowLevelStatusBar;
}

- (void)_showStatusBarIfNeeded {
    self.presentingViewController.view.window.windowLevel = UIWindowLevelNormal;
}

- (ZXImageScrollViewController *)_imageScrollerViewControllerForPage:(NSInteger)page {
    if (page > self.numberOfPages - 1 || page < 0) {
        return nil;
    }
    ZXImageScrollViewController *imageScrollerViewController = self.reusableImageScrollerViewControllers[page % reusable_page_count];
    
    __weak typeof(self) weak_self = self;
    if (self.zxDataSource && [self.zxDataSource conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDataSource)]) {
        imageScrollerViewController.page = page;
        if ([self.zxDataSource respondsToSelector:@selector(viewController:imageForPageAtIndex:)]) {
            imageScrollerViewController.fetchImageHandler = ^UIImage *(void) {
                __strong typeof(weak_self) strong_self = weak_self;
                    return [strong_self.zxDataSource viewController:strong_self imageForPageAtIndex:page];
                return nil;
            };
        } else if ([self.zxDataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:progressHandler:)]) {
            imageScrollerViewController.configureImageViewWithDownloadProgressHandler = ^(UIImageView *imageView, ZXImageDownloadProgressHandler handler) {
                __strong typeof(weak_self) strong_self = weak_self;
                [strong_self.zxDataSource viewController:strong_self presentImageView:imageView forPageAtIndex:page progressHandler:handler];
            };
        }
    }
    return imageScrollerViewController;
}

- (void)_setupTransitioningController {
    __weak typeof(self) weak_self = self;
    self.transitioningController.willPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _willPresent];
    };
    self.transitioningController.onPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _onPresent];
    };
    self.transitioningController.didPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _didPresented];
    };
    self.transitioningController.willDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _willDismiss];
    };
    self.transitioningController.onDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _onDismiss];
    };
    self.transitioningController.didDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _didDismiss];
    };
}

- (void)_willPresent {
    ZXImageScrollViewController *currentScrollViewController = self.currentScrollViewController;
    currentScrollViewController.view.alpha = 0.f;
    self.blurBackgroundView.alpha = 0.f;
    UIView *thumbView = self.currentThumbView;
    if (!thumbView) {
        return;
    }
    [self _hideThumbView];

    currentScrollViewController.view.alpha = 1.f;
    ZXImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    self.originFrame = imageView.frame;
    CGRect frame = [thumbView.superview convertRect:thumbView.frame toView:self.view];
    imageView.frame           = frame;
    imageView.backgroundColor = thumbView.backgroundColor;
    imageView.clipsToBounds   = thumbView.clipsToBounds;
    imageView.contentMode     = thumbView.contentMode;
}

- (void)_onPresent {
    ZXImageScrollViewController *currentScrollViewController = self.currentScrollViewController;
    self.blurBackgroundView.alpha = 1;
    [self _hideStatusBarIfNeeded];
    
    if (!self.currentThumbView) {
        currentScrollViewController.view.alpha = 1;
        return;
    }
    
    ZXImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    CGRect originFrame = [imageView.superview convertRect:imageView.frame toView:self.view];
    
    if (CGRectEqualToRect(originFrame, CGRectZero)) {
        currentScrollViewController.view.alpha = 1;
        return;
    }
    imageView.frame = self.originFrame;
}

- (void)_didPresented {
    self.currentScrollViewController.view.alpha = 1;
    self.currentScrollViewController.imageScrollView.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self.currentScrollViewController reloadData];
    [self _hideIndicator];
}

- (void)_willDismiss {
    ZXImageScrollViewController *currentScrollViewController = self.currentScrollViewController;
    ZXImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    // 还原 zoom.
    if (imageScrollView.zoomScale != 1) {
        [imageScrollView setZoomScale:1 animated:YES];
    }
    // 停止播放动画
    NSArray<UIImage *> *images = imageScrollView.imageView.image.images;
    if (images && images.count > 1) {
        UIImage *newImage = images.firstObject;
        imageScrollView.imageView.image = nil;
        imageScrollView.imageView.image = newImage;
    }
    // 清除文字
    _infoTextLabel.text = @"";
    
    if (self.zxDelegate && [self.zxDelegate conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDelegate)]) {
        if ([self.zxDelegate respondsToSelector:@selector(viewController:willDisMissAtIndex:presentedImage:)]) {
            [self.zxDelegate viewController:self willDisMissAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
    if (_isNeedAlpha) {
        UIView *thumbView = self.currentThumbView;
        if (thumbView) {
            thumbView.hidden = NO;
            thumbView.alpha = 0;
        }
    }
}

- (void)_onDismiss {
    [self _showStatusBarIfNeeded];
    self.blurBackgroundView.alpha = 0;
    
    ZXImageScrollViewController *currentScrollViewController = self.currentScrollViewController;
    ZXImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    UIImage *currentImage = imageView.image;
    // 图片未加载，默认 CrossDissolve 动画。
    if (!currentImage) {
        return;
    }
    // present 之前显示的图片视图。
    UIView *thumbView = self.currentThumbView;
    CGRect destFrame = CGRectZero;
    if (thumbView) {
        // 还原到起始位置然后 dismiss.
        destFrame = [thumbView.superview convertRect:thumbView.frame toView:imageScrollView];
        imageView.layer.contentsRect          = CGRectMake(0, 0, 1, 1);
        imageView.clipsToBounds               = thumbView.clipsToBounds;
        imageView.backgroundColor             = thumbView.backgroundColor;
        imageView.contentMode                 = thumbView.contentMode;
        imageView.frame                       = destFrame;
        imageView.layer.masksToBounds = thumbView.layer.masksToBounds;
        imageView.layer.cornerRadius  = thumbView.layer.cornerRadius;
        if (_isNeedAlpha) {
            imageView.alpha = 0;
            thumbView.alpha = 1;
        }
    }else {
        imageView.alpha = 0;
    }
}

- (void)_didDismiss {
    self.currentThumbView.hidden = NO;
    self.currentScrollViewController.imageScrollView.imageView.layer.anchorPoint = CGPointMake(0.5, 0);
    if (self.zxDelegate && [self.zxDelegate conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDelegate)]) {
        if ([self.zxDelegate respondsToSelector:@selector(viewController:didDisMissAtIndex:presentedImage:)]) {
            [self.zxDelegate viewController:self didDisMissAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
}

- (void)_hideIndicator {
    if (!self.indicator || 0.f == self.indicator.alpha) {
        return;
    }
    [UIView animateWithDuration:0.25 delay:1.f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.indicator.alpha = 0.f;
        self.infoTextLabel.alpha = 0.f;
    } completion:^(BOOL finished) {
    }];
}

- (void)_showIndicator {
    if (!self.indicator || 1.f == self.indicator.alpha) {
        return;
    }
    [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.indicator.alpha = 1.f;
        self.infoTextLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}


- (void)_hideThumbView {
    if (!_isHiddenThumbView) {
        return;
    }
    NSLog(@"%s", __FUNCTION__);
    self.lastThumbView.hidden = NO;
    UIView *currentThumbView = self.currentThumbView;
    currentThumbView.hidden = YES;
    self.lastThumbView = currentThumbView;
}

#pragma mark - Actions

- (void)_handleSingleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    [self verticalScreen];
    if (self.zxDelegate && [self.zxDelegate conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDelegate)]) {
        if ([self.zxDelegate respondsToSelector:@selector(viewController:didSingleTapedPageAtIndex:presentedImage:)]) {
            [self.zxDelegate viewController:self didSingleTapedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
}

- (void)_handleDoubleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint location = [sender locationInView:self.view];
    ZXImageScrollView *imageScrollView = self.currentScrollViewController.imageScrollView;
    [imageScrollView _handleZoomForLocation:location];
}

- (void)_handleLongPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.zxDelegate && [self.zxDelegate conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDelegate)]) {
            if ([self.zxDelegate respondsToSelector:@selector(viewController:didLongPressedPageAtIndex:presentedImage:)]) {
                [self.zxDelegate viewController:self didLongPressedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
            }
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ZXImageScrollViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ZXImageScrollViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page + 1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    [self _showIndicator];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    ZXImageScrollViewController *imageScrollerViewController = pageViewController.viewControllers.firstObject;
    self.currentPage = imageScrollerViewController.page;
    [self _updateIndicator];
    [self _updateInfoText];
    [self _hideIndicator];
    [self _hideThumbView];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [self.transitioningController prepareForPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self.transitioningController prepareForDismiss];
}

#pragma mark - Accessor

- (NSArray<ZXImageScrollViewController *> *)reusableImageScrollerViewControllers {
    if (!_reusableImageScrollerViewControllers) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:MIN(self.numberOfPages,reusable_page_count)];
        for (NSInteger index = 0; index < MAX(1, MIN(self.numberOfPages,reusable_page_count)); index++) {
            ZXImageScrollViewController *imageScrollerViewController = [ZXImageScrollViewController new];
            imageScrollerViewController.page = index;
            __weak typeof(self) weak_self = self;
            imageScrollerViewController.imageScrollView.contentOffSetVerticalPercentHandler = ^(CGFloat percent) {
                __strong typeof(weak_self) strong_self = weak_self;
                CGFloat alpha = 1.0f - percent * 4;
                if (alpha < 0) {
                    alpha = 0;
                }
                strong_self.blurBackgroundView.alpha = alpha;
            };
            imageScrollerViewController.imageScrollView.didEndDraggingInProperpositionHandler = ^(CGFloat velocity){
                __strong typeof(weak_self) strong_self = weak_self;
                strong_self.velocity = velocity;
                [strong_self verticalScreen];
                [strong_self dismissViewControllerAnimated:YES completion:nil];
            };
            [controllers addObject:imageScrollerViewController];
        }
        _reusableImageScrollerViewControllers = [[NSArray alloc] initWithArray:controllers];
    }
    return _reusableImageScrollerViewControllers;
}

- (UILabel *)indicatorLabel {
    if (!_indicatorLabel) {
        _indicatorLabel = [UILabel new];
        _indicatorLabel.font          = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _indicatorLabel.textAlignment = NSTextAlignmentCenter;
        _indicatorLabel.textColor     = [UIColor whiteColor];
    }
    return _indicatorLabel;
}

- (UILabel *)infoTextLabel{
    if (!_infoTextLabel) {
        _infoTextLabel = [UILabel new];
        _infoTextLabel.font          = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _infoTextLabel.textAlignment = NSTextAlignmentLeft;
        _infoTextLabel.numberOfLines = 0;
        _infoTextLabel.textColor     = [UIColor whiteColor];
    }
    return _infoTextLabel;
}

- (UIPageControl *)indicatorPageControl {
    if (!_indicatorPageControl) {
        _indicatorPageControl = [UIPageControl new];
        _indicatorPageControl.numberOfPages = self.numberOfPages;
        _indicatorPageControl.currentPage   = self.currentPage;
    }
    return _indicatorPageControl;
}

- (UIView *)blurBackgroundView {
    if (self.isShowBlurBackground) {
        if (!_blurBackgroundView) {
            _blurBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            _blurBackgroundView.clipsToBounds          = YES;
            _blurBackgroundView.userInteractionEnabled = NO;
        }
    } else {
        if (!_blurBackgroundView) {
            _blurBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            _blurBackgroundView.backgroundColor        = [UIColor blackColor];
            _blurBackgroundView.clipsToBounds          = YES;
            _blurBackgroundView.userInteractionEnabled = NO;
        }
    }
    return _blurBackgroundView;
}

- (UITapGestureRecognizer *)singleTapGestureRecognizer {
    if (!_singleTapGestureRecognizer) {
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTapAction:)];
    }
    return _singleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTapAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressAction:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.5;
    }
    return _longPressGestureRecognizer;
}

- (ZXImageScrollViewController *)currentScrollViewController {
    return self.reusableImageScrollerViewControllers[self.currentPage % reusable_page_count];
}

- (UIView *)currentThumbView {
    if (_currentThumbView) {
        return _currentThumbView;
    }
    if (!self.zxDataSource) {
        return nil;
    }
    if (![self.zxDataSource conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDataSource)]) {
        return nil;
    }
    if (![self.zxDataSource respondsToSelector:@selector(thumbViewForPageAtIndex:viewController:)]) {
        _isHiddenThumbView = NO;
        return nil;
    }
    return [self.zxDataSource thumbViewForPageAtIndex:self.currentPage viewController:self];
}

- (NSString *)infoText{
    if (!self.zxDataSource) {
        return nil;
    }
    if (![self.zxDataSource conformsToProtocol:@protocol(ZXPhotoBrowserViewControllerDataSource)]) {
        return nil;
    }
    if (![self.zxDataSource respondsToSelector:@selector(infoTextForPageAtIndex:viewController:)]) {
        return nil;
    }
    return [self.zxDataSource infoTextForPageAtIndex:self.currentPage viewController:self];
}

- (ZXPresentAnimatedTransitioningController *)transitioningController {
    if (!_transitioningController) {
        _transitioningController = [ZXPresentAnimatedTransitioningController new];
    }
    return _transitioningController;
}


@end
