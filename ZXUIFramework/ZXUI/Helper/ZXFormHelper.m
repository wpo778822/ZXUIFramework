//
//  ZXFormHelper.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/8.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXFormHelper.h"
#import "ZXUtilHelper.h"
@implementation ZXFormHelper
+ (NSMutableAttributedString *)linkAttStrWithKeyArray:(NSArray *)keyArray
                                           valueArray:(NSArray *)valueArray
                                          colonString:(NSString *)colonString
                                          blankOffset:(CGFloat)blankOffset
                                           titleColor:(UIColor *)titleColor
                                            infoColor:(UIColor *)infoColor
                                             baseFont:(UIFont *)baseFont
                                    linkBreakKeyArray:(NSArray <NSString *>*)linkBreakKeyArray
                                     positionKeyArray:(NSArray <NSString *>*)positionKeyArray
                                    positionTodoArray:(NSArray <NSDictionary *>*)positionTodoArray{
    NSMutableAttributedString *attriContent = [[NSMutableAttributedString alloc]init];
    [keyArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *obj = valueArray[idx];
        NSString *keyString = key;
        NSString *speace = @"";
        BOOL isBreak = (idx == keyArray.count - 1 || [linkBreakKeyArray containsObject:key]);
        UIColor *tColor = titleColor;
        UIColor *iColor = infoColor;
        UIFont *font = baseFont;
        NSAttributedString *insert;
        if (positionKeyArray) {
            if ([positionKeyArray containsObject:key]) {
                font = positionTodoArray[[positionKeyArray indexOfObject:key]][@"font"] ?:font;
                tColor = positionTodoArray[[positionKeyArray indexOfObject:key]][@"tColor"] ?:tColor;
                iColor = positionTodoArray[[positionKeyArray indexOfObject:key]][@"iColor"] ?:iColor;
                insert = positionTodoArray[[positionKeyArray indexOfObject:key]][@"insert"] ?:insert;
            }
        }
        if ([linkBreakKeyArray containsObject:key]) {
            speace = [ZXUtilHelper fillUpSpace:obj lineFeedWidth:blankOffset baseFont:font];
        }
        
        NSString *lineBreak = isBreak ? speace :@"\n";
        if (insert) {
            lineBreak = @"";
        }
        NSString *contentSring = [NSString stringWithFormat:@"%@%@%@%@",keyString,colonString,obj,lineBreak];
        NSMutableAttributedString *attriContentPiece = [[NSMutableAttributedString alloc] initWithString:contentSring];
        [attriContentPiece addAttribute:NSForegroundColorAttributeName value:iColor range:NSMakeRange(0, keyString.length + colonString.length)];
        [attriContentPiece addAttribute:NSForegroundColorAttributeName value:tColor range:NSMakeRange(keyString.length + colonString.length, obj.length)];
        [attriContentPiece addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, contentSring.length)];
        [attriContent appendAttributedString:attriContentPiece];
        if([insert isKindOfClass:[NSAttributedString class]])[attriContent appendAttributedString:insert];
    }];
    return attriContent;
}

+ (void)addLineSpacing:(CGFloat)lineSpacing attriContent:(NSMutableAttributedString *)attriContent{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [attriContent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attriContent.length)];
}

+ (void)addLineBreakWithAttriContent:(NSMutableAttributedString *)attriContent{
    [attriContent appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
}

@end
