//
//  ZXTableViewPlaceHolderDelegate.h
//  ZXartApp
//
//  Created by Apple on 2017/3/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

@protocol ZXTableViewPlaceHolderDelegate <NSObject>

@required

/**
 返回一个占位视图 （必须实现）

 @return view
 */
- (UIView *)makePlaceHolderView;

@end
