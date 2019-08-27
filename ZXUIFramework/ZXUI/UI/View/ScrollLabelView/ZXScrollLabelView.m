//
//  ZXScrollLabelView.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/8.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXScrollLabelView.h"
#import <CoreText/CoreText.h>
#define ZXScrollLabelFont [UIFont systemFontOfSize:14]

static const NSInteger kScrollDefaultTimeInterval = 2.0;//滚动默认时间

typedef NS_ENUM(NSInteger, ZXScrollLabelType) {
    ZXScrollLabelTypeUp = 0,
    ZXScrollLabelTypeDown
};

#pragma mark - NSTimer+TimerTarget

@interface NSTimer (TimerTarget)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)yesOrNo block:(void(^)(NSTimer *timer))block;

@end


@implementation NSTimer (TimerTarget)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)yesOrNo block:(void (^)(NSTimer *))block{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(startTimer:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)startTimer:(NSTimer *)timer {
    void (^block)(NSTimer *timer) = timer.userInfo;
    if (block) {
        block(timer);
    }
}

@end

#pragma mark - ZXScrollLabel


@interface ZXScrollLabel : UILabel

@property (assign, nonatomic) UIEdgeInsets contentInset;

@end

@implementation ZXScrollLabel

- (instancetype)init {
    if (self = [super init]) {
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _contentInset)];
}

@end

@interface ZXScrollLabel (Label)

+ (instancetype)initDefault;

@end

@implementation ZXScrollLabel (Label)

+ (instancetype)initDefault {
    ZXScrollLabel *label = [[ZXScrollLabel alloc]init];
    label.numberOfLines = 0;
    label.font = ZXScrollLabelFont;
    label.textColor = [UIColor whiteColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@end

#pragma mark - ZXScrollLabelView

@interface ZXScrollLabelView ()

@property (weak, nonatomic) ZXScrollLabel *upLabel;

@property (weak, nonatomic) ZXScrollLabel *downLabel;
//定时器
@property (strong, nonatomic) NSTimer *scrollTimer;
//文本行分割数组
@property (strong, nonatomic) NSArray *scrollArray;
//当前滚动行
@property (assign, nonatomic) NSInteger currentSentence;
//是否第一次开始计时
@property (assign, nonatomic, getter=isFirstTime) BOOL firstTime;
//传入参数是否为数组
@property (assign, nonatomic) BOOL isArray;

@end

@implementation ZXScrollLabelView

@synthesize scrollSpace = _scrollSpace;

@synthesize font = _font;

#pragma mark - Preference Methods

- (void)setSomePreference {
    /** Default preference. */
    self.backgroundColor = [UIColor blackColor];
    self.scrollEnabled = NO;
}

- (void)setSomeSubviews {
    ZXScrollLabel *upLabel = [ZXScrollLabel initDefault];
    self.upLabel = upLabel;
    [self addSubview:upLabel];
    
    ZXScrollLabel *downLabel = [ZXScrollLabel initDefault];
    self.downLabel = downLabel;
    [self addSubview:downLabel];
    
}


#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setSomePreference];
        [self setSomeSubviews];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)scrollTitle
                         type:(ZXScrollLabelViewType)scrollType
                     velocity:(NSTimeInterval)scrollVelocity
                        inset:(UIEdgeInsets)inset {
    if (self = [super init]) {
        _text = scrollTitle;
        _scrollType = scrollType;
        self.scrollVelocity = scrollVelocity;
        _scrollInset = inset;
    }
    return self;
}

#pragma mark - Factory Methods

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle {
    return [self scrollWithTitle:scrollTitle
                            type:ZXScrollLabelViewTypeLeftRight];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                           type:(ZXScrollLabelViewType)scrollType {
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:kScrollDefaultTimeInterval];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                       type:(ZXScrollLabelViewType)scrollType
                   velocity:(NSTimeInterval)scrollVelocity {
    return [self scrollWithTitle:scrollTitle
                            type:scrollType
                        velocity:scrollVelocity
                           inset:UIEdgeInsetsMake(0, 5, 0, 5)];
}

+ (instancetype)scrollWithTitle:(NSString *)scrollTitle
                       type:(ZXScrollLabelViewType)scrollType
                   velocity:(NSTimeInterval)scrollVelocity
                      inset:(UIEdgeInsets)inset {
    return [[self alloc] initWithTitle:scrollTitle
                                  type:scrollType
                              velocity:scrollVelocity
                                 inset:inset];
}

#pragma mark - Getter & Setter Methods

- (void)setText:(NSString *)text {
    _text = text;
    self.isArray = NO;
    [self resetScrollLabelView];
}

- (void)setScrollTexts:(NSArray *)scrollTexts{
    _scrollTexts = scrollTexts;
    _text = [scrollTexts firstObject];
    self.isArray = YES;
    [self resetScrollLabelView];
}

- (void)setScrollType:(ZXScrollLabelViewType)scrollType {
    if (_scrollType == scrollType) return;
    _scrollType = scrollType;
    self.scrollVelocity = _scrollVelocity;
    [self resetScrollLabelView];
}

- (void)setScrollVelocity:(NSTimeInterval)scrollVelocity {
    CGFloat velocity = scrollVelocity;
    if (scrollVelocity < 0.1) {
        velocity = 0.1;
    }else if (scrollVelocity > 10) {
        velocity = 10;
    }
    
    if (_scrollType == ZXScrollLabelViewTypeLeftRight || _scrollType == ZXScrollLabelViewTypeUpDown) {
        _scrollVelocity = velocity / 30.0;
    }else {
        _scrollVelocity = velocity;
    }
}

- (UIViewAnimationOptions)options {
    return UIViewAnimationOptionCurveEaseInOut;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self setupTextColor:textColor];
}

- (void)setScrollInset:(UIEdgeInsets)scrollInset {
    _scrollInset = scrollInset;
    [self setupSubviewsLayout];
}

- (void)setScrollSpace:(CGFloat)scrollSpace {
    _scrollSpace = scrollSpace;
    [self setupSubviewsLayout];
}

- (CGFloat)scrollSpace {
    if (_scrollSpace) return _scrollSpace;
    return 0.f;
}

- (NSArray *)scrollArray {
    if (_scrollArray) return _scrollArray;
    if (self.isArray) {
        return _scrollArray = _scrollTexts;
    }
    return _scrollArray = [self getSeparatedLinesFromLabel];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupSubviewsLayout];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.upLabel.textAlignment = textAlignment;
    self.downLabel.textAlignment = textAlignment;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.upLabel.font = font;
    self.downLabel.font = font;
    [self setupSubviewsLayout];
}

- (UIFont *)font {
    if (_font) return _font;
    return ZXScrollLabelFont;
}

#pragma mark - Custom Methods

- (void)setupInitial {
    switch (_scrollType) {
        case ZXScrollLabelViewTypeLeftRight:
            [self updateTextForScrollViewWithSEL:@selector(updateLeftRightScrollLabelLayoutWithText:labelType:)];
            break;
        case ZXScrollLabelViewTypeUpDown:
            [self updateTextForScrollViewWithSEL:@selector(updateUpDownScrollLabelLayoutWithText:labelType:)];
            break;
        case ZXScrollLabelViewTypeFold:
            break;
    }
}

/** 重置滚动视图 */
- (void)resetScrollLabelView {
    [self endup];
    [self setupSubviewsLayout];
    [self startup];
}

- (void)setupTextColor:(UIColor *)color {
    self.upLabel.textColor = color;
    self.downLabel.textColor = color;
}

- (void)setupTitle:(NSString *)title {
    self.upLabel.text = title;
    self.downLabel.text = title;
}

- (void)setupAttributeTitle:(NSAttributedString *)attributeTitle {
    self.text = attributeTitle.string;
    self.upLabel.attributedText = attributeTitle;
    self.downLabel.attributedText = attributeTitle;
}

#pragma mark - SubviewsLayout Methods

- (void)setupSubviewsLayout {
    switch (_scrollType) {
        case ZXScrollLabelViewTypeLeftRight:
            if (self.isArray) {
                [self setupInitial];
            }else {
                [self setupSubviewsLayout_LeftRight];
            }
            break;
        case ZXScrollLabelViewTypeUpDown:
            if (self.isArray) {
                [self setupInitial];
            }else {
                [self setupSubviewsLayout_UpDown];
            }
            break;
        case ZXScrollLabelViewTypeFold:
            [self setupSubviewsLayout_Fold];
            break;
            
        default:
            break;
    }
}

- (void)setupSubviewsLayout_LeftRight {
    CGFloat labelMaxH = self.frame.size.height;
    CGFloat labelMaxW = 0;
    CGFloat labelH = labelMaxH;
    __block CGFloat labelW = 0;
    self.contentOffset = CGPointZero;
    [self setupLRUDTypeLayoutWithTitle:_text maxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelW = MAX(size.width, self.frame.size.width);
        self.upLabel.frame = CGRectMake(self.scrollInset.left, 0, labelW, labelH);
        self.downLabel.frame = CGRectMake(CGRectGetMaxX(self.upLabel.frame) + self.scrollSpace, 0, labelW, labelH);
    }];
}

- (void)setupSubviewsLayout_UpDown {
    CGFloat labelMaxH = 0;
    CGFloat labelMaxW = self.frame.size.width - _scrollInset.left - _scrollInset.right;
    CGFloat labelW = labelMaxW;
    __block CGFloat labelH = 0;
    [self setupLRUDTypeLayoutWithTitle:_text maxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelH = MAX(size.height, self.frame.size.height);
        self.upLabel.frame = CGRectMake(self.scrollInset.left, 0, labelW, labelH);
        self.downLabel.frame = CGRectMake(self.scrollInset.left, CGRectGetMaxY(self.upLabel.frame) + self.scrollSpace, labelW, labelH);
    }];
}

- (void)setupSubviewsLayout_Fold {
    CGFloat labelW = self.frame.size.width - _scrollInset.left - _scrollInset.right;
    CGFloat labelX = _scrollInset.left;
    self.upLabel.frame = CGRectMake(labelX, 0, labelW, self.frame.size.height);
    self.downLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.upLabel.frame), labelW, self.frame.size.height);
}

- (void)setupLRUDTypeLayoutWithTitle:(NSString *)title
                             maxSize:(CGSize)size
                               width:(CGFloat)width
                              height:(CGFloat)height
                    completedHandler:(void(^)(CGSize size))completedHandler {
    CGSize scrollLabelS = [title boundingRectWithSize:size
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: self.font} context:nil].size;
    completedHandler(scrollLabelS);
    if (!self.isArray) {
        [self setupTitle:_text];
    }
}


- (void)updateLeftRightScrollLabelLayoutWithText:(NSString *)text labelType:(ZXScrollLabelType)type {
    CGFloat labelMaxH = self.frame.size.height;
    CGFloat labelMaxW = 0;
    CGFloat labelH = labelMaxH;
    __block CGFloat labelW = 0;
    [self setupLRUDTypeLayoutWithTitle:text maxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelW = MAX(size.width, self.frame.size.width);
        //开始布局
        if (type == ZXScrollLabelTypeUp) {
            self.upLabel.frame = CGRectMake(self.scrollInset.left, 0, labelW, labelH);
        }else if (type == ZXScrollLabelTypeDown) {
            self.downLabel.frame = CGRectMake(CGRectGetMaxX(self.upLabel.frame) + self.scrollSpace, 0, labelW, labelH);
        }
    }];
}


- (void)updateUpDownScrollLabelLayoutWithText:(NSString *)text labelType:(ZXScrollLabelType)type {
    CGFloat labelMaxH = 0;
    CGFloat labelMaxW = self.frame.size.width - _scrollInset.left - _scrollInset.right;
    CGFloat labelW = labelMaxW;
    __block CGFloat labelH = 0;
    [self setupLRUDTypeLayoutWithTitle:text maxSize:CGSizeMake(labelMaxW, labelMaxH) width:labelW height:labelH completedHandler:^(CGSize size) {
        labelH = MAX(size.height, self.frame.size.height);
        if (type == ZXScrollLabelTypeUp) {
            self.upLabel.frame = CGRectMake(self.scrollInset.left, 0, labelW, labelH);
        }else if (type == ZXScrollLabelTypeDown) {
            self.downLabel.frame = CGRectMake(self.scrollInset.left, CGRectGetMaxY(self.upLabel.frame) + self.scrollSpace, labelW, labelH);
        }
    }];
}

#pragma mark - Scrolling Operation Methods -- Public

- (void)beginScrolling {
    self.currentSentence = 0;
    if (self.isArray) {
        [self setupInitial];
    }
    [self startup];
}

- (void)endScrolling {
    [self endup];
}


#pragma mark - Scrolling Operation Methods -- Private

- (void)endup {
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
    self.scrollArray = nil;
}

- (void)startup {
    if (!self.text.length && !self.scrollArray.count) return;
    
    [self endup];
    
    if (_scrollType == ZXScrollLabelViewTypeFold) {
        _firstTime = YES;
        [self setupTitle:[self.scrollArray firstObject]];
        [self startWithVelocity:1];
    }else {
        [self startWithVelocity:self.scrollVelocity];
    }
}


- (void)startWithVelocity:(NSTimeInterval)velocity {
    if (!self.text.length && self.scrollArray.count) return;

    __weak typeof(self) weakSelf = self;
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:velocity repeat:YES block:^(NSTimer *timer) {
        ZXScrollLabelView *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateScrolling];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.scrollTimer forMode:NSRunLoopCommonModes];
}

#pragma mark - Scrolling Animation Methods

- (void)updateScrolling {
    switch (self.scrollType) {
        case ZXScrollLabelViewTypeLeftRight:
            [self updateScrollingType_LeftRight];
            break;
        case ZXScrollLabelViewTypeUpDown:
            [self updateScrollingType_UpDown];
            break;
        case ZXScrollLabelViewTypeFold:
            [self updateScrollingType_Fold];
            break;
        default:
            break;
    }
}

#pragma mark - ScrollLabelView + Methods

- (void)updateScrollingType_LeftRight {
    if (self.contentOffset.x >= (_scrollInset.left + self.upLabel.frame.size.width + self.scrollSpace)) {
        /** 更新 Label.text */
        if ((self.contentOffset.x > (_scrollInset.left + self.upLabel.frame.size.width) - self.frame.size.width) &&
            self.isArray) {
            [self updateTextForScrollViewWithSEL:@selector(updateLeftRightScrollLabelLayoutWithText:labelType:)];
        }
        [self endup];
        self.contentOffset = CGPointMake(_scrollInset.left + 1, 0);//x增加偏移量，防止卡顿
        [self startup];
    }else {
        self.contentOffset = CGPointMake(self.contentOffset.x + 1, self.contentOffset.y);
    }
    
}

- (void)updateScrollingType_UpDown {
    if (self.contentOffset.y >= (self.upLabel.frame.size.height + self.scrollSpace)) {
        /** 更新 Label.text */
        if ((self.contentOffset.y >= (self.upLabel.frame.size.height)) &&
            self.isArray) {
            [self updateTextForScrollViewWithSEL:@selector(updateUpDownScrollLabelLayoutWithText:labelType:)];
        }
        [self endup];
        self.contentOffset = CGPointMake(0, 2);//y增加偏移量，防止卡顿
        [self startup];
    }else {
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + 1);
    }
}

- (void)updateScrollingType_Fold {
    [self updateRepeatTypeWithOperation:^(NSTimeInterval velocity) {
        [self foldAnimationWithDelay:velocity];
    }];
}

- (void)updateRepeatTypeWithOperation:(void(^)(NSTimeInterval))operation {
    NSTimeInterval velocity = self.scrollVelocity;
    if (self.isFirstTime) {
        _firstTime = NO;
        [self endup];
        [self startWithVelocity:velocity];
    }
    operation(velocity);
}

- (void)flipAnimationWithDelay:(NSTimeInterval)delay {
    [UIView transitionWithView:self.upLabel duration:delay * 0.5 options:self.options animations:^{
        CGRect frame = self.upLabel.frame;
        frame.origin.y = 0 - frame.size.height;
        self.upLabel.frame = frame;
        [UIView transitionWithView:self.upLabel duration:delay * 0.5 options:self.options animations:^{
            CGRect frame = self.downLabel.frame;
            frame.origin.y = 0;
            self.downLabel.frame = frame;
        } completion:^(BOOL finished) {
            CGRect frame = self.upLabel.frame;
            frame.origin.y = self.frame.size.height;
            self.upLabel.frame = frame;
            ZXScrollLabel *tempLabel = self.upLabel;
            self.upLabel = self.downLabel;
            self.downLabel = tempLabel;
        }];
    } completion:nil];
}


- (void)foldAnimationWithDelay:(NSTimeInterval)delay {
    if (!self.scrollArray.count) return;
    [self updateScrollText];
    [self flipAnimationWithDelay:delay];
}

#pragma mark - Params For Array

void (*setter)(id, SEL, NSString *, ZXScrollLabelType);

- (void)updateTextForScrollViewWithSEL:(SEL)sel {
    if (!self.scrollArray.count) return;
    /** 更新文本 */
    [self updateScrollText];
    /** 执行 SEL */
    setter = (void (*)(id, SEL, NSString *, ZXScrollLabelType))[self methodForSelector:sel];
    setter(self, sel, self.upLabel.text, ZXScrollLabelTypeUp);
    setter(self, sel, self.downLabel.text, ZXScrollLabelTypeDown);
}

- (void)updateScrollText {
    NSInteger currentSentence = self.currentSentence;
    if (currentSentence >= self.scrollArray.count) currentSentence = 0;
    self.upLabel.text = self.scrollArray[currentSentence];
    currentSentence ++;
    if (currentSentence >= self.scrollArray.count) currentSentence = 0;
    self.downLabel.text = self.scrollArray[currentSentence];
    
    self.currentSentence = currentSentence;
}

#pragma mark - Text-Separator

- (NSArray *)getSeparatedLinesFromLabel {
    if (!_text) return nil;
    
    NSString *text = _text;
    UIFont *font = self.font;
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,self.upLabel.frame.size.width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    CFRelease(myFont);
    CFRelease(frameSetter);
    CFRelease(frame);
    CFRelease(path);
    
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    
    return (NSArray *)linesArray;
}

- (void)dealloc {
    [self endup];
}

@end

@implementation ZXScrollLabelView (TitleArray)

#pragma mark - TitleArray Methods

- (instancetype)initWithTextArray:(NSArray *)scrollTexts
                             type:(ZXScrollLabelViewType)scrollType
                         velocity:(NSTimeInterval)scrollVelocity
                            inset:(UIEdgeInsets)inset {
    if (self = [super init]) {
        self.isArray = YES;
        _scrollTexts = [scrollTexts copy];
        _text = [_scrollTexts firstObject];
        _scrollType = scrollType;
        self.scrollVelocity = scrollVelocity;
        _scrollInset = inset;
    }
    return self;
}

+ (instancetype)scrollWithTextArray:(NSArray *)scrollTexts
                               type:(ZXScrollLabelViewType)scrollType
                           velocity:(NSTimeInterval)scrollVelocity
                              inset:(UIEdgeInsets)inset {
    return [[self alloc] initWithTextArray:scrollTexts
                                      type:scrollType
                                  velocity:scrollVelocity
                                     inset:inset];
}

@end
