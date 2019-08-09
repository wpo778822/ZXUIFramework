//
//  ZXOptionButton.m
//  XYLQ
//
//  Created by mac on 2018/8/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZXOptionButton.h"
#import "ZXMarqueeLabel.h"
#import "ZXPopupMenu.h"
#import "ZXMacro.h"
#import <Masonry.h>
@interface ZXOptionButton()<ZXPopupMenuDelegate>
@property(nonatomic, strong) ZXMarqueeLabel *displayLabel;
@property (nonatomic, strong) UIButton *showOptionButton;
@property (nonatomic, weak) ZXPopupMenu *listMenu;
@property (nonatomic, assign) CGRect selfFrame;
@end
@implementation ZXOptionButton

#pragma mark - 键盘关闭函数
- (void)keyboardHide:(NSNotification *)notif{
    _listMenu.isShowShadow = NO;
    _listMenu.borderWidth = 0.5;
    self.listMenu.frame = _selfFrame;
}

#pragma mark - 键盘出现函数
- (void)keyboardWasShown:(NSNotification *)notif{
    if (CGRectEqualToRect(_selfFrame, CGRectZero)) {
        _selfFrame = self.listMenu.frame;
    }
    _listMenu.isShowShadow = YES;
    _listMenu.borderWidth = 0.f;
    self.listMenu.frame = _selfFrame;
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    CGRect frame = self.listMenu.frame;
    CGFloat offset =  keyboardSize.height - (SCREEN_HEIGHT  - frame.origin.y - self.listMenu.frame.size.height) + SCALE_SET(20);
    frame.origin.y -= offset;
    self.listMenu.frame = frame;
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)notification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    //注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardHide:) name: UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc{
    [self removeNotification];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initUI];
        [self setDefault];
    }
    return self;
}

- (void)setDefault{
    self.optionTitleFont = UIFontWithSize(15);
    self.placeholderColor = ZXRemarkColor;
    self.selectTitleColor = ZXTitleColor;
    self.showSearchBar = NO;
    self.textAlignment = NSTextAlignmentLeft;
    self.placeholder = @"-请选择-";
}

- (void)initUI{
    ZXMarqueeLabel *displayLabel = [[ZXMarqueeLabel alloc]init];
    displayLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:displayLabel];
    self.displayLabel = displayLabel;
    displayLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOption)];
    [displayLabel addGestureRecognizer:singleTapGestureRecognizer];
    [displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(5);
        make.centerY.equalTo(self);
    }];
    
    UIButton *showOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:showOptionButton];
    self.showOptionButton = showOptionButton;
    showOptionButton.adjustsImageWhenHighlighted = NO;
    [showOptionButton setImage:UIImageWithName(@"zhankai") forState:UIControlStateNormal];
    [showOptionButton setImage:UIImageWithName(@"shouqi") forState:UIControlStateSelected];
    [showOptionButton addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
    [showOptionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(displayLabel.mas_trailing).offset(5);
        make.centerY.equalTo(displayLabel);
        make.trailing.equalTo(self).offset(-5);
        make.width.equalTo(showOptionButton.mas_height);
    }];
}

- (void)showOption{
    if (self.showOptionButton.isSelected) {
        [self.listMenu dismiss];
    }else{
        [self showList];
    }
    self.showOptionButton.selected = !self.showOptionButton.isSelected;
}

- (void)zxPopupMenuBeganDismiss{
    self.showOptionButton.selected = NO;
}

- (void)showList{
    ZX_SAFE_SEND_MESSAGE(_delegate, beginShowOptionListWithOptionButton:){
        [_delegate beginShowOptionListWithOptionButton:self];
    }
    WeakSelf(weakSelf)
   [ZXPopupMenu showRelyOnView:self titles:self.titleArray icons:nil menuWidth:self.frame.size.width otherSettings:^(ZXPopupMenu *popupMenu) {
        popupMenu.itemHeight = 40;
        popupMenu.maxVisibleCount = 6;
        popupMenu.cornerRadius = 0.0;
        popupMenu.textAlignment = weakSelf.textAlignment;
        popupMenu.backColor = [UIColor whiteColor];
        popupMenu.textColor = weakSelf.selectTitleColor;
        popupMenu.fontSize = 12;
        popupMenu.isShowShadow = NO;
        popupMenu.showMaskView = NO;
        popupMenu.borderWidth = 0.5;
        popupMenu.dismissOnTouchOutside = NO;
        popupMenu.priorityDirection = ZXPopupMenuPriorityDirectionNone;
        popupMenu.arrowDirection = ZXPopupMenuArrowDirectionNone;
        popupMenu.delegate = weakSelf;
        popupMenu.animation = ZXPopupMenuAnimationFade;
        popupMenu.showSearchBar = weakSelf.showSearchBar;
        weakSelf.listMenu = popupMenu;
    }];
}

- (void)zxPopupMenuDidSelectedAtIndex:(NSInteger)index zxPopupMenu:(ZXPopupMenu *)zxPopupMenu{
    self.showOptionButton.selected = NO;
    NSInteger fixIndex =  [self.titleArray indexOfObject:zxPopupMenu.displayTitles[index]];    
    self.selectTitle = self.titleArray[fixIndex];
    ZX_SAFE_SEND_MESSAGE(_delegate, didSelectRow:optionButton:){
        [_delegate didSelectRow:fixIndex optionButton:self];
    }
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    [self setOptionLabelColor];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    _placeholderColor = placeholderColor;
    [self setOptionLabelColor];
}

- (void)setSelectTitleColor:(UIColor *)selectTitleColor{
    _selectTitleColor = selectTitleColor;
}

- (void)setShowSearchBar:(BOOL)showSearchBar{
    _showSearchBar = showSearchBar;
    if (showSearchBar) {
        [self notification];
    }else{
        [self removeNotification];
    }
}

- (void)setOptionTitleFont:(UIFont *)optionTitleFont{
    _optionTitleFont = optionTitleFont;
    _displayLabel.font = optionTitleFont;
}

- (void)setSelectTitle:(NSString *)selectTitle{
    _selectTitle = selectTitle;
    [self setOptionLabelColor];
}

- (void)setOptionLabelColor{
    if (!_selectTitle) {
        _displayLabel.text = _placeholder;
        _displayLabel.textColor = _placeholderColor;
    }else{
        _displayLabel.text = _selectTitle;
        _displayLabel.textColor = _selectTitleColor;
    }
}


@end
