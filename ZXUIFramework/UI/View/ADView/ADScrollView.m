
//
//  ADScrollView.m
//  unlimitedADScrollViews
//
//  Created by mac  on 2016/11/22.
//  Copyright © 2016年 mac . All rights reserved.
//
#import "ADScrollView.h"
#import <Masonry.h>
#define kScrollRateTime 3.0
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
@interface ADScrollView () <UIScrollViewDelegate>
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (strong , nonatomic) YYAnimatedImageView   *leftImageView;
@property (strong , nonatomic) YYAnimatedImageView   *rightImageView;
@property (strong , nonatomic) UIView *pageControl;
@property (strong , nonatomic) NSTimer       *timer;
@property (assign , nonatomic) NSInteger     totalADCounts;
@property (nonatomic, strong) UIImage *placeHolderImgae;
@property (nonatomic, assign) BOOL isConfigureImage;
@end
@implementation ADScrollView
- (instancetype)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.placeHolderImage = [UIImage imageNamed:@"banner_chongxinjiazai" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil];
        _isNormalPageControl = YES;
        [self configureViews];
        [self configureImageViews];
        [self addNotification];
        _isAutomaticScroll = YES;
        self.isLoopScroll = YES;
        self.isLoopShell  = NO;
        self.isConfigureImage = NO;
    }
    return self;
}
- (void)dealloc {
    [self releaseTimer];
    [self releaseNotification];
}
#pragma mark - Respones Events
- (void)searchViewSelected:(UITapGestureRecognizer *)recognizer {
    if ([_delegate respondsToSelector:@selector(didSelectedWhichAD:adScrollView:)] && (_totalADCounts > 0)) {
        [_delegate didSelectedWhichAD:_currentIndex adScrollView:self];
    }else if ([_delegate respondsToSelector:@selector(reloadADdata:)] && (_totalADCounts == 0)){
        [_delegate reloadADdata:self];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //重新加载图片
    [self updateImagesWhenScrolled];
    //移动到中间
    [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    //设置分页
    [self upPageControl];
    if ([_delegate respondsToSelector:@selector(didEndDeceleratingWhichAD:adScrollView:)]) {
        [_delegate didEndDeceleratingWhichAD:_currentIndex adScrollView:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_totalADCounts > 0)[self pauseTime];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_totalADCounts > 0)[self resumeTime];
}
#pragma mark - Private Method
#pragma mark - NSTimer Method
- (void)setUpTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kScrollRateTime
                                                  target:self
                                                selector:@selector(switchpics)
                                                userInfo:nil
                                                 repeats:YES];
        // 让NSTimer在tableView滚动中可以正常使用
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
// 暂停NSTimer
- (void)pauseTime {
    [self.timer setFireDate:[NSDate distantFuture]];
}
// 继续NSTimer
- (void)resumeTime {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kScrollRateTime]];
}
// 释放NSTimer
- (void)releaseTimer {
    [self.timer invalidate];
    _timer = nil;
}
#pragma mark - Nontification
- (void)addNotification {
    // 监听应用进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveToBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // 监听应用进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(APPBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}
- (void)releaseNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}
#pragma mark - Application Notification
// 进入后台调用的方法
- (void)moveToBackground:(NSNotification *)notification {
    [_timer setFireDate:[NSDate distantFuture]];
}
// 进入前台的方法
- (void)APPBecomeActive:(NSNotification *)notification {
    [_timer setFireDate:[NSDate date]];
}
// 滚动设置
- (void)switchpics {
    __weak typeof(self) selfWeak = self;
    if (_currentIndex == _totalADCounts - 1 && !_isLoopScroll) {
        return;
    }
    [UIView animateWithDuration:1.0 animations:^{
        selfWeak.scrollView.contentOffset = CGPointMake(selfWeak.frame.size.width * 2, 0);
    }completion:^(BOOL finished) {
        // 重新加载图片
        [selfWeak updateImagesWhenScrolled];
        // 移动到中间
        [selfWeak.scrollView setContentOffset:CGPointMake(selfWeak.frame.size.width, 0)];
        [selfWeak upPageControl];
    }];
}
// 根据滚动设置图片
- (void)updateImagesWhenScrolled{
    NSInteger leftIndex;
    NSInteger rightIndex;
    _totalADCounts == 0 ? _totalADCounts = [_ADArray count] : _totalADCounts;
    if (_totalADCounts == 0) return;
    if (_scrollView.contentOffset.x == self.frame.size.width && _isConfigureImage) {
        return;
    }
    if (_scrollView.contentOffset.x > self.frame.size.width) {
        // 向右滑动
        _currentIndex = (_currentIndex + 1) % _totalADCounts;
    }else if (_scrollView.contentOffset.x < self.frame.size.width) {
        // 向左滑动
        _currentIndex = (_currentIndex + _totalADCounts - 1) % _totalADCounts;
    }
    leftIndex  = (_currentIndex + _totalADCounts - 1) % _totalADCounts;
    rightIndex = (_currentIndex + 1) % _totalADCounts;
    
    if ([self.ADArray[leftIndex] isKindOfClass:[NSString class]] && ![self.ADArray[leftIndex] hasPrefix:@"http"]) {
        _leftImageView.image = self.ADArray[leftIndex];
    }else{
        [_leftImageView yy_setImageWithURL:self.ADArray[leftIndex] placeholder:_placeHolderImgae];
    }

    if ([self.ADArray[_currentIndex] isKindOfClass:[NSString class]] && ![self.ADArray[_currentIndex] hasPrefix:@"http"]) {
        _centerImageView.image = self.ADArray[_currentIndex];
    }else{
        __weak __typeof(&*self)weakSelf = self;
        [_centerImageView yy_setImageWithURL:self.ADArray[_currentIndex] placeholder:_placeHolderImgae options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if(weakSelf.isAutomaticScroll) [weakSelf pauseTime];
            CGFloat progress = (receivedSize * 1.0f) / (expectedSize * 1.0f);
            weakSelf.progressLayer.hidden = NO;
            weakSelf.progressLayer.strokeEnd = progress;
        } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if(weakSelf.isAutomaticScroll) [weakSelf resumeTime];
            weakSelf.progressLayer.hidden = YES;
        }];
    }
    if ([self.ADArray[rightIndex] isKindOfClass:[NSString class]] && ![self.ADArray[rightIndex] hasPrefix:@"http"]) {
        _rightImageView.image = self.ADArray[rightIndex];
    }else{
        [_rightImageView yy_setImageWithURL:self.ADArray[rightIndex] placeholder:_placeHolderImgae];
    }
    _isConfigureImage = YES;
}

- (void)setPageControl {
    __weak __typeof(&*self)weakSelf = self;
    if (!_isShowPageControl) return;
    if (_isNormalPageControl) {
        [_pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(weakSelf.mas_leading);
            make.trailing.equalTo(weakSelf.mas_trailing);
            make.bottom.equalTo(weakSelf.mas_bottom).offset(-5.0);
        }];
    }else{
        [_pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf);
            make.leading.equalTo(weakSelf.mas_leading).offset((weakSelf.currentIndex / (CGFloat)weakSelf.totalADCounts) * SCREEN_WIDTH);
            make.width.equalTo(@((1.f / weakSelf.totalADCounts) * SCREEN_WIDTH));
            make.height.equalTo(@2.f);
        }];
    }
}

- (void)upPageControl{
    __weak __typeof(&*self)weakSelf = self;
    if (!_isShowPageControl) return;
    if (_isNormalPageControl) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = _currentIndex;
    }else{
        [_pageControl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(weakSelf.mas_leading).offset((weakSelf.currentIndex / (CGFloat)weakSelf.totalADCounts) * SCREEN_WIDTH);
        }];
        [self layoutIfNeeded];
    }
}

- (void)configureAdsArray {
    NSInteger ADcounts = _ADArray.count;
    if (ADcounts == 0) {
        _ADArray = [NSArray arrayWithObjects:_placeHolderImage,_placeHolderImage,_placeHolderImage, nil];
        self.totalADCounts = 3;
    }
    if (ADcounts == 1) {
        self.isShowPageControl = NO;
    }
    else {
        self.placeHolderImage = [UIImage imageNamed:@"banner_nodata" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil];
        _scrollView.scrollEnabled = YES;
        self.totalADCounts = ADcounts;
        self.isShowPageControl = YES;
    }
    [self updateImagesWhenScrolled];
    [self setPageControl];
    [self setIsAutomaticScroll:_isAutomaticScroll];
}
#pragma mark - UI
- (void)configureViews {
    [self addSubview:self.scrollView];
    __weak typeof(self) selfWeak = self;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(selfWeak);
        make.leading.equalTo(selfWeak);
        make.trailing.equalTo(selfWeak);
        make.bottom.equalTo(selfWeak);
    }];
}
- (void)configureImageViews {
    __weak __typeof(&*self)weakSelf = self;
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.centerImageView];
    [self.scrollView addSubview:self.rightImageView];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        obj.backgroundColor = [UIColor randomColor];
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf);
            make.size.equalTo(weakSelf.scrollView);
            make.left.equalTo(weakSelf.scrollView).offset(SCREEN_WIDTH * idx);
        }];
    }];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (CGSizeEqualToSize(_scrollView.contentSize, CGSizeZero)) {
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3.0 , 0.0);
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0.0)];
    }
}
#pragma mark - Setter&Getter
- (void)setADArray:(NSArray *)ADArray {
    if (_ADArray != ADArray) {
        _ADArray = ADArray;
        [self configureAdsArray];
    }
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        
        // 监听点击页面事件
        UITapGestureRecognizer *searchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchViewSelected:)];
        [_scrollView addGestureRecognizer:searchViewTap];
        
    }
    return _scrollView;
}
- (UIView *)pageControl {
    if (_pageControl == nil) {
        if (_isNormalPageControl) {
      UIPageControl *pageControl                = [UIPageControl new];
      pageControl.numberOfPages                 = _totalADCounts;
      pageControl.pageIndicatorTintColor        = UIColor.groupTableViewBackgroundColor;
      pageControl.currentPageIndicatorTintColor = UIColor.blueColor;
      _pageControl                              = pageControl;
    }else{
      _pageControl                              = [[UIView alloc] init];
      _pageControl.backgroundColor              = [UIColor colorWithWhite:1.f alpha:.6f];
        }
    }
    return _pageControl;
}

- (YYAnimatedImageView *)leftImageView {
    if(_leftImageView == nil) {
        _leftImageView = [[YYAnimatedImageView alloc] init];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _leftImageView;
}
- (YYAnimatedImageView *)centerImageView {
    if(_centerImageView == nil) {
        _centerImageView = [[YYAnimatedImageView alloc] init];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
        _centerImageView.image = _placeHolderImgae;
    }
    return _centerImageView;
}
- (YYAnimatedImageView *)rightImageView {
    if(_rightImageView == nil) {
        _rightImageView = [[YYAnimatedImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightImageView;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(_centerImageView.frame.size.width / 2 - 20, _centerImageView.frame.size.height / 2 - 20, 40, 40);
        _progressLayer.cornerRadius = MIN(CGRectGetWidth(_progressLayer.bounds) / 2.0f, CGRectGetHeight(_progressLayer.bounds) / 2.0f);
        _progressLayer.lineWidth = 4;
        _progressLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:_progressLayer.cornerRadius - 7];
        _progressLayer.path = path.CGPath;
        _progressLayer.hidden = YES;
        [_centerImageView.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

- (void)setPlaceHolderImage:(UIImage *)placeHolderImage{
    _placeHolderImage = placeHolderImage;
}
- (void)setIsShowPageControl:(BOOL)isShowPageControl{
    _isShowPageControl = isShowPageControl;
    isShowPageControl ? [self addSubview:self.pageControl] : [self.pageControl removeFromSuperview];
}
- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    _isConfigureImage = NO;
    [self updateImagesWhenScrolled];
}
- (void)setTotalADCounts:(NSInteger)totalADCounts{
    _totalADCounts = totalADCounts;
    if (!_isLoopShell && totalADCounts == 1) {
        _scrollView.scrollEnabled = NO;
        _scrollView.delegate = nil;
        [self releaseTimer];
    }
}
- (void)setIsLoopShell:(BOOL)isLoopShell{
    _isLoopShell = isLoopShell;
    if (!isLoopShell && _totalADCounts == 1) {
        _scrollView.scrollEnabled = NO;
        _scrollView.delegate = nil;
        [self releaseTimer];
    }
}

- (void)setIsAutomaticScroll:(BOOL)isAutomaticScroll{
    _isAutomaticScroll = isAutomaticScroll;
    if (_ADArray.count < 2) {
        _isAutomaticScroll = NO;
    }
    _isAutomaticScroll ? [self setUpTimer] : [self releaseTimer];
}
@end
