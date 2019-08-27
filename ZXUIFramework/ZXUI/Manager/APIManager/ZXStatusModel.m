//
//  ZXStatusModel.m
//  EasyHome
//
//  Created by mac on 2018/10/31.
//  Copyright © 2018 黄勤炜. All rights reserved.
//

#import "ZXStatusModel.h"

@implementation ZXStatusModel

- (id)result{
    if ([_result isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return _result;
}

@end
