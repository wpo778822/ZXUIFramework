//
//  ZXAlbumCell.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 相册列表Cell
 */
@interface ZXAlbumCell : UITableViewCell

@property (nonatomic, strong) NSString *representedAssetIdentifier;

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, strong) NSString *albumName;

@property (nonatomic, assign) NSUInteger photosCount;
 
@end
