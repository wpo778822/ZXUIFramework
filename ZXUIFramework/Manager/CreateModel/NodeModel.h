//
//  NodeModel.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/17.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyInfomation.h"

static NSString *stringType = @"NSString";
static NSString *numberType = @"NSNumber";
static NSString *nullType   = @"NSNull";

@interface NodeModel : NSObject

/**
 *  model名
 */
@property (nonatomic, strong) NSString *name;

/**
 *  在name的基础上追加了"Model"
 */
@property (nonatomic, strong) NSString *fileName;

/**
 *  当前树形结构级别
 */
@property (nonatomic) NSInteger level;

/**
 *  普通的属性
 */
@property (nonatomic, strong) NSMutableDictionary *normalProperties;

/**
 *  字典类型元素
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NodeModel *> *dictionaryTypeModelList;

/**
 *  数组类型元素
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NodeModel *> *arrayTypeModelList;

/**
 *  便利构造器
 *
 *  @param dictionary 数据字典
 *  @param name       model名字
 *  @param level      当前树形结构级别
 *
 *  @return NodeModel对象
 */
+ (instancetype)nodeModelWithDictionary:(NSDictionary *)dictionary
                              modelName:(NSString *)name
                                  level:(NSInteger)level;

/**
 *  所有的property
 */
@property (nonatomic, strong, readonly) NSMutableArray <PropertyInfomation *>  *properties;

/**
 *  所有subModel -> subModel 命名为 key + "Model" ，
 *
 *  @return 数组
 */
- (NSArray *)allSubNodes;

@end
