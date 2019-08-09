//
//  ZXartCityPickViewController.m
//  ZXartApp
//
//  Created by Apple on 2017/11/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXartCityPickViewController.h"
#import "Geomanager.h"
#import <Masonry.h>

@interface ZXartCityPickViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSDictionary *areaListDict;
@property (nonatomic, strong) NSMutableArray *selectedCityArray;
@property (nonatomic, copy) NSArray *locationCityArray;
@property (nonatomic, assign) BOOL pushFinsh;
@end

@implementation ZXartCityPickViewController
- (NSDictionary *)areaListDict{
    if (!_areaListDict) {
        _areaListDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ChinaCity.plist" ofType:nil]];
    }
    return _areaListDict;
}

- (instancetype)initWithSelectedCity:(NSArray *)array delegate:(id<ZXartCityPickViewControllerDelegate>)delegate{
    self = [super init];
    if (self) {
        WeakSelf(weakSelf)
        [Geomanager fetchCurrrentLocationWithoutReGeocodeCompletionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error){
                weakSelf.locationCityArray = @[];
                GCDMain(^{
                    [weakSelf.tableView reloadData];
                });
            }
            if (regeocode) {
                NSString *province = [regeocode.province stringByReplacingOccurrencesOfString:@"省" withString:@""];
                province = [province stringByReplacingOccurrencesOfString:@"市" withString:@""];
                NSString *city = [regeocode.city stringByReplacingOccurrencesOfString:@"市" withString:@""];
                city =  [city stringByReplacingOccurrencesOfString:@"盟" withString:@""];
                city = [city stringByReplacingOccurrencesOfString:@"地区" withString:@""];
                weakSelf.locationCityArray = @[province ?: @"",city ?: @"",regeocode.district ?: @""];
                GCDMain(^{
                    [weakSelf.tableView reloadData];
                });
            }
        }];
        _selectedCityArray = array ? array.mutableCopy :@[].mutableCopy;
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH,SCALE_SET(80))];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorUsingHexString:@"#333333"];
        label.font = [UIFont systemFontOfSize:SCALE_SET(27.0)];
        label.text = @"选择所在地";
        [headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView);
            make.leading.equalTo(headerView).offset(SCALE_SET(18));
            make.trailing.equalTo(headerView);
            make.bottom.equalTo(headerView).offset(SCALE_SET(-10));
        }];
        [self.view addSubview:headerView];
        self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate  = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom);
            make.leading.trailing.bottom.equalTo(self.view);
        }];
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarButton:NO WithOriginalImage:_selectedCityArray.count == 0 ? @"cha_black" : @"cha_black"  action:@selector(cancel)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor grayColor]];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIFontWithSize(16),NSFontAttributeName, nil] forState:UIControlStateNormal];
    
}

- (void)cancel{
    switch (_selectedCityArray.count) {
        case 0:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            [self setBarButton:NO WithOriginalImage:@"cha_black" action:@selector(cancel)];
            [_selectedCityArray removeLastObject];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            break;
        case 2:
            [_selectedCityArray removeLastObject];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_pushFinsh) {
        self.navBarBgAlpha = @"0.0";
    }else{
        _pushFinsh = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navBarBgAlpha = @"0.0";
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (_selectedCityArray.count) {
        case 0:
            count = [self.areaListDict.allKeys count] + 1;
            break;
        case 1:
            count = [[self.areaListDict[_selectedCityArray[0]][0] allKeys] count];
            break;
        case 2:
            count = [self.areaListDict[_selectedCityArray[0]][0][_selectedCityArray[1]] count];
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:SCALE_SET(23.0)];
        cell.textLabel.textColor = [UIColor colorUsingHexString:@"#333333"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:SCALE_SET(15.0)];
        cell.detailTextLabel.textColor = [UIColor colorUsingHexString:@"#999999"];
    }
   __block NSString *text = @"";
    switch (_selectedCityArray.count) {
        case 0:
            if (indexPath.row == 0) {
                NSMutableString *string = [NSMutableString string];
                [_locationCityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [string appendString:obj];
                    [string appendString:@" "];
                }];
                text = string.copy;
                if (text.length < 4) {
                    text = _locationCityArray == nil ? @"获取定位信息中" : @"无法获取您的位置信息";
                }
            }else{
                text = self.areaListDict.allKeys[indexPath.row - 1];
            }
            break;
        case 1:
            text = [self.areaListDict[_selectedCityArray[0]][0] allKeys][indexPath.row];
            break;
        case 2:
            text = self.areaListDict[_selectedCityArray[0]][0][_selectedCityArray[1]][indexPath.row];
            break;
        default:
            break;
    }
    cell.textLabel.text = text;
    return cell;
}

#pragma mark tableviewdelege

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_selectedCityArray.count == 0) {
        if (indexPath.row == 0) {
            if (_locationCityArray.count == 0) {
                return;
            }
            if (_delegate && [_delegate respondsToSelector:@selector(cityDidSelected:)]) {
                [self.delegate cityDidSelected:_locationCityArray];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self setBarButton:NO WithOriginalImage:@"tap_back_black" action:@selector(cancel)];
            [_selectedCityArray addObject:[self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [tableView reloadData];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }else if (_selectedCityArray.count == 2){
        [_selectedCityArray addObject:[self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        if (_delegate && [_delegate respondsToSelector:@selector(cityDidSelected:)]) {
            NSArray *sel = @[@"北京",@"上海",@"天津",@"重庆",@"香港",@"澳门",@"台湾"];
            WeakSelf(weakSelf)
            [sel enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([weakSelf.selectedCityArray[0] isEqualToString:obj]) {
                    [weakSelf.selectedCityArray removeObjectAtIndex:1];
                }
            }];
            [self.delegate cityDidSelected:_selectedCityArray.copy];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [_selectedCityArray addObject:[self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        if ([self.areaListDict[_selectedCityArray[0]][0][_selectedCityArray[1]] count] > 0) {
            [tableView reloadData];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }else{
            if (_delegate && [_delegate respondsToSelector:@selector(cityDidSelected:)]) {
                [self.delegate cityDidSelected:_selectedCityArray.copy];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


@end
