//
//  ZXField.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXInputField;


/**
 块回调

 @param field 实例化对象
 */
typedef void (^Complete)(ZXInputField *field);

/**
 占位提示信息显示位置

 - ZXInputFieldPlaceholderAlignmentLeft: 居左
 - ZXInputFieldPlaceholderAlignmentRight: 居右
 - ZXInputFieldPlaceholderAlignmentCenter: 居中
 */
typedef NS_ENUM(NSInteger , ZXInputFieldPlaceholderAlignment) {
    ZXInputFieldPlaceholderAlignmentLeft = 1,
    ZXInputFieldPlaceholderAlignmentRight,
    ZXInputFieldPlaceholderAlignmentCenter
};

/**
 字符正则状态

 - ZXUndefined: 无状态（1·相关代理没有实现 2·没有编辑过）
 - ZXCorrectContent: 正确
 - ZXIncorrectContent: 不正确
 */
typedef NS_ENUM(NSInteger , ZXValidationOfContent) {
    ZXUndefined = 0,
    ZXCorrectContent,
    ZXIncorrectContent
};


/**
 键盘辅助视图响应模式（当accessoryView被设置时生效）

 - ZXAccessoryViewModeLast: 响应最后一个子输入框
 - ZXAccessoryViewModeAlways: 响应每一个子输入框
 */
typedef NS_ENUM(NSInteger , ZXAccessoryViewMode) {
    ZXAccessoryViewModeLast = 0,
    ZXAccessoryViewModeAlways
};


/**
 限制输入字符种类 默认无限制，可复选

 - ZXConstraintEntryTypeNone: 无限制
 - ZXConstraintEntryTypeNumber: 限制只能数字 1234567890
 - ZXConstraintEntryTypeChinese: 限制只能中文（beta）
 - ZXConstraintEntryTypeCharacter: 限制只能输入英文字母 a-z/A-Z
 */
typedef NS_OPTIONS(NSUInteger, ZXConstraintEntryType) {
    ZXConstraintEntryTypeNone = 0,
    ZXConstraintEntryTypeNumber = 1 << 0,
    ZXConstraintEntryTypeChinese = 1 << 1,
    ZXConstraintEntryTypeCharacter = 1 << 2,
};

/**
 基本代理方法
 */
@protocol ZXFieldDelegate <NSObject>

@optional

/**
 文字输入中
 */
- (void)inputFieldTextChanged:(ZXInputField *)inputField;


/**
 结束输入

 */
- (void)inputFieldHasEndedEditing:(ZXInputField *)inputField;


/**
 正则
 @param text 正则状态显示文字
 @return 是否通过正则
 */
- (BOOL)inputField:(ZXInputField *)inputField containsValidText:(NSString *)text;

@end


/**
 为构建ZXField的基本数据模型（目前显示模式为横向 < 1 , 2 ,3 ,4 ,... >）
 */
@protocol ZXFieldDataSource <NSObject>

@required

/**
 需要的输入框数量（等比布局）

 */
- (NSUInteger)numberOfSectionsInTextField:(ZXInputField *)zxField;


/**
 每个输入框的限制输入字符 (目前长度取样string.length)

 */
- (NSUInteger)numberOfCharactersInSection:(NSInteger)section inTextField:(ZXInputField *)zxField;

@end

@interface ZXInputField : UIView
#pragma mark property  -----属性
@property (weak, nonatomic) id <ZXFieldDataSource> dataSource;
@property (weak, nonatomic) id <ZXFieldDelegate> delegate;

/**
 当前输入文本，包含全部子输入框
 */
@property (strong, nonatomic) NSString *text;

/**
 键盘类型（类比UITextField中参数）
 */
@property (assign, nonatomic) UIKeyboardType keyboardType;

/**
 键盘返回键（类比UITextField中参数）
 */
@property (assign, nonatomic) UIReturnKeyType returnKeyType;

/**
 是否密文（类比UITextField中参数）
 */
@property(nonatomic,getter=isSecureTextEntry) BOOL secureTextEntry;

/**
 占位提示信息字体
 */
@property (strong, nonatomic) UIFont *placeholderFont;

/**
 占位提示信息文本（未有初始值）
 */
@property (strong, nonatomic) NSString *placeholderText;

/**
 占位提示信息未编辑状态字体颜色
 */
@property (strong, nonatomic) UIColor *placeholderFontColor;

/**
 占位提示信息编辑状态字体颜色
 */
@property (strong, nonatomic) UIColor *upperPlaceholderFontColor;

/**
 输入框字体
 */
@property (strong, nonatomic) UIFont *textFont;

/**
 输入框字体颜色
 */
@property (strong, nonatomic) UIColor *textFontColor;

/**
 输入框着色
 */
@property (strong, nonatomic) UIColor *tintColor;

/**
 输入框边框大小  1.0
 */
@property (assign, nonatomic) CGFloat borderWidth;

/**
 未编辑状态输入框边框颜色
 */
@property (strong, nonatomic) UIColor *borderColor;

/**
 编辑状态输入框边框颜色
 */
@property (strong, nonatomic) UIColor *upperBorderColor;

/**
 输入框未编辑状态下划线颜色
 */
@property (strong, nonatomic) UIColor *underliningColor;

/**
 输入框编辑状态下划线颜色
 */
@property (strong, nonatomic) UIColor *upperUnderliningColor;

/**
 正则通过提示信息文本
 */
@property (strong, nonatomic) NSString *correctLabelText;

/**
 正则通过状态输入框边框颜色
 */
@property (strong, nonatomic) UIColor *correctStateBorderColor;

/**
 正则通过状态占位提示信息颜色
 */
@property (strong, nonatomic) UIColor *correctStatePlaceholderLabelTextColor;

/**
 正则未通过提示信息文本
 */
@property (strong, nonatomic) NSString *incorrectLabelText;

/**
 正则未通过状态输入框边框颜色
 */
@property (strong, nonatomic) UIColor *incorrectStateBorderColor;

/**
 正则未通过状态占位提示信息颜色
 */
@property (strong, nonatomic) UIColor *incorrectStatePlaceholderLabelTextColor;

/**
 键盘左视图（类比UITextField中参数，当子输入框为 1 时生效）
 */
@property (strong, nonatomic) UIView *leftView;

/**
 键盘辅助视图 （类比UITextField中参数accessoryView）
 */
@property (strong, nonatomic) UIView *accessoryView;

/**
 字符正则状态
 */
@property (assign, nonatomic, readonly) ZXValidationOfContent isCorrect;

/**
 键盘辅助视图响应模式
 */
@property (assign, nonatomic) ZXAccessoryViewMode accessoryViewMode;

/**
 占位提示信息显示位置(当输入框唯有1个时与textAlignment相同)
 */
@property (assign, nonatomic) ZXInputFieldPlaceholderAlignment placeholderAlignment;


/**
 限制文本输入类型（默认无限制）
 */
@property (assign, nonatomic) ZXConstraintEntryType constraintEntryType;


#pragma mark method  -----方法
/**
 实例化方法 - 初始样式-带边框

 @param dataSource 数据源
 @param delegate 代理
 @return zxfield 实例化对象
 */
+ (ZXInputField *)borderedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                delegate:(id<ZXFieldDelegate>)delegate
                                   block:(Complete)block;


/**
 实例化方法 - 初始样式-无边框只留下划线 (borderColor = nil)
 
 @param dataSource 数据源
 @param delegate 代理
 @return zxfield 实例化对象
 */
+ (ZXInputField *)underlinedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                  delegate:(id<ZXFieldDelegate>)delegate
                                     block:(Complete)block;

/**
 实例化方法 - 初始样式-带边框,带占位提示信息

 @param dataSource 数据源
 @param delegate 代理
 @param placeholderText 占位提示信息
 @return zxfield 实例化对象
 */
+ (ZXInputField *)borderedFieldWithWithDataSource:(id<ZXFieldDataSource> )dataSource
                                    delegate:(id<ZXFieldDelegate>)delegate
                             placeholderText:(NSString *)placeholderText
                                       block:(Complete)block;

/**
 实例化方法 - 初始样式-配置边框,带占位提示信息

 @param dataSource 数据源
 @param delegate 代理
 @param placeholderText 占位提示信息
 @param borderWidth 边框大小
 @param borderColor 未编辑状态边框颜色
 @param upperBorderColor 编辑状态边框颜色
 @return zxfield 实例化对象
 */
+ (ZXInputField *)borderedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                delegate:(id<ZXFieldDelegate>)delegate
                         placeholderText:(NSString *)placeholderText
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(UIColor *)borderColor
                        upperBorderColor:(UIColor *)upperBorderColor
                                   block:(Complete)block;

/**
 实例化方法 - 初始样式-配置下划线

 @param dataSource 数据源
 @param delegate 代理
 @param underliningHeight 下划线大小 equal borderWidth
 @param underliningColor 下划线颜色
 @return zxfield 实例化对象
 */
+ (ZXInputField *)underlinedFieldWithDataSource:(id<ZXFieldDataSource>)dataSource
                                  delegate:(id<ZXFieldDelegate>)delegate
                         underliningHeight:(CGFloat)underliningHeight
                          underliningColor:(UIColor *)underliningColor
                                     block:(Complete)block;
/**
 是否第一响应
 */
- (BOOL)isFirstResponder;

/**
 变为第一响应
 */
- (void)_becomeFirstResponder;

/**
 取消第一响应
 */
- (void)_resignFirstResponder;

/**
 主动触发正则判断
 */
- (void)validateInput;

/**
  样式初始化加载（不清除已输入文字）
 */
- (void)reload;

/**
 重置文本
 */
- (void)resetInput;


@end
