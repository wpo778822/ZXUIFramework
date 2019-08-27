//
//  ZXMarqueeLabel.m
//  Demo
//
//  Created by 黄勤炜 on 2018/8/7.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXMarqueeLabel.h"

@interface ZXMarqueeLabel ()

@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, assign) CGFloat offsetX;
@property(nonatomic, assign) CGFloat textWidth;

@property(nonatomic, strong) CAGradientLayer *fadeLeftLayer;
@property(nonatomic, strong) CAGradientLayer *fadeRightLayer;

@property(nonatomic, assign) BOOL isFirstDisplay;

/// 绘制文本时重复绘制的次数，用于实现首尾连接的滚动效果，1 表示不首尾连接，大于 1 表示首尾连接。
@property(nonatomic, assign) NSInteger textRepeatCount;
@end

@implementation ZXMarqueeLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineBreakMode = NSLineBreakByClipping;
        self.clipsToBounds = YES;
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}


- (void)didInitialize {
    self.speed = .5;
    self.pauseDurationWhenMoveToEdge = 2.5;
    self.spacingBetweenHeadToTail = 20;
    self.automaticallyValidateVisibleFrame = YES;
    self.fadeWidth = 20;
    self.fadeStartColor = [UIColor colorWithWhite:255 alpha:1];
    self.fadeEndColor = [UIColor colorWithWhite:255 alpha:0];
    self.shouldFadeAtEdge = NO;
    self.textStartAfterFade = NO;
    
    self.isFirstDisplay = YES;
    self.textRepeatCount = 2;
}

- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.offsetX = 0;
    self.displayLink.paused = ![self shouldPlayDisplayLink];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    self.offsetX = 0;
    self.textWidth = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    self.displayLink.paused = ![self shouldPlayDisplayLink];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    self.offsetX = 0;
    self.textWidth = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    self.displayLink.paused = ![self shouldPlayDisplayLink];
}

- (void)drawTextInRect:(CGRect)rect {
    CGFloat textInitialX = 0;
    if (self.textAlignment == NSTextAlignmentLeft) {
        textInitialX = 0;
    } else if (self.textAlignment == NSTextAlignmentCenter) {
        textInitialX = fmax(0, (CGRectGetWidth(self.bounds) - self.textWidth) / 2.0);
    } else if (self.textAlignment == NSTextAlignmentRight) {
        textInitialX = fmax(0, CGRectGetWidth(self.bounds) - self.textWidth);
    }
    
    // 考虑渐变遮罩的偏移
    CGFloat textOffsetXByFade = 0;
    BOOL shouldTextStartAfterFade = self.shouldFadeAtEdge && self.textStartAfterFade && self.textWidth > CGRectGetWidth(self.bounds);
    if (shouldTextStartAfterFade && textInitialX < self.fadeWidth) {
        textOffsetXByFade = self.fadeWidth;
    }
    textInitialX += textOffsetXByFade;
    
    for (NSInteger i = 0; i < self.textRepeatCountConsiderTextWidth; i++) {
        [self.attributedText drawInRect:CGRectMake(self.offsetX + (self.textWidth + self.spacingBetweenHeadToTail) * i + textInitialX, 0, self.textWidth, CGRectGetHeight(rect))];
    }
}

- (void)layoutSubviews {
    BOOL isSizeChanged = !(self.frame.size.width <=0 || self.frame.size.height <= 0);
    [super layoutSubviews];
    if (isSizeChanged) {
        self.offsetX = 0;
        self.displayLink.paused = ![self shouldPlayDisplayLink];
    }
    if (self.fadeLeftLayer) {
        self.fadeLeftLayer.frame = CGRectMake(0, 0, self.fadeWidth, CGRectGetHeight(self.bounds));
        [self bringSublayerToFront:self.fadeLeftLayer];
        // 显示非英文字符时，UILabel 内部会额外多出一层 layer 盖住了这里的 fadeLayer，所以要手动提到最前面
    }
    if (self.fadeRightLayer) {
        self.fadeRightLayer.frame = CGRectMake(CGRectGetWidth(self.bounds) - self.fadeWidth, 0, self.fadeWidth, CGRectGetHeight(self.bounds));
        [self bringSublayerToFront:self.fadeLeftLayer];
        // 显示非英文字符时，UILabel 内部会额外多出一层 layer 盖住了这里的 fadeLayer，所以要手动提到最前面
    }
}

- (void)bringSublayerToFront:(CALayer *)sublayer {
    if (sublayer.superlayer == self.layer) {
        [sublayer removeFromSuperlayer];
        [self.layer insertSublayer:sublayer atIndex:(unsigned)self.layer.sublayers.count];
    }
}

- (NSInteger)textRepeatCountConsiderTextWidth {
    if (self.textWidth < CGRectGetWidth(self.bounds)) {
        return 1;
    }
    return self.textRepeatCount;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    if (self.offsetX == 0) {
        displayLink.paused = YES;
        [self setNeedsDisplay];
        
        int64_t delay = (self.isFirstDisplay || self.textRepeatCount <= 1) ? self.pauseDurationWhenMoveToEdge : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            displayLink.paused = ![self shouldPlayDisplayLink];
            if (!displayLink.paused) {
                self.offsetX -= self.speed;
            }
        });
        
        if (delay > 0 && self.textRepeatCount > 1) {
            self.isFirstDisplay = NO;
        }
        
        return;
    }
    
    self.offsetX -= self.speed;
    [self setNeedsDisplay];
    
    if (-self.offsetX >= self.textWidth + (self.textRepeatCountConsiderTextWidth > 1 ? self.spacingBetweenHeadToTail : 0)) {
        displayLink.paused = YES;
        int64_t delay = self.textRepeatCount > 1 ? self.pauseDurationWhenMoveToEdge : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.offsetX = 0;
            [self handleDisplayLink:displayLink];
        });
    }
}

- (BOOL)shouldPlayDisplayLink {
    BOOL result = self.window && CGRectGetWidth(self.bounds) > 0 && self.textWidth > CGRectGetWidth(self.bounds);
    
    // 如果 label.frame 在 window 可视区域之外，也视为不可见，暂停掉 displayLink
    if (result && self.automaticallyValidateVisibleFrame) {
        CGRect rectInWindow = [self.window convertRect:self.frame fromView:self.superview];
        if (!CGRectIntersectsRect(self.window.bounds, rectInWindow)) {
            return NO;
        }
    }
    
    return result;
}

- (void)setOffsetX:(CGFloat)offsetX {
    _offsetX = offsetX;
    [self updateFadeLayersHidden];
}

- (void)setShouldFadeAtEdge:(BOOL)shouldFadeAtEdge {
    _shouldFadeAtEdge = shouldFadeAtEdge;
    if (shouldFadeAtEdge) {
        [self initFadeLayersIfNeeded];
    }
    [self updateFadeLayersHidden];
}

- (void)setFadeStartColor:(UIColor *)fadeStartColor {
    _fadeStartColor = fadeStartColor;
    [self updateFadeLayerColors];
}

- (void)setFadeEndColor:(UIColor *)fadeEndColor {
    _fadeEndColor = fadeEndColor;
    [self updateFadeLayerColors];
}

- (void)updateFadeLayerColors {
    if (self.fadeLeftLayer) {
        if (self.fadeStartColor && self.fadeEndColor) {
            self.fadeLeftLayer.colors = @[(id)self.fadeStartColor.CGColor,
                                          (id)self.fadeEndColor.CGColor];
        } else {
            self.fadeLeftLayer.colors = nil;
        }
    }
    if (self.fadeRightLayer) {
        if (self.fadeStartColor && self.fadeEndColor) {
            self.fadeRightLayer.colors = @[(id)self.fadeStartColor.CGColor,
                                           (id)self.fadeEndColor.CGColor];
        } else {
            self.fadeRightLayer.colors = nil;
        }
    }
}

- (void)updateFadeLayersHidden {
    if (!self.fadeLeftLayer || !self.fadeRightLayer) {
        return;
    }
    
    BOOL shouldShowFadeLeftLayer = self.shouldFadeAtEdge && (self.offsetX < 0 || (self.offsetX == 0 && !self.isFirstDisplay));
    self.fadeLeftLayer.hidden = !shouldShowFadeLeftLayer;
    
    BOOL shouldShowFadeRightLayer = self.shouldFadeAtEdge && (self.textWidth > CGRectGetWidth(self.bounds) && self.offsetX != self.textWidth - CGRectGetWidth(self.bounds));
    self.fadeRightLayer.hidden = !shouldShowFadeRightLayer;
}

- (void)initFadeLayersIfNeeded {
    if (!self.fadeLeftLayer) {
        self.fadeLeftLayer = [CAGradientLayer layer];// 请保留自带的 hidden 动画
        self.fadeLeftLayer.startPoint = CGPointMake(0, .5);
        self.fadeLeftLayer.endPoint = CGPointMake(1, .5);
        [self.layer addSublayer:self.fadeLeftLayer];
        [self setNeedsLayout];
    }
    
    if (!self.fadeRightLayer) {
        self.fadeRightLayer = [CAGradientLayer layer];// 请保留自带的 hidden 动画
        self.fadeRightLayer.startPoint = CGPointMake(1, .5);
        self.fadeRightLayer.endPoint = CGPointMake(0, .5);
        [self.layer addSublayer:self.fadeRightLayer];
        [self setNeedsLayout];
    }
    
    [self updateFadeLayerColors];
}

@end

@implementation ZXMarqueeLabel (ReusableView)

- (BOOL)requestToStartAnimation {
    self.automaticallyValidateVisibleFrame = NO;
    BOOL shouldPlayDisplayLink = [self shouldPlayDisplayLink];
    if (shouldPlayDisplayLink) {
        self.displayLink.paused = NO;
    }
    return shouldPlayDisplayLink;
}

- (BOOL)requestToStopAnimation {
    self.displayLink.paused = YES;
    return YES;
}

@end
