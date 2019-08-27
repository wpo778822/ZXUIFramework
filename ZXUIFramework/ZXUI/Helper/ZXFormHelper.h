//
//  ZXFormHelper.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/8.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXMacro.h"

@interface ZXFormHelper : NSObject

/**
 一个为项目而生的表格富文本

 想象目的效果
 [key][colonString][value] ---blankOffset---- [key][colonString][value]
 
 @param keyArray 关键字数组
 @param valueArray 值的数组
 @param colonString 键与值之间间隔符
 @param blankOffset 中间最大换行空间
 @param titleColor 值的颜色
 @param infoColor 键的颜色
 @param baseFont 基础字号
 @param linkBreakKeyArray 执行直接换行的键数组
 @param positionKeyArray 修改显示值的键数组
 @param positionTodoArray 将要修改键的状态值字典，与positionKeyArray对应(支持更改'font-字体','tColor-值的颜色','iColor-键的颜色','insert-值后插入富文本')
 @return 富文本
 */
+ (NSMutableAttributedString *)linkAttStrWithKeyArray:(NSArray *)keyArray
                                           valueArray:(NSArray *)valueArray
                                          colonString:(NSString *)colonString
                                          blankOffset:(CGFloat)blankOffset
                                           titleColor:(UIColor *)titleColor
                                            infoColor:(UIColor *)infoColor
                                             baseFont:(UIFont *)baseFont
                                    linkBreakKeyArray:(NSArray <NSString *>*)linkBreakKeyArray
                                     positionKeyArray:(NSArray <NSString *>*)positionKeyArray
                                    positionTodoArray:(NSArray <NSDictionary *>*)positionTodoArray;
+ (void)addLineSpacing:(CGFloat)lineSpacing attriContent:(NSMutableAttributedString *)attriContent;
+ (void)addLineBreakWithAttriContent:(NSMutableAttributedString *)attriContent;

@end

