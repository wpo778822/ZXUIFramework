//
//  ZXArtLoadingView.m
//  ZXartApp
//
//  Created by mac  on 2017/1/19.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXLoadingSeedView.h"

@interface ZXLoadingSeedView (){
    CADisplayLink *_disPlayLink;
    /**
     曲线的振幅
     */
    CGFloat _waveAmplitude;
    /**
     曲线角速度
     */
    CGFloat _wavePalstance;
    /**
     曲线初相
     */
    CGFloat _waveX;
    /**
     曲线偏距
     */
    CGFloat _waveY;
    /**
     曲线移动速度
     */
    CGFloat _waveMoveSpeed;
    
    /**
     曲线间隔
     */
    CGFloat _waveOffset;

    //背景发暗的图片
    UIImageView *_imageView1;
    
    //前面正常显示的图片
    UIImageView *_imageView2;
}

@end

@implementation ZXLoadingSeedView

#pragma mark - Class Method
+ (void)hideSeedViewFromView:(UIView *)superView {
    for (UIView *view in superView.subviews) {
        if ([view isKindOfClass:self]) {
            ZXLoadingSeedView *load = (ZXLoadingSeedView*)view;
            [load removeLoadingView];
            [load removeFromSuperview];
        }
    }
}

#pragma mark - Lifecycle

- (instancetype)initWithSize:(CGSize)size bottomImage:(UIImage *)bottomImage topImage:(UIImage *)topImage fillColor:(UIColor *)fillColor{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        [self buildWithBottomImage:bottomImage topImage:topImage fillColor:fillColor];
        [self buildData];
    }
    return self;
}

- (void)buildWithBottomImage:(UIImage *)bottomImage topImage:(UIImage *)topImage fillColor:(UIColor *)fillColor{
    //画个圆
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.masksToBounds = YES;
    
    //底部图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = bottomImage;
    [self addSubview:imageView];
    
    //上层图片加暗层
    _imageView1 = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView1.image = topImage;
    _imageView1.backgroundColor = fillColor;
    [self addSubview:_imageView1];
    UIView *view = [[UIView alloc] initWithFrame:_imageView1.bounds];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [_imageView1 addSubview:view];
    
    //上层原图
    _imageView2 = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView2.image = topImage;
    _imageView2.backgroundColor = fillColor;
    [self addSubview:_imageView2];
}

//初始化数据
-(void)buildData{
    //振幅
    _waveAmplitude = 3;
    //角速度
    _wavePalstance = 0.12;
    //偏距
    _waveY = self.bounds.size.height * 0.5;
    //初相
    _waveX = 0;
    //间隔
    _waveOffset = 1.0;
    //x轴移动速度
#if TARGET_IPHONE_SIMULATOR
    _waveMoveSpeed = 0.3;
#elif TARGET_OS_IPHONE
    _waveMoveSpeed = 0.15;
#endif
    
    //以屏幕刷新速度为周期刷新曲线的位置
    _disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWave)];
    [_disPlayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateWave{
    _waveX -= _waveMoveSpeed;
    [self updateWave1];
    [self updateWave2];
}

- (void)updateWave1{
    //波浪宽度
    CGFloat waterWaveWidth = self.bounds.size.width;
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, _waveY);
    //初始化波浪其实Y为偏距
    CGFloat y = 0;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * sin(_wavePalstance * x + _waveX + _waveOffset) + _waveY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    //填充底部颜色
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathCloseSubpath(path);
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    _imageView1.layer.mask = layer;
    CGPathRelease(path);
}

- (void)updateWave2{
    //波浪宽度
    CGFloat waterWaveWidth = self.bounds.size.width;
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, _waveY);
    //初始化波浪其实Y为偏距
    CGFloat y = 0;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * sin(_wavePalstance * x + _waveX) + _waveY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    //添加终点路径、填充底部颜色
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathCloseSubpath(path);
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    _imageView2.layer.mask = layer;
    CGPathRelease(path);
}

- (void)removeLoadingView{
    if (_disPlayLink) {
        [_disPlayLink invalidate];
        _disPlayLink = nil;
    }
    
    if (_imageView1) {
        [_imageView1 removeFromSuperview];
        _imageView1 = nil;
    }
    if (_imageView2) {
        [_imageView2 removeFromSuperview];
        _imageView2 = nil;
    }
}
@end
