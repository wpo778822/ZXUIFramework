//
//  ZXTextField.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, ZXTextFieldConstraintEntryType) {
    ZXTextFieldConstraintEntryTypeNone = 0, //无限制
    ZXTextFieldConstraintEntryTypeNumber = 1 << 0,  //数字
    ZXTextFieldConstraintEntryTypeChinese = 1 << 1,   //中文
    ZXTextFieldConstraintEntryTypeCharacter = 1 << 2,     //字母
    ZXTextFieldConstraintEntryTypePoint = 1 << 3,//小数点
};

@class ZXTextField;

@protocol ZXTextFieldDelegate <UITextFieldDelegate>

@optional

/**
 *  配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。
 *  @warning 在 UIControlEventEditingChanged 里也会触发文字长度拦截，由于此时 textField 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementString 这两个参数的值也会比较特殊，具体请看参数讲解。
 *
 *  @param textField 触发的 textField
 *  @param range 要变化的文字的位置，如果在 UIControlEventEditingChanged 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
 *  @param replacementString 要变化的文字，如果在 UIControlEventEditingChanged 里，这里永远传入 nil。
 */
- (void)textField:(ZXTextField *)textField didPreventTextChangeInRange:(NSRange)range replacementString:(NSString *)replacementString;

@end

@interface ZXTextField : UITextField

@property(nonatomic, weak) id<ZXTextFieldDelegate> zxDelegate;

/**
 *  修改 placeholder 的颜色，默认是 UIColorPlaceholder。
 */
@property(nonatomic, strong) UIColor *placeholderColor;

/**
 *  文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
 *
 *  默认为 TextFieldTextInsets
 */
@property(nonatomic, assign) UIEdgeInsets textInsets;


/**
 限制输入类型 ，默认 ZXTextFieldConstraintEntryTypeNone（可多选）
 */
@property(nonatomic, assign) ZXTextFieldConstraintEntryType constraintEntryType;

/**
 *  当通过 `setText:`、`setAttributedText:`等方式修改文字时，是否应该自动触发 UIControlEventEditingChanged 事件及 UITextFieldTextDidChangeNotification 通知。
 *
 *  默认为YES（注意系统的 UITextField 对这种行为默认是 NO）
 */
@property(nonatomic, assign) BOOL shouldResponseToProgrammaticallyTextChanges;

/**
 *  显示允许输入的最大文字长度，默认为 NSUIntegerMax，也即不限制长度。
 */
@property(nonatomic, assign) NSUInteger maximumTextLength;


/**
 是否能被取消第一响应   默认为YES
 */
@property(nonatomic, assign) BOOL canResign;

@end
