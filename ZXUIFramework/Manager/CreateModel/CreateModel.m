//
//  NodeModelHelper.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/17.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "CreateModel.h"
#import "NodeModel.h"
#import "NodeModelStrings.h"

@implementation CreateModel

+ (NSString *)createModelWithJsonData:(NSDictionary *)jsonData rootModelName:(NSString *)rootModelName {
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        NodeModel *nodeModel = [NodeModel nodeModelWithDictionary:jsonData modelName:rootModelName level:0];
        for (NodeModel *node in nodeModel.allSubNodes) {
            NodeModelStrings *nodeModelString = [NodeModelStrings nodeModelStringsWithNodeModel:node];
            [nodeModelString createFile];
        }
        return [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
    }
    return nil;
}

+ (NSString *)ceateJsonFile:(NSDictionary *)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonData
                                                       options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                         error:nil];
        if (data) {
            [data writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/data.json"]
                   atomically:YES];
            
            return[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
        }
    }
    return nil;
}

@end
