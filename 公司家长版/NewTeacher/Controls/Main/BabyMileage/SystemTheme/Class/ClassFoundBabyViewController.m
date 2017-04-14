//
//  ClassNotFoundViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassFoundBabyViewController.h"
#import "MileageModel.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "ThemeBatchModel.h"
#import "UIImage+Caption.h"
#import "MyThemeManagerController.h"

@interface ClassFoundBabyViewController ()

@end

@implementation ClassFoundBabyViewController
{
    NSMutableArray *_selectArr;
    UIView *_tipView;
}

- (void)dealloc{
    NSLog(@"ClassNotFoundViewController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.useNewInterface = YES;
    _selectArr = [NSMutableArray array];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWei = (winSize.width - 4 * margin) / 3,itemHei = itemWei;
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    [self createCollectionViewLayout:layout Action:nil Param:nil Header:YES Foot:YES];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"mileagePhotoCell"];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [_collectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 30 - 64 - 44)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:rgba(248, 151, 55, 1)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(sureFindFinish:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, self.view.frameHeight - 44, self.view.frameWidth, 44)];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:button];
    
    if ([self.dataSource count] == 0) {
        _pageCount = 10;
        [self beginRefresh];
    }
}

- (void)resetCollectionView
{
    if ([self.dataSource count] == 0) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 100)];
        [_tipView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, _tipView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"咦，暂时还没有发布内容哦!"];
        [_tipView addSubview:label];
        [self.view addSubview:_tipView];
    }
    else
    {
        [_tipView removeFromSuperview];
        _tipView = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [(MyThemeManagerController *)self.parentViewController.parentViewController changeRightType:0];
}

- (void)sureFindFinish:(id)sender{
    
    if (_selectArr.count == 0) {
        [self.view.window makeToast:@"请先选择图片或视频" duration:1.0 position:@"center"];
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in _selectArr) {
        ThemeBatchItem *item = self.dataSource[key.integerValue];
        [array addObject:item.id];
        [items addObject:item];
    }
    NSString *photos = [array componentsJoinedByString:@","];
    [_delegate foundBabyFinish:self Param:@{@"album_id":self.mileage.album_id ?: @"",@"photos":photos} Items:items];
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassPhotoList"];
    [param setObject:self.mileage.album_id ?: @"" forKey:@"album_id"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

- (void)startPullRefresh
{
    _pageIdx = 1;
    _lastPage = NO;
    [super startPullRefresh];
}

- (void)startPullRefresh2
{
    if (_lastPage) {
        [self.view makeToast:@"已到最后一页" duration:1.0 position:@"center"];
        
        //isStopRefresh
        [self performSelector:@selector(finishRefresh) withObject:nil afterDelay:0.1];
    }
    else
    {
        if ([self.dataSource count] > 0) {
            _pageIdx++;
        }
        [super startPullRefresh2];
    }
    
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        for (id subDic in data) {
            NSError *error;
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObjectsFromArray:themeBatch.photos];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
        //id ret_msg = [result valueForKey:@"ret_msg"];
        //[self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
        
    }
    [_collectionView reloadData];
    [self resetCollectionView];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        data = (!data || [data isKindOfClass:[NSNull class]]) ? [NSArray array] : data;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *set = [NSMutableArray array];
        NSInteger count = [self.dataSource count];
        for (id subDic in data) {
            NSError *error;
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            for (ThemeBatchItem *item in themeBatch.photos) {
                [array addObject:item];
                [set addObject:[NSIndexPath indexPathForItem:count++ inSection:0]];
            }
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_collectionView insertItemsAtIndexPaths:set];
        
        if ([self.dataSource count] == array.count) {
            [self resetCollectionView];
        }
    }
    else
    {
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
    
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mileagePhotoCell" forIndexPath:indexPath];
    UIImageView *contentImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!contentImg) {
        CGSize itemSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
        //face
        contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        [contentImg setContentMode:UIViewContentModeScaleAspectFill];
        contentImg.clipsToBounds = YES;
        [contentImg setTag:1];
        [contentImg setBackgroundColor:BACKGROUND_COLOR];
        [cell.contentView addSubview:contentImg];
        
        //video
        UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((contentImg.frameWidth - 30) / 2, (contentImg.frameHeight - 30) / 2, 30, 30)];
        [videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [videoImg setTag:2];
        [videoImg setBackgroundColor:[UIColor clearColor]];
        [contentImg addSubview:videoImg];
        
        //select
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(contentImg.frameRight - 30, contentImg.frameBottom - 30, 30, 30)];
        [button setImage:CREATE_IMG(@"bb2@2x") forState:UIControlStateNormal];
        [button setImage:CREATE_IMG(@"bb2_1@2x") forState:UIControlStateSelected];
        button.userInteractionEnabled = NO;
        [button setTag:3];
        [cell.contentView addSubview:button];
    }
    
    ThemeBatchItem *item = self.dataSource[indexPath.item];
    NSString *str = item.thumb ?: item.path;
    [contentImg setImage:nil];
    
    if (![str hasPrefix:@"http"]) {
        str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (item.type.integerValue != 0){
        BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
        if (mp4) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [contentImg setImage:image];
                });
            });
        }
        else
        {
            [contentImg setImageWithURL:[NSURL URLWithString:str]];
        }
    }
    else
    {
        [contentImg setImageWithURL:[NSURL URLWithString:str]];
    }
    
    //video
    UIImageView *videoImg = (UIImageView *)[contentImg viewWithTag:2];
    videoImg.hidden = (item.type.integerValue == 0);
    
    //select
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:3];
    button.selected = [_selectArr containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.item]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:3];
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
    if ([_selectArr containsObject:key]) {
        [_selectArr removeObject:key];
        button.selected = NO;
    }
    else{
        ThemeBatchItem *item = self.dataSource[indexPath.item];
        if (item.use_student_ids && [item.use_student_ids rangeOfString:[DJTGlobalManager shareInstance].userInfo.userid].location != NSNotFound) {
            [self.view.window makeToast:@"您以前选择过该图片，不可以重复选择" duration:1.0 position:@"center"];
        }
        else{
            if ([_selectArr count] == 0) {
                [_selectArr addObject:key];
                button.selected = YES;
            }
            else{
                BOOL mp4 = [[[[item.path lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
                if (mp4) {
                    [self.view.window makeToast:@"视频不可以和图片一块选择" duration:1.0 position:@"center"];
                }
                else{//
                    ThemeBatchItem *oneItem = self.dataSource[[[_selectArr firstObject] integerValue]];
                    BOOL oneMp4 = [[[[oneItem.path lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
                    if (oneMp4) {
                        [self.view.window makeToast:@"图片不可以和视频一块选择" duration:1.0 position:@"center"];
                    }
                    else{
                        if (_selectArr.count >= 9) {
                            [self.view.window makeToast:@"图片不可以超过9张" duration:1.0 position:@"center"];
                        }
                        else
                        {
                            [_selectArr addObject:key];
                            button.selected = YES;
                        }
                        
                    }
                }
                
            }
        }
        
    }
}

@end
