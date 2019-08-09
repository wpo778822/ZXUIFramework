//
//  ZXAlbumPickerViewController.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXAlbumPickerViewController.h"

#import <Photos/Photos.h>

#import "ZXAlbumCell.h"
#import "ZXPhotoPickerTheme.h"

static NSString * const ZXAlbumCellIdentifier = @"ZXAlbumCellIdentifier";

@interface ZXAlbumPickerViewController ()

@property (nonatomic, copy) void (^dismissalHandler)(NSDictionary *);
@property (nonatomic, strong) NSDictionary *selectedCollectionItem;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@end

@implementation ZXAlbumPickerViewController

- (instancetype)initWithCollectionItems:(NSArray<NSDictionary *> *)collectionItems selectedCollectionItem:(NSDictionary *)collectionItem dismissalHandler:(void (^)(NSDictionary *))dismissalHandler{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.selectedCollectionItem = collectionItem;
        self.collectionItems = collectionItems;
        self.dismissalHandler = dismissalHandler;
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    navigationItem.leftBarButtonItem = cancelItem;

    self.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem;
    
    if (![[ZXPhotoPickerTheme sharedInstance].navigationBarTintColor isEqual:[UIColor whiteColor]]) {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationController.navigationBar.barTintColor = [ZXPhotoPickerTheme sharedInstance].navigationBarTintColor;
        self.tableView.tintColor = [ZXPhotoPickerTheme sharedInstance].navigationBarTintColor;
    }

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass(ZXAlbumCell.class) bundle:[NSBundle bundleForClass:ZXAlbumCell.class]];
    
    [self.tableView registerNib:cellNib forCellReuseIdentifier:ZXAlbumCellIdentifier];
    self.tableView.rowHeight = 61.0;
}

#pragma mark - IBActions

- (void)dismiss:(id)sender{
    if (self.dismissalHandler) {
        self.dismissalHandler(self.selectedCollectionItem);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.collectionItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZXAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:ZXAlbumCellIdentifier];
    
    NSDictionary *collectionItem = [self.collectionItems objectAtIndex:indexPath.row];
    
    PHFetchResult *fetchResult = collectionItem[@"assets"];
    PHCollection *collection = collectionItem[@"collection"];
    
    cell.albumName = collection.localizedTitle;
    cell.photosCount = fetchResult.count;
    if ([collectionItem isEqual:self.selectedCollectionItem]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    PHAsset *asset = [fetchResult firstObject];
    cell.representedAssetIdentifier = asset.localIdentifier;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(40.0 * scale, 40.0 * scale);
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      cell.thumbnailImage = result;
                                  }
                              }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *collectionItem = [self.collectionItems objectAtIndex:indexPath.row];
    self.selectedCollectionItem = collectionItem;
    [tableView reloadData];
    [self dismiss:nil];
}

@end
