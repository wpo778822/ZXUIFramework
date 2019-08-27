//
//  ZXPhotoCell.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXPhotoCell.h"

#import "ZXPhotoPickerTheme.h"

static const CGFloat ZXHightedAnimationDuration = 0.15;
static const CGFloat ZXUnhightedAnimationDuration = 0.4;
static const CGFloat ZXHightedAnimationTransformScale = 0.9;
static const CGFloat ZXUnhightedAnimationSpringDamping = 0.5;
static const CGFloat ZXUnhightedAnimationSpringVelocity = 6.0;

@interface ZXPhotoCell()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *selectionVeil;
@property (nonatomic, assign) BOOL enableSelectionIndicatorViewVisibility;
@property (nonatomic, weak) PHImageManager *imageManager;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) BOOL animateSelection;
@property (nonatomic, assign, getter=isAnimatingHighlight) BOOL animateHighlight;
@property (nonatomic, weak) IBOutlet UILabel *selectionOrderLabel;
@property (nonatomic, strong) UIImage *thumbnailImage;

@end

@implementation ZXPhotoCell

- (void)awakeFromNib{
    [super awakeFromNib];

    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [self addGestureRecognizer:self.longPressGestureRecognizer];

    self.selectionOrderLabel.textColor = [ZXPhotoPickerTheme sharedInstance].orderLabelTextColor;
    self.selectionOrderLabel.font = [ZXPhotoPickerTheme sharedInstance].selectionOrderLabelFont;

    self.selectionVeil.layer.borderWidth = 4.0;

    self.selectionOrderLabel.backgroundColor = [ZXPhotoPickerTheme sharedInstance].orderTintColor;
    self.selectionVeil.layer.borderColor = [ZXPhotoPickerTheme sharedInstance].orderTintColor.CGColor;

    [self prepareForReuse];
}

- (void)prepareForReuse{
    [super prepareForReuse];

    [self cancelImageRequest];

    self.imageView.image = nil;
    self.enableSelectionIndicatorViewVisibility = NO;
    self.selectionVeil.alpha = 0.0;
    self.selectionOrderLabel.alpha = 0.0;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setSelected:selected animated:self.animateSelection];
}

- (void)setSelectionOrder:(NSUInteger)selectionOrder{
    _selectionOrder = selectionOrder;
    self.selectionOrderLabel.text = [NSString stringWithFormat:@"%zd", selectionOrder];
}

- (void)dealloc{
    [self cancelImageRequest];
}

#pragma mark - Publics

- (void)loadPhotoWithManager:(PHImageManager *)manager forAsset:(PHAsset *)asset targetSize:(CGSize)size{
    self.imageManager = manager;
    self.imageRequestID = [self.imageManager requestImageForAsset:asset
                                                       targetSize:size
                                                      contentMode:PHImageContentModeAspectFill
                                                          options:nil
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                            self.thumbnailImage = result;
                                                        }
                                                    }];
}

- (void)setNeedsAnimateSelection{
    self.animateSelection = YES;
}

- (void)animateHighlight:(BOOL)highlighted{
    if (highlighted) {
        self.animateHighlight = YES;
        [UIView animateWithDuration:ZXHightedAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(ZXHightedAnimationTransformScale, ZXHightedAnimationTransformScale);
        } completion:^(BOOL finished) {
            self.animateHighlight = NO;
        }];
    }
    else {
        [UIView animateWithDuration:ZXUnhightedAnimationDuration delay:self.isAnimatingHighlight? ZXHightedAnimationDuration: 0 usingSpringWithDamping:ZXUnhightedAnimationSpringDamping initialSpringVelocity:ZXUnhightedAnimationSpringVelocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

#pragma mark - Privates

- (void)setThumbnailImage:(UIImage *)thumbnailImage{
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)cancelImageRequest{
    if (self.imageRequestID != PHInvalidImageRequestID) {
        [self.imageManager cancelImageRequest:self.imageRequestID];
        self.imageRequestID = PHInvalidImageRequestID;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (!animated) {
        self.selectionVeil.alpha = selected ? 1.0 : 0.0;
        self.selectionOrderLabel.alpha = selected ? 1.0 : 0.0;
        self.enableSelectionIndicatorViewVisibility = selected;
    }
    else {
        self.enableSelectionIndicatorViewVisibility = YES;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.selectionVeil.alpha = selected ? 1.0 : 0.0;
            self.selectionOrderLabel.alpha = selected ? 1.0 : 0.0;
        } completion:^(BOOL finished) {
            self.enableSelectionIndicatorViewVisibility = selected;
        }];
    }
    self.animateSelection = NO;
}

@end
