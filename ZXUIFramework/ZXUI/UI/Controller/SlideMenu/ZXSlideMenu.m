//
//  ZXSlideMenu.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/19.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXSlideMenu.h"

static CGFloat MenuWidthScale = 0.8f;
static CGFloat MaxCoverAlpha = 0.3;
static CGFloat MinActionSpeed = 500;

@interface ZXSlideMenu ()<UIGestureRecognizerDelegate>{
    CGPoint _originalPoint;
}

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation ZXSlideMenu

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController{
    if (self = [super init]) {
        _rootViewController = rootViewController;
        [self addChildViewController:_rootViewController];
        [self.view addSubview:_rootViewController.view];
        [_rootViewController didMoveToParentViewController:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    _pan.delegate = self;
    [self.view addGestureRecognizer:_pan];
    
    _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0;
    _coverView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [_coverView addGestureRecognizer:tap];
    [_rootViewController.view addSubview:_coverView];
    [self applyShadowToSlidingViewAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self updateLeftMenuFrame];
    
    [self updateRightMenuFrame];
}

#pragma mark Setter&&Getter

-(void)setLeftViewController:(UIViewController *)leftViewController{
    _leftViewController = leftViewController;
    [self addChildViewController:_leftViewController];
    [self.view insertSubview:_leftViewController.view atIndex:0];
    [_leftViewController didMoveToParentViewController:self];
}

-(void)setRightViewController:(UIViewController *)rightViewController{
    _rightViewController = rightViewController;
    [self addChildViewController:_rightViewController];
    [self.view insertSubview:_rightViewController.view atIndex:0];
    [_rightViewController didMoveToParentViewController:self];
}

-(void)setSlideEnabled:(BOOL)slideEnabled{
    _pan.enabled = slideEnabled;
}

-(BOOL)slideEnabled{
    return _pan.isEnabled;
}

#pragma mark 拖拽方法
-(void)pan:(UIPanGestureRecognizer*)pan{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _originalPoint = _rootViewController.view.center;
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged:pan];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnd:pan];
            break;
        default:
            break;
    }
}

-(void)panChanged:(UIPanGestureRecognizer*)pan{
    CGPoint translation = [pan translationInView:self.view];
    _rootViewController.view.center = CGPointMake(_originalPoint.x + translation.x, _originalPoint.y);
    if (!_rightViewController && CGRectGetMinX(_rootViewController.view.frame) <= 0 ) {
        _rootViewController.view.frame = self.view.bounds;
    }
    if (!_leftViewController && CGRectGetMinX(_rootViewController.view.frame) >= 0) {
        _rootViewController.view.frame = self.view.bounds;
    }
    if (CGRectGetMinX(_rootViewController.view.frame) > self.menuWidth) {
        _rootViewController.view.center = CGPointMake(_rootViewController.view.bounds.size.width/2 + self.menuWidth, _rootViewController.view.center.y);
    }
    if (CGRectGetMaxX(_rootViewController.view.frame) < self.emptyWidth) {
        _rootViewController.view.center = CGPointMake(_rootViewController.view.bounds.size.width/2 - self.menuWidth, _rootViewController.view.center.y);
    }
    if (CGRectGetMinX(_rootViewController.view.frame) > 0) {
        [self.view sendSubviewToBack:_rightViewController.view];
        [self updateLeftMenuFrame];
        _coverView.hidden = NO;
        [_rootViewController.view bringSubviewToFront:_coverView];
        _coverView.alpha = CGRectGetMinX(_rootViewController.view.frame)/self.menuWidth * MaxCoverAlpha;
    }else if (CGRectGetMinX(_rootViewController.view.frame) < 0){
        [self.view sendSubviewToBack:_leftViewController.view];
        [self updateRightMenuFrame];
        _coverView.hidden = NO;
        [_rootViewController.view bringSubviewToFront:_coverView];
        _coverView.alpha = (CGRectGetMaxX(self.view.frame) - CGRectGetMaxX(_rootViewController.view.frame))/self.menuWidth * MaxCoverAlpha;
    }
}

- (void)panEnd:(UIPanGestureRecognizer*)pan {
    CGFloat speedX = [pan velocityInView:pan.view].x;
    if (ABS(speedX) > MinActionSpeed) {
        [self dealWithFastSliding:speedX];
        return;
    }
    if (CGRectGetMinX(_rootViewController.view.frame) > self.menuWidth/2) {
        [self showLeftViewControllerAnimated:true];
    }else if (CGRectGetMaxX(_rootViewController.view.frame) < self.menuWidth/2 + self.emptyWidth){
        [self showRightViewControllerAnimated:true];
    }else{
        [self showRootViewControllerAnimated:true];
    }
}

- (void)dealWithFastSliding:(CGFloat)speedX {
    BOOL swipeRight = speedX > 0;
    BOOL swipeLeft = speedX < 0;
    CGFloat roootX = CGRectGetMinX(_rootViewController.view.frame);
    if (swipeRight) {
        if (roootX > 0) {
            [self showLeftViewControllerAnimated:true];
        }else if (roootX < 0){
            [self showRootViewControllerAnimated:true];
        }
    }
    if (swipeLeft) {
        if (roootX < 0) {
            [self showRightViewControllerAnimated:true];
        }else if (roootX > 0){
            [self showRootViewControllerAnimated:true];
        }
    }
    return;
}

#pragma mark PanDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)_rootViewController;
        if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
            return NO;
        }
    }
    if ([_rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarController = (UITabBarController*)_rootViewController;
        UINavigationController *navigationController = tabbarController.selectedViewController;
        if ([navigationController isKindOfClass:[UINavigationController class]]) {
            if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
                return NO;
            }
        }
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGFloat actionWidth = [self emptyWidth];
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x <= actionWidth || point.x > self.view.bounds.size.width - actionWidth) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)tap {
    [self showRootViewControllerAnimated:true];
}

#pragma mark 显示/隐藏方法
-(void)showRootViewControllerAnimated:(BOOL)animated{
    [UIView animateWithDuration:[self animationDurationAnimated:animated] animations:^{
        CGRect frame = self.rootViewController.view.frame;
        frame.origin.x = 0;
        self.rootViewController.view.frame = frame;
        [self updateLeftMenuFrame];
        [self updateRightMenuFrame];
        self.coverView.alpha = 0;
    }completion:^(BOOL finished) {
        self.coverView.hidden = YES;
    }];
}

- (void)showLeftViewControllerAnimated:(BOOL)animated {
    if (!_leftViewController) {return;}
    [self.view sendSubviewToBack:_rightViewController.view];
    _coverView.hidden = NO;
    [_rootViewController.view bringSubviewToFront:_coverView];
    [UIView animateWithDuration:[self animationDurationAnimated:animated] animations:^{
        self.rootViewController.view.center = CGPointMake(self.rootViewController.view.bounds.size.width/2 + self.menuWidth, self.rootViewController.view.center.y);
         self.leftViewController.view.frame = CGRectMake(0, 0, [self menuWidth], self.view.bounds.size.height);
         self.coverView.alpha = MaxCoverAlpha;
    }];
}

- (void)showRightViewControllerAnimated:(BOOL)animated {
    if (!_rightViewController) {return;}
    _coverView.hidden = NO;
    [_rootViewController.view bringSubviewToFront:_coverView];
    [self.view sendSubviewToBack:_leftViewController.view];
    [UIView animateWithDuration:[self animationDurationAnimated:animated] animations:^{
        self.rootViewController.view.center = CGPointMake(self.rootViewController.view.bounds.size.width/2 - self.menuWidth, self.rootViewController.view.center.y);
        self.rightViewController.view.frame = CGRectMake([self emptyWidth], 0, [self menuWidth], self.view.bounds.size.height);
        self.coverView.alpha = MaxCoverAlpha;
    }];
}

- (void)restoreShadowToSlidingView {
    UIView* shadowedView = self.rootViewController.view;
//    if (!shadowedView) return;
    
    CALayer *shadowLayer = shadowedView.layer;
    shadowLayer.shadowOpacity = 0.0;
    shadowLayer.shadowPath = nil;
}

- (void)applyShadowToSlidingViewAnimated:(BOOL)animated {
//    if (!self.shadowEnabled) return;
    
    UIView* shadowedView = self.rootViewController.view;
    if (!shadowedView) return;
    CALayer *shadowLayer = shadowedView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowRadius = 10;
    shadowLayer.shadowOpacity = 0.5;
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowLayer.bounds] CGPath];
    if (animated) {
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = @(0.0);
        anim.duration = 1.0;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.fillMode = kCAFillModeForwards;
        [shadowLayer addAnimation:anim forKey:@"animateShadowOpacity"];
    }
}


#pragma mark -
#pragma mark 其它方法
- (void)updateLeftMenuFrame {
    _leftViewController.view.center = CGPointMake(CGRectGetMinX(_rootViewController.view.frame)/2, _leftViewController.view.center.y);
}

- (void)updateRightMenuFrame {
    _rightViewController.view.center = CGPointMake((self.view.bounds.size.width + CGRectGetMaxX(_rootViewController.view.frame))/2, _rightViewController.view.center.y);
}

- (CGFloat)menuWidth {
    if(_menuWidth) return _menuWidth;
    return MenuWidthScale * self.view.bounds.size.width;
}

- (CGFloat)emptyWidth {
    return self.view.bounds.size.width - self.menuWidth;
}

- (CGFloat)animationDurationAnimated:(BOOL)animated {
    return animated ? 0.25 : 0;
}

@end

@implementation UIViewController (SlideMenu)

- (ZXSlideMenu *)sldeMenu {
    UIViewController *sldeMenu = self.parentViewController;
    while (sldeMenu) {
        if ([sldeMenu isKindOfClass:[ZXSlideMenu class]]) {
            return (ZXSlideMenu *)sldeMenu;
        } else if (sldeMenu.parentViewController && sldeMenu.parentViewController != sldeMenu) {
            sldeMenu = sldeMenu.parentViewController;
        } else {
            sldeMenu = nil;
        }
    }
    return nil;
}

@end
