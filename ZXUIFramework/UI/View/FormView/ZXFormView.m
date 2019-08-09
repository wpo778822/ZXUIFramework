//
//  ZXFormView.m
//  XYLQManager
//
//  Created by 黄勤炜 on 2018/8/15.
//  Copyright © 2018年 sino. All rights reserved.
//

#import "ZXFormView.h"
#import "ZXUtilHelper.h"
#import "ZXMacro.h"
#import <Masonry.h>
#define MAX_LENGTH 5
@interface ZXFormLabel : UILabel
@property (nonatomic, assign) BOOL isJustified;
- (void)justifiedtWithWidth:(CGFloat)labelWidth;
@end

@implementation ZXFormLabel

- (void)justifiedtWithWidth:(CGFloat)labelWidth{
    if(!labelWidth || labelWidth <= 0.f) return;
    //自适应高度
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName :self.font} context:nil].size;
    CGFloat margin = (labelWidth - textSize.width)/(self.text.length - 1);
    NSNumber *number = [NSNumber numberWithFloat:margin];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:self.text];
    //字间距 :NSKernAttributeName
    [attribute addAttribute:NSKernAttributeName value:number range:NSMakeRange(0, self.text.length - 1)];
    self.attributedText = attribute;
}

- (void)layoutSubviews{
    if (!CGSizeIsEmpty(self.frame.size) && !_isJustified && self.text.length < MAX_LENGTH) {
        [self justifiedtWithWidth:self.frame.size.width];
        _isJustified = YES;
    }
}

@end

@interface ZXForm : UIView
@property (nonatomic, strong) ZXFormLabel *titleLabel;
@property (nonatomic, strong) UILabel *spaceLabel;
@property (nonatomic, strong) ZXMarqueeLabel *infoLabel;
- (instancetype)initWithTitle:(NSString *)key space:(NSString *)space info:(NSString *)info;
@end
@implementation ZXForm

- (instancetype)initWithTitle:(NSString *)key space:(NSString *)space info:(NSString *)info{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initUI];
        [self setTitle:key space:space info:info];
    }
    return self;
}

- (void)initUI{
    ZXFormLabel *titleLabel = [[ZXFormLabel alloc]init];
    self.titleLabel = titleLabel;
    UILabel *spaceLabel = [[UILabel alloc]init];
    self.spaceLabel = spaceLabel;
    ZXMarqueeLabel *infoLabel = [[ZXMarqueeLabel alloc]init];
    self.infoLabel = infoLabel;
    [self addSubview:titleLabel];
    [self addSubview:spaceLabel];
    [self addSubview:infoLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self);
        make.width.mas_equalTo(0);
    }];
    [spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.leading.equalTo(titleLabel.mas_trailing);
    }];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing);
        make.centerY.equalTo(titleLabel);
        make.leading.equalTo(titleLabel.mas_trailing).offset(10);
    }];
}

- (void)setTitle:(NSString *)title space:(NSString *)space info:(NSString *)info{
    self.titleLabel.text = title ?:@"";
    self.spaceLabel.text = space ?:@"";
    self.infoLabel.text = info ?:@"";
}

@end
@interface ZXFormView()
@property (nonatomic, assign) CGFloat linkBreakIndex;

@end
@implementation ZXFormView

- (instancetype)initWithTitleArray:(NSArray *)titleArray linkBreakIndex:(NSInteger)index{
    self = [super init];
    if (self) {
        self.linkBreakIndex = index;
        self.backgroundColor = [UIColor whiteColor];
        [self setDefault];
        [self initWithTitleArray:titleArray infoArray:nil];
    }
    return self;
}

- (instancetype)initWithTitleArray:(NSArray *)titleArray{
    return [self initWithTitleArray:titleArray linkBreakIndex:-1];
}

- (void)setDefault{
    _spaceString = @"：";
    _verticalOffset = 10;
    _horizontalOffset = 10;
    _titleFont = [UIFont systemFontOfSize:12];
    _infoFont = [UIFont systemFontOfSize:12];
    _titleColor = ZXRemarkColor;
    _infoColor = [UIColor blackColor];
}

- (void)initWithTitleArray:(NSArray *)keyArray infoArray:(NSArray *)infoArray{
    __block NSMutableArray<ZXMarqueeLabel *> *array = @[].mutableCopy;
    
    [keyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZXForm *form = [[ZXForm alloc]initWithTitle:obj space:self.spaceString info:infoArray ? infoArray[idx]:nil];
        form.titleLabel.font      = self.titleFont;
        form.titleLabel.textColor = self.titleColor;
        form.spaceLabel.font      = self.titleFont;
        form.spaceLabel.textColor = self.titleColor;
        form.infoLabel.font       = self.infoFont;
        form.infoLabel.textColor  = self.infoColor;
        [array addObject:form.infoLabel];
        [self addSubview:form];
    }];
    

    self.titleFont = _titleFont;//初始化标题
    
    self.infoLabelArray = array.copy;
    
    [self makeLayout];

}

- (void)makeLayout{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0) {
                make.top.equalTo(self.mas_top);
            }
            if (self.subviews.count == 1) {
                make.leading.trailing.bottom.equalTo(self);
            }
            
            if (self.linkBreakIndex > 0 && self.linkBreakIndex <= idx) {
                if (idx % 2 != 0 && self.linkBreakIndex == idx) {
                    [self.subviews[idx - 1] mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.trailing.equalTo(self);
                    }];
                }
                make.top.equalTo(self.subviews[idx - 1].mas_bottom).offset(self.verticalOffset);
                make.leading.trailing.equalTo(self);
                if (idx == self.subviews.count - 1) {
                    make.bottom.equalTo(self.mas_bottom);
                }
                return;
            }
            if (idx % 2 == 0) {
                if (idx != 0 ) {
                    make.top.equalTo(self.subviews[idx - 1].mas_bottom).offset(self.verticalOffset);
                }
                make.leading.equalTo(self.mas_leading);
                if(idx < self.subviews.count - 1)make.trailing.equalTo(self.subviews[idx + 1].mas_leading).offset(-self.horizontalOffset).priorityHigh();
            }else{
                make.leading.equalTo(self.mas_leading).offset(SCREEN_WIDTH * 0.4);
                make.centerY.equalTo(self.subviews[idx - 1]);
                make.trailing.equalTo(self.mas_trailing);
            }
            
            if (idx == self.subviews.count - 1) {
                make.bottom.equalTo(self.mas_bottom);
                if (idx % 2 == 0) {
                    make.trailing.equalTo(self.mas_trailing);
                }
            }
        }];
    }];
}


#pragma mark get/set

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    __block CGFloat maxWidth = 0.f;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof ZXForm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.titleLabel.text length] > MAX_LENGTH)return;
        CGFloat width = [ZXUtilHelper computeString:obj.titleLabel.text baseFont:titleFont];
        maxWidth = maxWidth > width ? maxWidth : width;
    }];
    
    __block CGFloat lastWidth = maxWidth;
    
    if (self.subviews.count % 2 != 0) {
        lastWidth = [ZXUtilHelper computeString:((ZXForm *)self.subviews.lastObject).titleLabel.text baseFont:titleFont];
        if(maxWidth > lastWidth) lastWidth = maxWidth;
    }

    [self.subviews enumerateObjectsUsingBlock:^(__kindof ZXForm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = idx == self.subviews.count - 1 ? lastWidth : maxWidth;
        if (self.linkBreakIndex > 0 && self.linkBreakIndex <= idx) {
            CGFloat _width = [ZXUtilHelper computeString:obj.titleLabel.text baseFont:titleFont];
            width = _width > width ? _width : width;
        }
        obj.titleLabel.font = titleFont;
        obj.spaceLabel.font = titleFont;
        [obj.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if(width > 0)make.width.mas_equalTo(width);
        }];
    }];
}

- (void)setInfoFont:(UIFont *)infoFont{
    _infoFont = infoFont;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof ZXForm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.infoLabel.font = infoFont;
    }];
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof ZXForm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.spaceLabel.textColor = titleColor;
        obj.titleLabel.textColor = titleColor;
    }];
}

- (void)setInfoColor:(UIColor *)infoColor{
    _infoColor = infoColor;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof ZXForm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.infoLabel.textColor = infoColor;
    }];
}

- (void)setSpaceString:(NSString *)spaceString{
    _spaceString = spaceString;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof ZXForm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.spaceLabel.text = spaceString;
    }];
}

- (void)setHorizontalOffset:(CGFloat)horizontalOffset{
    _horizontalOffset = horizontalOffset;
    [self makeLayout];
}

- (void)setVerticalOffset:(CGFloat)verticalOffset{
    _verticalOffset = verticalOffset;
    [self makeLayout];
}

#pragma mark 方法

- (void)inputInfoTextWithArray:(NSArray<NSString *> *)array{
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        self.infoLabelArray[idx].text = obj;
    }];
}

- (void)setIndexHidden:(BOOL)hidden index:(NSInteger)index{
    if (index >= 0 && index < self.subviews.count) {
        ZXForm *form = self.subviews[index];
        form.titleLabel.hidden = hidden;
    }
}

- (void)requestToStartAnimation{
    [_infoLabelArray enumerateObjectsUsingBlock:^(ZXMarqueeLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj requestToStartAnimation];
    }];
}

- (void)requestToStopAnimation{
    [_infoLabelArray enumerateObjectsUsingBlock:^(ZXMarqueeLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj requestToStopAnimation];
    }];
}


@end
