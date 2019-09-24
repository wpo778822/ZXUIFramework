//
//  ZXPhotoPickerViewController.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXPhotoPickerViewController.h"

#import <Photos/Photos.h>

#import "UIViewController+ZXPhotoHelper.h"
#import "ZXCameraCell.h"
#import "ZXPhotoCell.h"
#import "ZXPhotoNavigationController.h"
#import "ZXAlbumPickerViewController.h"
#import "ZXSinglePhotoViewController.h"

static NSString * const ZXCameraCellIdentifier = @"ZXCameraCellIdentifier";
static NSString * const ZXPhotoCellIdentifier = @"ZXPhotoCellIdentifier";

static const NSUInteger ZXNumberOfPhotoColumns = 3;
static const CGFloat ZXPhotoFetchScaleResizingRatio = 0.75;

@interface ZXPhotoPickerViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, copy) NSArray *collectionItems;
@property (nonatomic, copy) NSDictionary *currentCollectionItem;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) UIBarButtonItem *doneItem;
@property (nonatomic, assign) BOOL needToSelectFirstPhoto;
@property (nonatomic, assign) CGSize cellPortraitSize;
@property (nonatomic, assign) CGSize cellLandscapeSize;

@end

@implementation ZXPhotoPickerViewController

- (instancetype)init{
    self.selectedPhotos = [NSMutableArray array];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.numberOfPhotoToSelect = 1;
    self.shouldReturnImageForSingleSelection = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(7, 7, 0, 7);
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(ZXCameraCell.class) bundle:[NSBundle bundleForClass:ZXCameraCell.class]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:ZXCameraCellIdentifier];
    cellNib = [UINib nibWithNibName:NSStringFromClass(ZXPhotoCell.class) bundle:[NSBundle bundleForClass:ZXPhotoCell.class]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:ZXPhotoCellIdentifier];
    self.collectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    
    self.imageManager = [[PHCachingImageManager alloc] init];

    self.navigationController.navigationBar.tintColor = self.view.tintColor = self.theme.tintColor;


    [self fetchCollections];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];

    if (self.allowsMultipleSelection) {
        self.doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishPickingPhotos:)];
        self.doneItem.enabled = NO;
        navigationItem.rightBarButtonItem = self.doneItem;
    }

    self.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem;

    if (![self.theme.navigationBarTintColor isEqual:[UIColor whiteColor]]) {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationController.navigationBar.barTintColor = self.theme.navigationBarTintColor;
    }
    
    [self updateViewWithCollectionItem:[self.collectionItems firstObject]];

    self.cellPortraitSize = self.cellLandscapeSize = CGSizeZero;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Getters

- (ZXPhotoPickerTheme *)theme{
    return [ZXPhotoPickerTheme sharedInstance];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    return fetchResult.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ZXCameraCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:ZXCameraCellIdentifier forIndexPath:indexPath];
        return cameraCell;
    }    
    
    ZXPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:ZXPhotoCellIdentifier forIndexPath:indexPath];

    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    PHAsset *asset = fetchResult[indexPath.item-1];
    photoCell.representedAssetIdentifier = asset.localIdentifier;
    
    CGFloat scale = [UIScreen mainScreen].scale * ZXPhotoFetchScaleResizingRatio;
    CGSize imageSize = CGSizeMake(CGRectGetWidth(photoCell.frame) * scale, CGRectGetHeight(photoCell.frame) * scale);
    
    [photoCell loadPhotoWithManager:self.imageManager forAsset:asset targetSize:imageSize];

    [photoCell.longPressGestureRecognizer addTarget:self action:@selector(presentSinglePhoto:)];

    if ([self.selectedPhotos containsObject:asset]) {
        NSUInteger selectionIndex = [self.selectedPhotos indexOfObject:asset];
        photoCell.selectionOrder = selectionIndex+1;
    }

    return photoCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZXPhotoCell class]]) {
        [(ZXPhotoCell *)cell animateHighlight:YES];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (!self.canAddPhoto
        || cell.isSelected) {
        return NO;
    }
    if ([cell isKindOfClass:[ZXPhotoCell class]]) {
        ZXPhotoCell *photoCell = (ZXPhotoCell *)cell;
        [photoCell setNeedsAnimateSelection];
        photoCell.selectionOrder = self.selectedPhotos.count+1;
    }
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self zx_presentCameraCaptureViewWithDelegate:self];
        [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO];
    }
    else if (NO == self.allowsMultipleSelection) {
        if (NO == self.shouldReturnImageForSingleSelection) {
            PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
            PHAsset *asset = fetchResult[indexPath.item-1];
            [self.selectedPhotos addObject:asset];
            [self finishPickingPhotos:nil];
        } else {
            PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
            PHAsset *asset = fetchResult[indexPath.item-1];
            
            [self requestImageForAsset:asset];
        }
    }
    else {
        PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
        PHAsset *asset = fetchResult[indexPath.item-1];
        [self.selectedPhotos addObject:asset];
        self.doneItem.enabled = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZXPhotoCell class]]) {
        [(ZXPhotoCell *)cell animateHighlight:NO];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZXPhotoCell class]]) {
        [(ZXPhotoCell *)cell setNeedsAnimateSelection];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        return;
    }
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    PHAsset *asset = fetchResult[indexPath.item-1];

    NSUInteger removedIndex = [self.selectedPhotos indexOfObject:asset];

    for (NSInteger i=removedIndex+1; i<self.selectedPhotos.count; i++) {
        PHAsset *needReloadAsset = self.selectedPhotos[i];
        ZXPhotoCell *cell = (ZXPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[fetchResult indexOfObject:needReloadAsset]+1 inSection:indexPath.section]];
        cell.selectionOrder = cell.selectionOrder-1;
    }

    [self.selectedPhotos removeObject:asset];
    if (self.selectedPhotos.count == 0) {
        self.doneItem.enabled = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (CGSizeEqualToSize(CGSizeZero, self.cellPortraitSize)
        || CGSizeEqualToSize(CGSizeZero, self.cellLandscapeSize)) {
        [self setupCellSize];
    }

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft
        || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        return self.cellLandscapeSize;
    }
    return self.cellPortraitSize;
}

#pragma mark - voids

- (void)dismiss:(id)sender{
    if ([self.delegate respondsToSelector:@selector(photoPickerViewControllerDidCancel:)]) {
        [self.delegate photoPickerViewControllerDidCancel:self];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)presentAlbumPickerView:(id)sender{
    ZXAlbumPickerViewController *albumPickerViewController = [[ZXAlbumPickerViewController alloc] initWithCollectionItems:self.collectionItems selectedCollectionItem:self.currentCollectionItem dismissalHandler:^(NSDictionary *selectedCollectionItem) {
        if (![self.currentCollectionItem isEqual:selectedCollectionItem]) {
            [self updateViewWithCollectionItem:selectedCollectionItem];
        }
    }];
    
    ZXPhotoNavigationController *navigationController = [[ZXPhotoNavigationController alloc] initWithRootViewController:albumPickerViewController];
    
    navigationController.view.tintColor  = self.theme.tintColor;

    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)finishPickingPhotos:(id)sender{
    if ([self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImages:)]) {
        [self.delegate photoPickerViewController:self didFinishPickingImages:[self.selectedPhotos copy]];
    }
    else {
        [self dismiss:nil];
    }
}

- (void)presentSinglePhoto:(id)sender{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *gesture = sender;
        if (gesture.state != UIGestureRecognizerStateBegan) {
            return;
        }
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:(ZXPhotoCell *)gesture.view];

        PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];

        PHAsset *asset = fetchResult[indexPath.item-1];

        ZXSinglePhotoViewController *presentedViewController = [[ZXSinglePhotoViewController alloc] initWithPhotoAsset:asset imageManager:self.imageManager dismissalHandler:^(BOOL selected) {
            if (selected && [self collectionView:self.collectionView shouldSelectItemAtIndexPath:indexPath]) {
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
            }
        }];
        
        ZXPhotoNavigationController *navigationController = [[ZXPhotoNavigationController alloc] initWithRootViewController:presentedViewController];
        
        navigationController.view.tintColor = presentedViewController.view.tintColor = self.theme.tintColor;

        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{

        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (![image isKindOfClass:[UIImage class]]) {
            return;
        }

        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollection *collection = self.currentCollectionItem[@"collection"];
            if (collection.assetCollectionType == PHAssetCollectionTypeSmartAlbum) {
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            }
            else {
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
                PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection assets:self.currentCollectionItem[@"assets"]];
                [albumChangeRequest addAssets:@[placeholder]];
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                self.needToSelectFirstPhoto = YES;
            }

            if (!self.allowsMultipleSelection) {
                if ([self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImage:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate photoPickerViewController:self didFinishPickingImage:image];
                    });
                }
                else {
                    [self dismiss:nil];
                }
            }
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - Privates

- (void)updateViewWithCollectionItem:(NSDictionary *)collectionItem{
    self.currentCollectionItem = collectionItem;
    PHCollection *photoCollection = self.currentCollectionItem[@"collection"];
    
    UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeSystem];
    albumButton.tintColor = self.theme.titleLabelTextColor;
    albumButton.titleLabel.font = self.theme.titleLabelFont;
    [albumButton addTarget:self action:@selector(presentAlbumPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [albumButton setTitle:photoCollection.localizedTitle forState:UIControlStateNormal];
    UIImage *arrowDownImage = [UIImage imageNamed:@"ZXIconSpinnerDropdwon" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil];
    arrowDownImage = [arrowDownImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [albumButton setImage:arrowDownImage forState:UIControlStateNormal];
    [albumButton sizeToFit];
    albumButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, albumButton.frame.size.width - (arrowDownImage.size.width) + 10, 0.0, 0.0);
    albumButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -arrowDownImage.size.width, 0.0, arrowDownImage.size.width + 10);

    albumButton.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(albumButton.bounds) + 10, CGRectGetHeight(albumButton.bounds));
    
    self.navigationItem.titleView = albumButton;

    [self.collectionView reloadData];
    [self refreshPhotoSelection];
}

- (UIImage *)zx_orientationNormalizedImage:(UIImage *)image{
    if (image.imageOrientation == UIImageOrientationUp) return image;

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (BOOL)allowsMultipleSelection{
    return (self.numberOfPhotoToSelect != 1);
}

- (void)refreshPhotoSelection{
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    NSUInteger selectionNumber = self.selectedPhotos.count;

    for (int i=0; i<fetchResult.count; i++) {
        PHAsset *asset = [fetchResult objectAtIndex:i];
        if ([self.selectedPhotos containsObject:asset]) {
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            ZXPhotoCell *cell = (ZXPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0]];
            cell.selectionOrder = [self.selectedPhotos indexOfObject:asset]+1;
            selectionNumber--;
            if (selectionNumber == 0) {
                break;
            }
        }
    }
}

- (BOOL)canAddPhoto{
    return (self.selectedPhotos.count < self.numberOfPhotoToSelect || self.numberOfPhotoToSelect == 0);
}

- (void)fetchCollections{
    NSMutableArray *allAblums = [NSMutableArray array];

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    __block __weak void (^weakFetchAlbums)(PHFetchResult *collections);
    void (^fetchAlbums)(PHFetchResult *collections);
    weakFetchAlbums = fetchAlbums = ^void(PHFetchResult *collections) {
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

        for (PHCollection *collection in collections) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if (assetsFetchResult.count > 0) {
                    [allAblums addObject:@{@"collection": assetCollection
                                           , @"assets": assetsFetchResult}];
                }
            }
            else if ([collection isKindOfClass:[PHCollectionList class]]) {
                PHCollectionList *collectionList = (PHCollectionList *)collection;
                PHFetchResult *fetchResult = [PHCollectionList fetchCollectionsInCollectionList:(PHCollectionList *)collectionList options:nil];
                weakFetchAlbums(fetchResult);
            }
        }
    };

    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    fetchAlbums(topLevelUserCollections);

    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (assetsFetchResult.count > 0) {
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [allAblums insertObject:@{@"collection": collection
                                          , @"assets": assetsFetchResult} atIndex:0];
            }
            else {
                [allAblums addObject:@{@"collection": collection
                                       , @"assets": assetsFetchResult}];
            }
        }
    }
    self.collectionItems = [allAblums copy];
}

- (void)requestImageForAsset:(PHAsset *)asset {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *image, NSDictionary *info) {
        if (image && [self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImage:)]) {
            [self.delegate photoPickerViewController:self didFinishPickingImage:[self zx_orientationNormalizedImage:image]];
        }
        else {
            [self dismiss:nil];
        }
    }];
}


- (void)setupCellSize{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    CGFloat arrangementLength = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));

    CGFloat minimumInteritemSpacing = layout.minimumInteritemSpacing;
    UIEdgeInsets sectionInset = layout.sectionInset;

    CGFloat totalInteritemSpacing = MAX((ZXNumberOfPhotoColumns - 1), 0) * minimumInteritemSpacing;
    CGFloat totalHorizontalSpacing = totalInteritemSpacing + sectionInset.left + sectionInset.right;

    CGFloat size = (CGFloat)floor((arrangementLength - totalHorizontalSpacing) / ZXNumberOfPhotoColumns);
    self.cellPortraitSize = CGSizeMake(size, size);

    arrangementLength = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    NSUInteger numberOfPhotoColumnsInLandscape = (arrangementLength - sectionInset.left + sectionInset.right)/size;
    totalInteritemSpacing = MAX((numberOfPhotoColumnsInLandscape - 1), 0) * minimumInteritemSpacing;
    totalHorizontalSpacing = totalInteritemSpacing + sectionInset.left + sectionInset.right;
    size = (CGFloat)floor((arrangementLength - totalHorizontalSpacing) / numberOfPhotoColumnsInLandscape);
    self.cellLandscapeSize = CGSizeMake(size, size);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:fetchResult];
    if (collectionChanges == nil) {

        [self fetchCollections];

        if (self.needToSelectFirstPhoto) {
            self.needToSelectFirstPhoto = NO;

            fetchResult = [self.collectionItems firstObject][@"assets"];
            PHAsset *asset = [fetchResult firstObject];
            [self.selectedPhotos addObject:asset];
            self.doneItem.enabled = YES;
        }

        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        PHFetchResult *fetchResult = [collectionChanges fetchResultAfterChanges];
        NSInteger index = [self.collectionItems indexOfObject:self.currentCollectionItem];
        self.currentCollectionItem = @{
                                       @"assets": fetchResult,
                                       @"collection": self.currentCollectionItem[@"collection"]
                                       };
        if (index != NSNotFound) {
            NSMutableArray *updatedCollectionItems = [self.collectionItems mutableCopy];
            [updatedCollectionItems replaceObjectAtIndex:index withObject:self.currentCollectionItem];
            self.collectionItems = [updatedCollectionItems copy];
        }
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]
            || ([collectionChanges removedIndexes].count > 0
                && [collectionChanges changedIndexes].count > 0)) {
            [collectionView reloadData];
        }
        else {
            [collectionView performBatchUpdates:^{
                
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                NSMutableArray *removeIndexPaths = [NSMutableArray arrayWithCapacity:removedIndexes.count];
                [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [removeIndexPaths addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                }];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:removeIndexPaths];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:insertedIndexes.count];
                [insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                }];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:insertIndexPaths];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                NSMutableArray *changedIndexPaths = [NSMutableArray arrayWithCapacity:changedIndexes.count];
                [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                    if (![removeIndexPaths containsObject:indexPath]) {
                        if (self.needToSelectFirstPhoto) {
                            if (![collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
                                [changedIndexPaths addObject:indexPath];
                            }
                        }
                        else {
                            [changedIndexPaths addObject:indexPath];
                        }
                    }
                }];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:changedIndexPaths];
                }
            } completion:^(BOOL finished) {
                if (self.needToSelectFirstPhoto) {
                    self.needToSelectFirstPhoto = NO;

                    PHAsset *asset = [fetchResult firstObject];
                    [self.selectedPhotos addObject:asset];
                    self.doneItem.enabled = YES;
                }
                [self refreshPhotoSelection];
            }];
        }
    });
}

@end
