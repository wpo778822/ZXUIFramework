//
//  NodeModelStrings.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/17.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeModel.h"

@interface NodeModelStrings : NSObject

/**
 *  节点对象
 */
@property (nonatomic, strong) NodeModel  *nodeModel;

/**
 *  用NodeModel进行初始化
 *
 *  @param nodeModel nodeModel对象
 *
 *  @return NodeModelStrings对象
 */
+ (instancetype)nodeModelStringsWithNodeModel:(NodeModel *)nodeModel;

/**
 *  创建文件
 */
- (void)createFile;

@end
