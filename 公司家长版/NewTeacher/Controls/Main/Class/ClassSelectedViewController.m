//
//  ClassSelectedViewController2.m
//  NewTeacher
//
//  Created by songzhanglong on 15/6/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassSelectedViewController.h"
#import "WaterfallLayout.h"
#import "Toast+UIView.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import "MileageModel.h"
#import "ThemeBatchModel.h"

@interface ClassSelectedViewController ()

@end

@implementation ClassSelectedViewController
{
    NSMutableDictionary *_selectedDic;
    BOOL _lastPage;
    
    NSMutableArray *_downImgs,*_changeArr;
    UIImageView *_tipView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.useNewInterface = YES;
    if (_nMaxCount > 0) {
        self.titleLable.text = [NSString stringWithFormat:@"0 / %ld",(long)_nMaxCount];
    }
    
    _selectedDic = [[NSMutableDictionary alloc] init];
    [self createRightBarButton];
    
    _pageCount = 10;
    
    //collectionview
    WaterfallLayout *layout = [[WaterfallLayout alloc] init];
    [self createCollectionViewLayout:layout Action:@"photo" Param:nil Header:YES Foot:YES];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ClassActivityCell"];
    [self beginRefresh];
}

- (void)backToPreControl:(id)sender
{
    NSArray *allValues = _selectedDic.allValues;
    if (allValues.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSIndexPath *indexPath in allValues) {
            ThemeBatchItem *item = self.dataSource[indexPath.item];
            [array addObject:item];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(selectAlbumsFromPre:)]) {
            [_delegate selectAlbumsFromPre:array];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetCollectionFootView
{
    if ([self.dataSource count] == 0) {
        _tipView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 112) / 2, ([UIScreen mainScreen].bounds.size.height - 64 - 118) / 2, 112, 118)];
        [_tipView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon19" ofType:@"png"]]];
        [self.view addSubview:_tipView];
    }
    else
    {
        [_tipView removeFromSuperview];
        _tipView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - UI
- (void)createRightBarButton
{
    //返回按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(makeSure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

#pragma mark - actions
- (void)makeSure:(id)sender
{
    NSArray *allValues = _selectedDic.allValues;
    if (allValues.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    _changeArr = [NSMutableArray array];
    for (NSIndexPath *indexPath in allValues) {
        ThemeBatchItem *item = self.dataSource[indexPath.item];
        NSString *url = item.path;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        if ([url rangeOfString:@"{"].location != NSNotFound) {
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [_changeArr addObject:url];
    }
    
    for (ThemeBatchItem *item in _otherArr) {
        NSString *url = item.path;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        if ([url rangeOfString:@"{"].location != NSNotFound) {
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [_changeArr addObject:url];
    }

    _downImgs = [NSMutableArray array];
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    [self beginDownLoadImgs];
    
}

#pragma mark - 图片下载
- (void)beginDownLoadImgs
{
    @try {
        NSString *url = [_changeArr firstObject];
        [_changeArr removeObject:url];
        __weak typeof(self)weakSelf= self;
        __weak typeof(_changeArr)weakImgs = _changeArr;
        __weak typeof(_downImgs)weakDownImgs = _downImgs;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [weakSelf downFinish:NO];
                }
                else
                {
                    [weakDownImgs addObject:image];
                    if (weakImgs.count == 0) {
                        [weakSelf downFinish:YES];
                    }
                    else
                    {
                        [weakSelf beginDownLoadImgs];
                    }
                }
            });
            
        }];
    } @catch (NSException *e) {
        [self downFinish:NO];
    }
}

- (void)downFinish:(BOOL)suc
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    if (suc) {
        [_delegate selectClass:_downImgs];
    }
    else
    {
        [self.view makeToast:@"原始图片下载异常" duration:1.0 position:@"center"];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassPhotoList"];
    [param setObject:_photoItem.album_id ?: @"" forKey:@"album_id"];
    [param setObject:_photoItem.mileage_type ?: @"" forKey:@"mileage_type"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
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
    }
    
    WaterfallLayout *layout = (WaterfallLayout *)_collectionView.collectionViewLayout;
    [layout clearLayoutArrributes];
    [_collectionView reloadData];
    [self resetCollectionFootView];
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
        NSMutableArray *paths = [NSMutableArray array];
        NSInteger count = [self.dataSource count];
        for (id subDic in data) {
            NSError *error;
            ThemeBatchModel *themeBatch = [[ThemeBatchModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [array addObjectsFromArray:themeBatch.photos];
            for (int i = 0;i < themeBatch.photos.count;i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count++ inSection:0];
                [paths addObject:indexPath];
            }
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
        }
        [self.dataSource addObjectsFromArray:array];
        [_collectionView insertItemsAtIndexPaths:paths];
        
        if ([self.dataSource count] == array.count) {
            [self resetCollectionFootView];
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
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ClassActivityCell" forIndexPath:indexPath];
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg) {
        //face
        faceImg = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [faceImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [faceImg setContentMode:UIViewContentModeScaleAspectFill];
        faceImg.clipsToBounds = YES;
        [faceImg setTag:1];
        [faceImg setBackgroundColor:BACKGROUND_COLOR];
        [cell.contentView addSubview:faceImg];
        
        //tip
        UIImageView *tipImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected.png"]];
        [tipImg setFrame:CGRectMake(faceImg.frame.size.width - 5 - 18, faceImg.frame.size.height - 5 - 18, 18, 18)];
        tipImg.translatesAutoresizingMaskIntoConstraints = NO;
        [tipImg setBackgroundColor:[UIColor clearColor]];
        [tipImg setTag:2];
        [faceImg addSubview:tipImg];
        NSArray *layouts2 = [NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:tipImg attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:faceImg attribute:NSLayoutAttributeRight multiplier:1 constant:-5],[NSLayoutConstraint constraintWithItem:tipImg attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:faceImg attribute:NSLayoutAttributeBottom multiplier:1 constant:-5], nil];
        [faceImg addConstraints:layouts2];
        
        //video
        UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((faceImg.frame.size.width - 30) / 2, (faceImg.frame.size.height - 30) / 2, 30, 30)];
        [videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [videoImg setTag:3];
        [videoImg setBackgroundColor:[UIColor clearColor]];
        videoImg.translatesAutoresizingMaskIntoConstraints = NO;
        [faceImg addSubview:videoImg];
        
        [faceImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:faceImg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:faceImg attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
    }
    
    ThemeBatchItem *item = self.dataSource[indexPath.item];
    [faceImg setImage:nil];
    NSString *fileName = [item.path lastPathComponent];
    BOOL mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
    NSString *lastpath = mp4 ? item.path : item.thumb;
    NSString *url = [lastpath hasPrefix:@"http"] ? lastpath : [G_IMAGE_ADDRESS stringByAppendingString:lastpath ?: @""];
    if (mp4) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:url] atTime:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [faceImg setImage:image];
            });
        });
    }
    else
    {
        [faceImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    //tip
    UIImageView *tipImg = (UIImageView *)[faceImg viewWithTag:2];
    NSString *value = [_selectedDic valueForKey:[NSString stringWithFormat:@"section%ld_row%ld",(long)indexPath.section,(long)indexPath.item]];
    if (value) {
        tipImg.hidden = NO;
    }
    else
    {
        BOOL hidden = YES;
        for (ThemeBatchItem *subItem in _otherArr) {
            if ([subItem.id isEqualToString:item.id]) {
                hidden = NO;
                break;
            }
        }
        tipImg.hidden = hidden;
    }
    
    //video
    UIImageView *videoImg = (UIImageView *)[faceImg viewWithTag:3];
    videoImg.hidden = !mp4;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg.image) {
        return;
    }
    
    UIImageView *tipImage = (UIImageView *)[faceImg viewWithTag:2];
    NSInteger count = _selectedDic.allValues.count;
    NSString *key = [NSString stringWithFormat:@"section%ld_row%ld",(long)indexPath.section,(long)indexPath.item];
    id value = [_selectedDic valueForKey:key];
    if (value) {
        [_selectedDic removeObjectForKey:key];
        tipImage.hidden = YES;
    }
    else
    {
        BOOL found = NO;
        ThemeBatchItem *item = self.dataSource[indexPath.item];
        for (ThemeBatchItem *subItem in _otherArr) {
            if ([subItem.id isEqualToString:item.id]) {
                [_otherArr removeObject:subItem];
                found = YES;
                break;
            }
        }
        
        if (found) {
            _nMaxCount += 1;
            tipImage.hidden = YES;
        }
        else
        {
            if (count >= _nMaxCount) {
                return;
            }
            
            if ([item.path hasSuffix:@"mp4"]) {
                [self.view makeToast:@"不可选择视频" duration:1.0 position:@"center"];
                return;
            }
            
            [_selectedDic setObject:indexPath forKey:key];
            tipImage.hidden = NO;
        }
    }
    
    self.titleLable.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)_selectedDic.allValues.count,(long)_nMaxCount];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

@end
