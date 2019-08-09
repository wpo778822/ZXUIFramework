//
//  ZXStatusModel.h
//  EasyHome
//
//  Created by mac on 2018/10/31.
//  Copyright © 2018 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXStatusModel : NSObject
@property (nonatomic, copy) NSString * errCode;
@property (nonatomic, copy) NSString * errMsg;
@property (nonatomic, copy) NSString * returnCode;
@property (nonatomic, copy) id result;
@property (nonatomic, copy) id detail;

@end

NS_ASSUME_NONNULL_END
