//
//  ZXAlbumCell.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXAlbumCell.h"
#import "ZXPhotoPickerTheme.h"

@interface ZXAlbumCell()

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *albumNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *photosCountLabel;

@end

@implementation ZXAlbumCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.photosCountLabel.font = [ZXPhotoPickerTheme sharedInstance].photosCountLabelFont;
    self.albumNameLabel.font = [ZXPhotoPickerTheme sharedInstance].albumNameLabelFont;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage{
    self.thumbnailImageView.image = thumbnailImage;
    _thumbnailImage = thumbnailImage;
}

- (void)setAlbumName:(NSString *)albumName{
    self.albumNameLabel.text = albumName;
    _albumName = albumName;
}

- (void)setPhotosCount:(NSUInteger)photosCount{
    self.photosCountLabel.text = photosCount > 0 ? [NSString stringWithFormat:@"(%zd)", photosCount] : @"";
    _photosCount = photosCount;    
}

@end
