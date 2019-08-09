//
//  ZXAlbumPickerViewController.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 相册列表
 */
@interface ZXAlbumPickerViewController : UITableViewController
/**
 实例化

 @param collectionItems 相册列表
 @param collectionItem 已选中相册
 @param dismissalHandler 相册选中回调
 @return self
 */
- (instancetype)initWithCollectionItems:(NSArray<NSDictionary *> *)collectionItems
                 selectedCollectionItem:(NSDictionary *)collectionItem
                       dismissalHandler:(void (^)(NSDictionary *selectedCollectionItem))dismissalHandler NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
@end
