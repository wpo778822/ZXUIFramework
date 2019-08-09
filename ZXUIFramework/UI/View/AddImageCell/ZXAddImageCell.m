//
//  ReturnImagesCell.m
//  ZXartApp
//
//  Created by blingman on 2018/5/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "ZXAddImageCell.h"
#import "ZXPhotoBrowserViewController.h"
#import "ZXMacro.h"
#import "UIView+ZXUI.h"
#import "UIImage+Util.h"
#import "ZXNoticeView.h"
#import "ZXPhotoPicker.h"
#import "ZXUtilHelper.h"
#import <Masonry.h>
#import <YYWebImage.h>
static NSInteger const kCellTag = 1000;

@interface ZXAddImageCell ()
<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, ZXPhotoBrowserViewControllerDataSource, ZXPhotoBrowserViewControllerDelegate,ZXPhotoPickerViewControllerDelegate>
@property (nonatomic, strong)UICollectionView * imagesCollectionView;
@property (nonatomic, assign)CGFloat itemWidth;
@property (nonatomic, assign)CGFloat space;
@property (nonatomic, assign)NSInteger sectionRow;
@property (nonatomic, assign)BOOL isReturning;

@property (nonatomic, weak)UITableViewCell * selectedCell;
@property (nonatomic, assign)NSInteger imageLimiteCount;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *countLabel;

@end

@implementation ZXAddImageCell

- (void)configEHomeTypeWithIndex:(NSInteger)index title:(NSString *)title{
    if (_countLabel) {
        _countLabel.text = [NSString stringWithFormat:@"%ld",(long)index];
        _titleLabel.text = title;
        [_imagesCollectionView reloadData];
    }else{
        [self configSubViewCanEdit:YES title:title maxImageCount:3 maxRowCount:3];
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.font = _titleLabel.font;
        countLabel.textColor = [UIColor whiteColor];
        countLabel.backgroundColor = ZXBlueColor;
        countLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:countLabel];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(SCALE_SET(15));
            make.top.offset(SCALE_SET(13));
        }];
        [countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.left.offset(SCALE_SET(15));
            make.trailing.equalTo(self.titleLabel.mas_leading).offset(SCALE_SET(-10));
            make.size.mas_equalTo(CGSizeMake(SCALE_SET(20), SCALE_SET(20)));
        }];
        [countLabel cornerRadius:SCALE_SET(10)];
        countLabel.text = [NSString stringWithFormat:@"%ld",(long)index];
    }
}

- (void)configSubViewCanEdit:(BOOL)canEdit title:(NSString *)title maxImageCount:(NSInteger)maxImageCount maxRowCount:(NSInteger)maxRowCount {
    //
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //
    _imageLimiteCount = maxImageCount > 0 ? maxImageCount : 6;
    _isReturning = canEdit;
    _sectionRow = maxRowCount > 0 ? maxRowCount : 4;
    _space = 5.;
    _imageArray = [[NSMutableArray alloc] initWithCapacity:_imageLimiteCount];
    
    UIView *lineView;
    if (title.length > 0) {
        UILabel *label = [[UILabel alloc] init];
        _titleLabel = label;
        label.textAlignment = NSTextAlignmentLeft;
        label.text = title;
        label.textColor = ColorBlack;
        label.font = [UIFont systemFontOfSize:SCALE_SET(15)];
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(SCALE_SET(15));
            make.top.offset(SCALE_SET(13));
        }];
        
        lineView = [[UIView alloc] init];
        lineView.backgroundColor = ColorLightGray;
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(label.mas_bottom).offset(SCALE_SET(13));
            make.left.offset(SCALE_SET(15));
            make.right.offset(0);
            make.height.mas_equalTo(SCALE_SET(0.5));
        }];
    }
    
    _itemWidth = (SCREEN_WIDTH - SCALE_SET(15 * 2 + _sectionRow * _space)) / _sectionRow;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(_itemWidth, _itemWidth);
    layout.minimumLineSpacing = SCALE_SET(_space);
    layout.minimumInteritemSpacing = SCALE_SET(_space);
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = NO;
    [self.contentView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (lineView) {
            make.top.mas_equalTo(lineView.mas_bottom).offset(SCALE_SET(15));
            make.left.offset(SCALE_SET(15));
            make.right.bottom.offset(-SCALE_SET(15));
            make.height.mas_equalTo(self.itemWidth);
        }else {
            make.top.left.offset(SCALE_SET(15));
            make.right.bottom.offset(-SCALE_SET(15));
            make.height.mas_equalTo(self.itemWidth);
        }
    }];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellAdd"];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellImage"];
    _imagesCollectionView = collectionView;
}

- (void)deleteImage:(UIButton *)button {
    UICollectionViewCell *cell = (UICollectionViewCell *)button.superview;
    NSUInteger index = cell.tag - kCellTag;
    [_imageArray removeObjectAtIndex:index];
    WeakSelf(weakSelf)
    GCDMain(^{
        if (weakSelf.imageArray.count + 1 <= 4 && weakSelf.imagesCollectionView.contentSize.height > weakSelf.itemWidth) {
            [weakSelf.imagesCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(weakSelf.itemWidth);
            }];
            
            [weakSelf.imagesCollectionView reloadData];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshReturnImagesCell)]) {
                [weakSelf.delegate refreshReturnImagesCell];
            }
        }else {
            [weakSelf.imagesCollectionView reloadData];
        }
    });
}

#pragma mark UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _isReturning ? _imageArray.count + 1 : _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isReturning && indexPath.section == 0 && indexPath.row == _imageArray.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellAdd" forIndexPath:indexPath];
        UIImageView *imageView = [cell viewWithTag:333];
        if (!imageView) {
            imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, _itemWidth, _itemWidth)];
            imageView.tag = 333;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [cell addSubview:imageView];
        }
        imageView.image = [UIImage imageNamed:@"fabu_tianjiatupian"];
        return cell;
    }else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellImage" forIndexPath:indexPath];
        cell.tag = kCellTag + indexPath.row;
        UIImageView *imageView = [cell viewWithTag:111];
        if (!imageView) {
            imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, _itemWidth, _itemWidth)];
            imageView.tag = 111;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [cell addSubview:imageView];
            if (_isReturning) {
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteBtn.frame = CGRectMake(_itemWidth - SCALE_SET(5 + 15), SCALE_SET(5), SCALE_SET(15), SCALE_SET(15));
                [deleteBtn setImage:[UIImage imageNamed:@"fadongtai_shantupian"] forState:UIControlStateNormal];
                deleteBtn.tag = 222;
                [deleteBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:deleteBtn];
            }
        }
        if (_isReturning) {
            imageView.image = [_imageArray objectAtIndex:indexPath.row];
        }else {
            NSString *url = [_imageArray objectAtIndex:indexPath.row];
            [imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:nil];
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isReturning && indexPath.section == 0 && indexPath.row == _imageArray.count) {
        [self addPicture];
    }else {
        _selectedCell = [self viewWithTag:kCellTag + indexPath.row];
        ZXPhotoBrowserViewController *vc = [ZXPhotoBrowserViewController new];
        vc.zxDataSource = self;
        vc.zxDelegate = self;
        vc.isNeedAlpha = YES;
        vc.isShowBlurBackground = NO;
        vc.startPage = _isReturning ? indexPath.row : indexPath.row;
        [(UIViewController *)_delegate presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark action
- (void)addPicture {
    if (_imageArray.count >= _imageLimiteCount) {
        [ZXNoticeView showNoticeViewWithInfoString:[NSString stringWithFormat:@"最多上传%ld张图片！", (long)_imageLimiteCount] type:ZXNoticeTypeInfo completion:nil];
        return;
    }
    if ([_delegate isKindOfClass:[UIViewController class]]) {
        
        ZXPhotoPickerViewController *pickerViewController = [[ZXPhotoPickerViewController alloc] init];
        pickerViewController.numberOfPhotoToSelect = _imageLimiteCount - _imageArray.count;
        
        UIColor *customColor = [UIColor colorWithRed:33/255.0 green:150/255.0 blue:243/255.0 alpha:1.0];
        
        pickerViewController.theme.titleLabelTextColor = [UIColor blackColor];
        pickerViewController.theme.navigationBarTintColor = customColor;
        pickerViewController.theme.tintColor = [UIColor blackColor];
        pickerViewController.theme.orderTintColor = customColor;
        pickerViewController.theme.orderLabelTextColor = [UIColor blackColor];
        pickerViewController.theme.cameraVeilColor = customColor;
        pickerViewController.theme.cameraIconColor = [UIColor whiteColor];
        pickerViewController.theme.statusBarStyle = UIStatusBarStyleDefault;
        
        [(UIViewController *)_delegate zx_presentCustomAlbumPhotoView:pickerViewController delegate:self];
    }
}

- (void)refleshImage{
    if (self.imageArray.count + 1 > 4 && self.imagesCollectionView.contentSize.height == self.itemWidth) {
        [self.imagesCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2 * self.itemWidth + SCALE_SET(self.space * 3));
        }];
        
        [self.imagesCollectionView reloadData];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshReturnImagesCell)]) {
            [self.delegate refreshReturnImagesCell];
        }
    }else {
        [self.imagesCollectionView reloadData];
    }
}

#pragma mark ZXPhotoPickerViewControllerDelegate
- (void)photoPickerViewController:(ZXPhotoPickerViewController *)picker didFinishPickingImage:(UIImage *)image{
    ShowHUDAndActivity;
    [picker dismissViewControllerAnimated:YES completion:^() {
        [self.imageArray addObject:image];
        [self refleshImage];
        HiddenHUDAndAvtivity;
    }];
}

- (void)photoPickerViewController:(ZXPhotoPickerViewController *)picker didFinishPickingImages:(NSArray *)photoAssets{
    ShowHUDAndActivity;
    [picker dismissViewControllerAnimated:YES completion:^() {
                PHImageManager *imageManager = [[PHImageManager alloc] init];
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                options.synchronous = YES;
                for (PHAsset *asset in photoAssets) {
                   CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
                    [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *image, NSDictionary *info) {
                        [self.imageArray addObject:image];
                    }];
                }
        [self refleshImage];
        HiddenHUDAndAvtivity;
    }];
}

#pragma mark - ZXPhotoPickerViewControllerDelegate

- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(ZXPhotoPickerViewController *)picker{
    [ZXUtilHelper showPhotoAlbumAccessDenied];
}

- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(ZXPhotoPickerViewController *)picker{
    [ZXUtilHelper showCameraAccessDenied];
}

#pragma mark - ZXPhotoBrowserViewController

- (NSInteger)numberOfPagesInViewController:(ZXPhotoBrowserViewController *)viewController {
    return _imageArray.count;
}

- (void)viewController:(ZXPhotoBrowserViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    if (_isReturning) {
        imageView.image = _imageArray[index];
    }else {
        UICollectionViewCell *cell = [self viewWithTag:kCellTag + index];
        UIImageView *imgV = [cell viewWithTag:111];
        imageView.image = imgV.image;
    }
}

- (UIView *)thumbViewForPageAtIndex:(NSInteger)index viewController:(ZXPhotoBrowserViewController *)viewController {
    NSInteger tag = kCellTag + index;
    UICollectionViewCell *cell = [self viewWithTag:tag];
    return [cell viewWithTag:111];
}

- (void)viewController:(ZXPhotoBrowserViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
