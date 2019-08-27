//
//  ZXGestureLockView.m
//  ZXUI
//
//  Created by mac on 2018/10/10.
//  Copyright © 2018 mac. All rights reserved.
//

#import "ZXGestureLockView.h"

typedef NS_ENUM(NSInteger, ZXGestureLockType) {
    ZXGestureLockNormal,
    ZXGestureLockSelected,
    ZXGestureLockErrorType,
};

@interface ZXGestureLockKeyView:UIView

@property (nonatomic, assign) ZXGestureLockType lockType;
@property (nonatomic, strong) UIView *seedView;
@property (nonatomic, strong) UIColor *errorColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@end

@implementation ZXGestureLockKeyView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _seedView = [UIView new];
        [self addSubview:_seedView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height/2.0;
    
    CGFloat x = CGRectGetWidth(self.frame) / 3.0;
    CGFloat y = CGRectGetWidth(self.frame) / 3.0;
    CGFloat w = CGRectGetWidth(self.frame) / 3.0;
    self.seedView.frame = CGRectMake(x, y, w, w);
    self.seedView.layer.cornerRadius = self.seedView.frame.size.height/2;
}


- (void)setErrorColor:(UIColor *)errorColor{
    _errorColor = errorColor;
}
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    self.seedView.backgroundColor = _normalColor;
}
- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
}

- (void)setLockType:(ZXGestureLockType)lockType{
    _lockType = lockType;
    switch (_lockType) {
        case ZXGestureLockNormal:
            self.backgroundColor = [UIColor clearColor];
            self.seedView.backgroundColor = self.normalColor;
            break;
        case ZXGestureLockSelected:
            self.backgroundColor = self.normalColor;
            self.seedView.backgroundColor = self.selectedColor;
            break;
        case ZXGestureLockErrorType:
            self.backgroundColor = self.normalColor;
            self.seedView.backgroundColor = self.errorColor;
            break;
        default:
            break;
    }
}

@end

NSInteger const Rows  = 3;
NSInteger const Count = 9;

@interface ZXGestureLockView ()
@property (nonatomic, strong) NSMutableArray <ZXGestureLockKeyView *> *keyViewArray;
@property (nonatomic, strong) NSMutableArray <ZXGestureLockKeyView *> *selectedKeyViewArray;
@property (nonatomic, assign) CGPoint movePoint;
@property (nonatomic, strong) CAShapeLayer *drawLayer;

@end

@implementation ZXGestureLockView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 2;
        self.errorLineColor = UIColor.redColor;
        self.selectedLineColor = UIColor.blueColor;
        self.horizontalSpace = 30;
        self.verticalSpace = 30;
        self.normalColor = UIColor.groupTableViewBackgroundColor;
        [self setViews];
    }
    return self;
}

- (CAShapeLayer *)drawLayer{
    if (!_drawLayer) {
        _drawLayer = [CAShapeLayer layer];
        _drawLayer.fillColor = [UIColor clearColor].CGColor;
        _drawLayer.lineWidth = self.lineWidth;
        _drawLayer.lineJoin = @"round";
        [self.layer addSublayer:_drawLayer];
    }
    return _drawLayer;
}


- (NSMutableArray *)keyViewArray{
    if (!_keyViewArray) {
        _keyViewArray = @[].mutableCopy;
    }
    return _keyViewArray;
}
- (NSMutableArray *)selectedKeyViewArray{
    if (!_selectedKeyViewArray) {
        _selectedKeyViewArray = @[].mutableCopy;
    }
    return _selectedKeyViewArray;
}

- (void)setHorizontalSpace:(CGFloat)horizontalSpace{
    _horizontalSpace = horizontalSpace;
    [self setNeedsLayout];
}

- (void)setVerticalSpace:(CGFloat)verticalSpace{
    _verticalSpace = verticalSpace;
    [self setNeedsLayout];
}

- (void)setErrorLineColor:(UIColor *)errorLineColor{
    _errorLineColor = errorLineColor;
    for (ZXGestureLockKeyView *view in self.keyViewArray) {
        view.errorColor = errorLineColor;
    }
}
- (void)setSelectedLineColor:(UIColor *)selectedLineColor{
    _selectedLineColor = selectedLineColor;
    for (ZXGestureLockKeyView *view in self.keyViewArray) {
        view.selectedColor = selectedLineColor;
    }
}
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    for (ZXGestureLockKeyView *view in self.keyViewArray) {
        view.normalColor = normalColor;
    }
}
- (void)setShowErrorStatus:(BOOL)showErrorStatus{
    _showErrorStatus = showErrorStatus;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if(Rows < 1) return;
    CGFloat keyViewWidth = (CGRectGetWidth(self.frame)- (Rows-1)*self.horizontalSpace)/Rows;
    [self.keyViewArray enumerateObjectsUsingBlock:^(ZXGestureLockKeyView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger num = idx/Rows;
        NSInteger remainNum = idx%Rows;
        obj.frame = CGRectMake((keyViewWidth+self.horizontalSpace)*remainNum, (keyViewWidth+self.verticalSpace)*num, keyViewWidth, keyViewWidth);
    }];
}

- (void)setViews{
    self.backgroundColor = [UIColor clearColor];
    for (NSUInteger i = 0; i < Count; i++) {
        ZXGestureLockKeyView *keyView = [[ZXGestureLockKeyView alloc]init];
        keyView.errorColor = self.errorLineColor;
        keyView.selectedColor = self.selectedLineColor;
        keyView.normalColor = self.normalColor;
        keyView.tag = i+1;
        [self addSubview:keyView];
        [self.keyViewArray addObject:keyView];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.selectedKeyViewArray.count>0) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        ZXGestureLockKeyView *firstKeyView = [self.selectedKeyViewArray objectAtIndex:0];
        [bezierPath moveToPoint:firstKeyView.center];
        self.drawLayer.strokeColor = self.showErrorStatus ? self.errorLineColor.CGColor : self.selectedLineColor.CGColor;
        [self.selectedKeyViewArray enumerateObjectsUsingBlock:^(ZXGestureLockKeyView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.lockType = self.showErrorStatus ? ZXGestureLockErrorType : ZXGestureLockSelected;
            [bezierPath addLineToPoint:obj.center];
        }];
        if (!CGPointEqualToPoint(self.movePoint, CGPointZero)) {
             [bezierPath addLineToPoint:self.movePoint];
        }
        self.drawLayer.path = bezierPath.CGPath;
    }else{
        [self.drawLayer removeFromSuperlayer];
        self.drawLayer = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationPoint = [touch locationInView:self];
    ZXGestureLockKeyView *keyView = [self returnContainKeyViewWithPoint:locationPoint];
    if (keyView) {
        [self.selectedKeyViewArray addObject:keyView];
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationPoint = [touch locationInView:self];
    if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), locationPoint)) {
        ZXGestureLockKeyView *keyView = [self returnContainKeyViewWithPoint:locationPoint];
        if (keyView&&![self.selectedKeyViewArray containsObject:keyView]) {
            [self.selectedKeyViewArray addObject:keyView];
        }
        self.movePoint = locationPoint;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(didSelectedGestureLockView:pathNumberStr:)]) {
       self.showErrorStatus = [self.delegate didSelectedGestureLockView:self pathNumberStr:[self returnPathNumber]];
    }
    self.movePoint = CGPointZero;
    [self setNeedsDisplay];
    if (self.showErrorStatus)[self changeSelectedKeyViewWithKeytype:ZXGestureLockErrorType];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self clearKeyView];
    });
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self clearKeyView];
}


#pragma mark - Something
- (ZXGestureLockKeyView *)returnContainKeyViewWithPoint:(CGPoint)point{
    ZXGestureLockKeyView *tempView = nil;
    for (ZXGestureLockKeyView *keyView in self.keyViewArray) {
        if (CGRectContainsPoint(keyView.frame, point)) {
            tempView = keyView;
            break;
        }
    }
    return tempView;
}

- (void)clearKeyView{
    [self.selectedKeyViewArray removeAllObjects];
    self.movePoint = CGPointZero;
    self.showErrorStatus = NO;
    [self setNeedsDisplay];
    [self changeAllKeyViewWithKeytype:ZXGestureLockNormal];
}

- (void)changeAllKeyViewWithKeytype:(ZXGestureLockType)keyType{
    for (ZXGestureLockKeyView *keyView in self.keyViewArray) {
        if (keyView.lockType != keyType) {
            keyView.lockType = keyType;
        }
    }
}

- (void)changeSelectedKeyViewWithKeytype:(ZXGestureLockType)keyType{
    for (ZXGestureLockKeyView *keyView in self.selectedKeyViewArray) {
        if (keyView.lockType != keyType) {
            keyView.lockType = keyType;
        }
    }
}

- (NSString *)returnPathNumber{
    NSString *path = @"";
    for (ZXGestureLockKeyView *keyView in self.selectedKeyViewArray) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)keyView.tag]];
    }
    return path;
}



@end
