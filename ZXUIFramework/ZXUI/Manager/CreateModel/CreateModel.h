//
//  NodeModelHelper.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/17.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateModel : NSObject

/**
 *  根据Json生产Model
 *
 *  @param jsonData      json数据
 *  @param rootModelName model名字
 */
+ (NSString *)createModelWithJsonData:(NSDictionary *)jsonData rootModelName:(NSString *)rootModelName;

/**
 *  生成Json文件
 *
 *  @param jsonData json数据
 */
+ (NSString *)ceateJsonFile:(NSDictionary *)jsonData;

@end
