//
//  ZXartTitleScrollView.m
//  ZXartApp
//
//  Created by Apple on 2017/4/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXTitleScrollView.h"
#import "ZXMacro.h"
#import "UIView+ZXUI.h"
#import <Masonry.h>

@interface ZXTitleScrollView()
@property (nonatomic, assign) NSInteger itemCount;
@end
@implementation ZXTitleScrollView

- (instancetype)initWithTitles:(NSArray *)titles selected:(SelectedBlock)selected{
    self = [super init];
    if (self) {
        _selected = selected;
        self.backgroundColor = [UIColor whiteColor];
        _selectedTextColor   = ZXBlueColor;
        _textColor           = ZXRemarkColor;
        _separatorLineColor  = ZXBlueColor;
        _fontSize            = DEVICE_TYPE_IPHONE_5 ? 16.0:17.0;
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        _scrollView = scrollView;
        [self addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.bottom.equalTo(self);
        }];
        scrollView.showsHorizontalScrollIndicator = NO;
        _buttonArray = @[].mutableCopy;
        WeakSelf(weakSelf)
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *title = obj;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.adjustsImageWhenHighlighted = NO;
            btn.tag = 100 + idx;
            [scrollView addSubview:btn];
            [weakSelf.buttonArray addObject:btn];
            [btn setTitle:title forState:UIControlStateNormal];
            btn.titleLabel.font = UIFontWithSize(weakSelf.fontSize);
            [btn setTitleColor:weakSelf.textColor forState:UIControlStateNormal];
            [btn setTitleColor:weakSelf.selectedTextColor forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            if (idx == 0) {
                weakSelf.selectedBtn = btn;
                weakSelf.selectedBtn.selected = YES;
            }
        }];
        _selectedLineH           = SCALE_SET(3);
        _itemCount               = titles.count;
        self.itemEdge            = 40.0;
        self.isShowShadow        = YES;
        self.isShowSeparatorLine = YES;
    }
    return self;
}

- (void)setContinuousItemConstraints:(UIView *)view
                                path:(NSInteger)itemPath
                               count:(NSInteger)totalCounts
                              offset:(CGFloat)itemOffset{
    if (itemPath == 0) {
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.superview.mas_centerY);
            make.leading.equalTo(view.superview).offset(itemOffset == 10.0 ? 10 : itemOffset / 2);
            make.bottom.equalTo(view.superview);
        }];
    }else if (itemPath == totalCounts - 1){
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo([view.superview viewWithTag:view.tag - 1]);
            make.leading.equalTo([view.superview viewWithTag:view.tag - 1].mas_trailing).offset(itemOffset);
            make.trailing.equalTo(view.superview.mas_trailing).offset(itemOffset == 10.0 ? -10 : -itemOffset / 2);
        }];
    }else{
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo([view.superview viewWithTag:view.tag - 1]);
            make.leading.equalTo([view.superview viewWithTag:view.tag - 1].mas_trailing).offset(itemOffset);
        }];
    }
}

- (void)remakeSelected{
    if (_isShowSeparatorLine) {
        WeakSelf(weakSelf)
        [_selectedView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(weakSelf.selectedBtn.titleLabel);
            make.trailing.equalTo(weakSelf.selectedBtn.titleLabel);
            make.bottom.equalTo(self).offset(weakSelf.selectedViewOffest);
            make.height.equalTo(@(weakSelf.selectedLineH));
        }];
    }
}

- (void)btnClick:(UIButton *)sender{
    [self topBtnClick:sender noTouch:NO];
}

- (void)topBtnClick:(NSInteger)index{
    [self topBtnClick:[self viewWithTag:100 + index] noTouch:YES];
}

- (void)topBtnClick:(UIButton *)sender noTouch:(BOOL)touch{
    if (_selectedBtn == sender) return;
    if (sender == nil) sender = _selectedBtn;
    if (_scrollView.contentSize.width == 0) {
        [self layoutIfNeeded];
    }
    _selectedBtn.selected = NO;
    _selectedBtn          = sender;
    _selectedBtn.selected = YES;
    CGFloat offsetx       = [self viewWithTag:sender.tag - 1].frame.origin.x;
    CGFloat offsetMax     = _scrollView.contentSize.width  - self.frame.size.width;
    
    // 触底回滚
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax){
        offsetx = offsetMax;
    }else if (offsetx == offsetMax){
        offsetx -= 0.01;
    }
    CGPoint offset = CGPointMake((offsetx == 0 || offsetx == offsetMax) ? offsetx : offsetx - _itemEdge / 2, _scrollView.contentOffset.y);
    [self remakeSelected];
    WeakSelf(weakSelf)
    [UIView animateWithDuration:0.5 delay:0.f usingSpringWithDamping:0.85 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (!touch && weakSelf.selected) {
            weakSelf.selected(sender.tag - 100);
        }
        if(!CGSizeEqualToSize(weakSelf.scrollView.contentSize, CGSizeZero))[weakSelf.scrollView setContentOffset:offset animated:NO];
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)remakeConstraints{
    WeakSelf(weakSelf)
    [_buttonArray enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf.scrollView);
            CGFloat edge = 1.0 / weakSelf.itemCount;
            make.centerX.equalTo(weakSelf).multipliedBy(edge + (edge * 2) * idx);
        }];
    }];
}

-(void)setIsShowShadow:(BOOL)isShowShadow{
    _isShowShadow = isShowShadow;
    if (isShowShadow) {
        [self addShadowWithColor:[UIColor colorUsingHexString:@"#cde1f4"] radius:2.5 offset:CGSizeMake(0, 3) opacity:0.8 bounds:NO];
    }else{
        [self addShadowWithColor:[UIColor colorUsingHexString:@"#d7d9de"] radius:0 offset:CGSizeZero opacity:0 bounds:NO];
    }
}

- (void)setIsShowSeparatorLine:(BOOL)isShowSeparatorLine{
    _isShowSeparatorLine = isShowSeparatorLine;
    if (_isShowSeparatorLine) {
        UIView *selectedView = [[UIView alloc] init];
        self.selectedView   = selectedView;
        selectedView.backgroundColor = _separatorLineColor;
        [self.scrollView addSubview:selectedView];
        [self remakeSelected];
    }else{
        [self.selectedView removeFromSuperview];
        self.selectedView = nil;
    }
}

- (void)setSelectedViewOffest:(CGFloat)selectedViewOffest{
    _selectedViewOffest = selectedViewOffest;
    [self remakeSelected];
}

- (void)setItemEdge:(CGFloat)itemEdge{
    _itemEdge = itemEdge;
    WeakSelf(weakSelf)
    [_buttonArray enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf setContinuousItemConstraints:obj path:idx count:weakSelf.itemCount offset:weakSelf.itemEdge];
    }];
}

- (void)setSelectedLineH:(CGFloat)selectedLineH{
    _selectedLineH = selectedLineH;
    [self remakeSelected];
}

- (void)setSeparatorLineColor:(UIColor *)separatorLineColor{
    _separatorLineColor = separatorLineColor;
    _selectedView.backgroundColor = separatorLineColor;
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    [_buttonArray enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitleColor:textColor forState:UIControlStateNormal];
    }];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor{
    _selectedTextColor = selectedTextColor;
    [_buttonArray enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitleColor:selectedTextColor forState:UIControlStateSelected];
    }];
}

- (void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    [_buttonArray enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.titleLabel.font = UIFontWithSize(fontSize);
    }];
}

-(NSInteger)currentPage{
    return _selectedBtn.tag - 100;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(250, 40.0);
}

@end
