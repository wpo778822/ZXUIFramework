//
//  ZXViewControllerPicker.m
//  ZXUI
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//
#import "ZXViewControllerPicker.h"
#import <objc/runtime.h>
#import "ZXMacro.h"

#pragma mark - FloatingView

static const CGFloat kDownLoadWidth = 60.f;
static const CGFloat kOffSet = 0.5*kDownLoadWidth;
typedef void (^FloatingBlock) (void);

@interface FloatingView : UIView <UIDynamicAnimatorDelegate>

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, copy) FloatingBlock floatingBlock;

@end

@implementation FloatingView
- (instancetype)initWithFrame:(CGRect)frame{
    frame.size.width = kDownLoadWidth;
    frame.size.height = kDownLoadWidth;
    if (self = [super initWithFrame:frame]) {
        UIView *imageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 5,
                                                                               CGRectGetWidth(self.frame) - 10,
                                                                               CGRectGetHeight(self.frame) - 10)];
        imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.size.width / 2;
        imageBackgroundView.clipsToBounds = YES;
        imageBackgroundView.backgroundColor = ZXBlueColor;
        imageBackgroundView.alpha = 0.7;
        [self addSubview:imageBackgroundView];
        self.layer.cornerRadius = kDownLoadWidth / 2;
        self.alpha = 0.7;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *startTouch = [touches anyObject];
    self.startPoint = [startTouch locationInView:self.superview];
    [self.animator removeAllBehaviors];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *startTouch = [touches anyObject];
    self.center = [startTouch locationInView:self.superview];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *endTouch = [touches anyObject];
    self.endPoint = [endTouch locationInView:self.superview];
    CGFloat errorRange = 5;
    if (( self.endPoint.x - self.startPoint.x >= -errorRange &&
         self.endPoint.x - self.startPoint.x <= errorRange ) &&
        ( self.endPoint.y - self.startPoint.y >= -errorRange &&
         self.endPoint.y - self.startPoint.y <= errorRange )){
        if (self.floatingBlock) {
            self.floatingBlock();
        }
    } else {
        self.center = self.endPoint;
        CGFloat superwidth = self.superview.bounds.size.width;
        CGFloat superheight = self.superview.bounds.size.height;
        CGFloat endX = self.endPoint.x;
        CGFloat endY = self.endPoint.y;
        CGFloat topRange = endY;
        CGFloat bottomRange = superheight - endY;
        CGFloat leftRange = endX;
        CGFloat rightRange = superwidth - endX;
        CGFloat minRangeTB = topRange > bottomRange ? bottomRange : topRange;
        CGFloat minRangeLR = leftRange > rightRange ? rightRange : leftRange;
        CGFloat minRange = minRangeTB > minRangeLR ? minRangeLR : minRangeTB;
        CGPoint minPoint = CGPointZero;
        if (minRange == topRange) {
            endX = endX - kOffSet < 0 ? kOffSet : endX;
            endX = endX + kOffSet > superwidth ? superwidth - kOffSet : endX;
            minPoint = CGPointMake(endX , 0 + kOffSet);
        } else if(minRange == bottomRange){
            endX = endX - kOffSet < 0 ? kOffSet : endX;
            endX = endX + kOffSet > superwidth ? superwidth - kOffSet : endX;
            minPoint = CGPointMake(endX , superheight - kOffSet);
            
        } else if(minRange == leftRange){
            endY = endY - kOffSet < 0 ? kOffSet : endY;
            endY = endY + kOffSet > superheight ? superheight - kOffSet : endY;
            minPoint = CGPointMake(0 + kOffSet , endY);
            
        } else if(minRange == rightRange){
            endY = endY - kOffSet < 0 ? kOffSet : endY;
            endY = endY + kOffSet > superheight ? superheight - kOffSet : endY;
            minPoint = CGPointMake(superwidth - kOffSet , endY);
        }
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self
                                                                             attachedToAnchor:minPoint];
        [attachmentBehavior setLength:0];
        [attachmentBehavior setDamping:0.1];
        [attachmentBehavior setFrequency:5];
        [self.animator addBehavior:attachmentBehavior];
    }
}

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        _animator.delegate = self;
    }
    return _animator;
}

@end


#pragma mark - ZXViewControllerPicker

static NSString *const kNameKey = @"kNameKey";
static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kErrorKey = @"kErrorKey";

static FloatingView *_floatingView = nil;

static NSArray *_prefixArray = nil;

static NSArray *_exceptArray = nil;

static NSArray *_finalArray = nil;

typedef NS_ENUM(NSInteger, VCShowType) {
    Push,
    Present,
    PresentNavi
};


@interface ZXViewControllerPicker () <UISearchBarDelegate>{
    NSArray *_tempArray;
}

@property (nonatomic, strong) UIButton *cancelButton;

@end


@implementation ZXViewControllerPicker

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.rowHeight = 66.f;
    UIView *bg = [UIView new];
    bg.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    [bg addSubview:self.cancelButton];
    self.tableView.tableFooterView = bg;
    [self findAndShowControllers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self class] setCircleHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self class] setCircleHidden:NO];
}

- (void)pickCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(20, 30, SCREEN_WIDTH - 40, 50);
        _cancelButton.backgroundColor = ZXBlueColor;
        _cancelButton.layer.cornerRadius = 7.0f;
        
        [_cancelButton addTarget:self action:@selector(pickCancel) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:@"退出" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return _cancelButton;
}

- (void)findAndShowControllers {
    if (!_finalArray) {
        NSArray *classNameArray = [self findViewControllers];
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *className in classNameArray) {
            UIViewController *controller = nil;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            @try {
                controller = [[NSClassFromString(className) alloc] init];
                 [controller view];
            } @catch (NSException *exception) {
                NSLog(@"[<%@> exception: %@]", className, exception);
                dic[kErrorKey] = exception.description;
            } @finally {
                dic[kNameKey] = className;
                NSString *title = nil;
                title = controller.title ?: (controller.navigationItem.title?:controller.tabBarItem.title);
                if(title.length == 0)title = className;
                dic[kTitleKey] = title;
                [array addObject:dic];
            }
        }
        
        _finalArray = array;
    }
    
    _tempArray = _finalArray;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *classInfo = _tempArray[indexPath.row];
    if (classInfo[kErrorKey]) {
        UITableViewRowAction *eror = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Error" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            NSString *title = [NSString stringWithFormat:@"ErrorClass %@ - %@", classInfo[kTitleKey], classInfo[kNameKey]];
            [[[UIAlertView alloc] initWithTitle:title
                                        message:classInfo[kErrorKey]
                                       delegate:nil
                              cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        return @[eror];
    }

    UITableViewRowAction *push = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Push" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self saveAndShowController:classInfo showType:Push];
    }];
    
    push.backgroundColor = ZXBlueColor;
    
    UITableViewRowAction *present = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Present" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self saveAndShowController:classInfo showType:Present];
    }];
    
    present.backgroundColor = ZXRedColor;
    UITableViewRowAction *presentNavi = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"PresentNavi" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self saveAndShowController:classInfo showType:PresentNavi];
    }];
    
    presentNavi.backgroundColor = ZXBlackColor;

    return @[push,present,presentNavi];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tempArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TestPickerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *classInfo = _tempArray[indexPath.row];
    cell.textLabel.text = classInfo[kTitleKey];;
    cell.detailTextLabel.text = classInfo[kNameKey];
    return cell;
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *classInfo in _finalArray) {
        NSString *className = classInfo[kNameKey];
        NSString *classTitle = classInfo[kTitleKey];
        
        NSString *upperClassName = [className uppercaseString];
        NSString *upperSearchText = [searchText uppercaseString];
        
        NSRange rangeName = [upperClassName rangeOfString:upperSearchText];
        NSRange rangeTitle = [classTitle rangeOfString:searchText];
        
        BOOL isNameCompare = rangeName.location != NSNotFound;
        BOOL isTitleCompare = rangeTitle.location != NSNotFound;
        
        if (isNameCompare || isTitleCompare) {
            [resultArray addObject:classInfo];
        }
    }
    
    _tempArray = searchText.length ? resultArray : _finalArray;
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Picker Method

+ (void)activate {
    [self activateWithClassPrefix:nil except:nil];
}

+ (void)activateWithClassPrefix:(NSArray <NSString *> *)prefixes {
    [self activateWithClassPrefix:prefixes except:nil];
}

+ (void)activateWithClassPrefix:(NSArray *)prefixes except:(NSArray *)except {
    [self showFinderWithClassPrefix:prefixes except:except];
}

+ (void)showFinderWithClassPrefix:(NSArray<NSString *> *)prefixArray except:(NSArray *)exceptArray {
            _prefixArray = prefixArray;
            _exceptArray = exceptArray;
            _floatingView = [[FloatingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(kWindow.frame) - 80 ,
                                                                           kWindow.frame.size.height - 190,
                                                                           60,
                                                                           60)];
            _floatingView.backgroundColor = [UIColor clearColor];
            _floatingView.floatingBlock = ^{
                [self showPickerController];
            };
        [kWindow addSubview:_floatingView];
}


+ (void)showPickerController {
    UIViewController *rootVC = kWindow.rootViewController;
    UIViewController *selfVC = [self new];
    UINavigationController *naviedPickerVC = [[UINavigationController alloc] initWithRootViewController:selfVC];
    naviedPickerVC.navigationBar.barStyle = UIBarStyleBlack;
    
    if (rootVC.presentedViewController) {
        [rootVC dismissViewControllerAnimated:YES completion:^{
            [rootVC presentViewController:naviedPickerVC animated:YES completion:nil];
        }];
    }else {
        [rootVC presentViewController:naviedPickerVC animated:YES completion:nil];
    }
}

- (void)dismissController {
    UIViewController *rootVC = kWindow.rootViewController;
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}

+ (void)setCircleHidden:(BOOL)hidden {
    _floatingView.hidden = hidden;
}

- (void)saveAndShowController:(NSDictionary *)controllerInfo showType:(VCShowType)showType {
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *controllerName = controllerInfo[kNameKey];
        [self showViewController:controllerName showType:showType];
    }];
}

- (void)showViewController:(NSString *)controllerName showType:(VCShowType)showType{
    UIViewController *controller = [[NSClassFromString(controllerName) alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    UIViewController *rootVC = kWindow.rootViewController;
    switch (showType) {
        case Push: {
            if ([rootVC isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabbarVC = (UITabBarController *)rootVC;
                UINavigationController *naviVC = tabbarVC.selectedViewController;
                if ([naviVC isKindOfClass:[UINavigationController class]]) {
                    [naviVC pushViewController:controller animated:YES];
                }else {
                    UINavigationController *aNaviVC = [[UINavigationController alloc] initWithRootViewController:controller];
                    [naviVC presentViewController:aNaviVC animated:YES completion:nil];
                }
                
            }else if ([rootVC isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController *)rootVC) pushViewController:controller animated:YES];
                
            }else {
                UINavigationController *reulstNavi = [[UINavigationController alloc] initWithRootViewController:controller];
                [rootVC presentViewController:reulstNavi animated:YES completion:nil];
            }
            break;
        }
            
        case Present: {
            [rootVC presentViewController:controller animated:YES completion:nil];
            break;
        }
            
        case PresentNavi: {
            UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(dismissController)];
            controller.navigationItem.leftBarButtonItem = left;
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:controller];
            [rootVC presentViewController:naviVC animated:YES completion:nil];
            break;
        }
    }
}

- (NSArray *)findViewControllers {
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    
    NSMutableArray *unSortedArray = [NSMutableArray array];
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class theClass = classes[i];
            NSString *className = [NSString stringWithUTF8String:class_getName(theClass)];
            if (theClass == [self class]) continue;
            
            if (_prefixArray.count > 0) {
                for (NSString *classPrefix in _prefixArray) {
                    if ([className hasPrefix:classPrefix]) {
                        if ([theClass isSubclassOfClass:[UIViewController class]])[unSortedArray addObject:className];
                    }
                }
                
            }else {
                if([self isSystemClass:className])continue;
                if ([self isSpecialClass:className]) continue;
                if ([self getRootClassOfClass:theClass] == [NSObject class]) {
                    if ([theClass isSubclassOfClass:[UIViewController class]]) {
                        [unSortedArray addObject:className];
                    }
                }
            }
        }
        free(classes);
    }
    [unSortedArray removeObjectsInArray:_exceptArray];
    NSArray *finalArray = [unSortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSForcedOrderingSearch];
    }];
    
    return finalArray;
}

- (BOOL)isSystemClass:(NSString *)className {
    for (NSString *aClass in [self systemClassPrefixArray]) {
        if ([className hasPrefix:aClass]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)systemClassPrefixArray {
    return @[@"__", @"_", @"UI", @"NS", @"CMKApplication",
             @"CMKCamera", @"DeferredPU",
             @"AB", @"MK", @"MF",
             @"CN", @"SSDK",
             @"SSP", @"QL",
             @"GSAuto"];
}

- (BOOL)isSpecialClass:(NSString *)className {
    return [@[@"JSExport", @"Object", @"CLTilesManagerClient", @"FigIrisAutoTrimmerMotionSampleExport"] containsObject:className];
}

- (Class)getRootClassOfClass:(Class)aClass {
    Class superClass = nil;
    if (aClass) {
        if ([aClass respondsToSelector:@selector(superclass)]) {
            superClass = [aClass superclass];
        }
        if (superClass == nil) {
            return aClass;
        }
    }else {
        return nil;
    }
    
    return [self getRootClassOfClass:superClass];
}

@end
