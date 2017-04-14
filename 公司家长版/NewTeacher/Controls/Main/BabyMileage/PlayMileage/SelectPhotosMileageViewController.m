//
//  SelectPhotosMileageViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectPhotosMileageViewController.h"
#import "Toast+UIView.h"
#import "GrowAlbumListItem.h"
#import "SelectPhotosCell.h"
#import "SelectedPhotosCell.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import "CreatePlayMileageViewController.h"
#import "MWPhotoBrowser.h"
#import "SelectMileageViewController.h"
#import "PlayMileageListController.h"

@interface SelectPhotosMileageViewController ()<MWPhotoBrowserDelegate,SelectPhotosCellDelegate>

@end

@implementation SelectPhotosMileageViewController
{
    BOOL _lastPage;
    NSInteger _pageIdx,_pageCount;
    UIView *_tipView;
    NSMutableArray *_mwphotos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.showBack = YES;
    self.useNewInterface = YES;
    self.titleLable.text = @"图片与视频";
    self.titleLable.textColor = [UIColor whiteColor];
    
    [self createLeftBut];
    UIButton *leftBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [leftBut setFrame:CGRectMake(0, 0, 40, 30)];
    [leftBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    
    [self createRightButton];
    
    self.view.backgroundColor = CreateColor(33.0, 27.0, 25.0);
    
    _pageCount = 20;
    if ([_otherArr count] <= 0) {
        _otherArr = [NSMutableArray array];
    }
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [self createCollectionViewLayout:layout Action:@"mileage" Param:nil Header:YES Foot:YES];
    [_collectionView setAutoresizingMask:UIViewAutoresizingNone];
    [_collectionView setFrame:CGRectMake(0, 0, winSize.width, winSize.height - 64 - 44)];
    [_collectionView registerClass:[SelectedPhotosCell class] forCellWithReuseIdentifier:@"selectAlbumItem1"];
    [_collectionView registerClass:[SelectPhotosCell class] forCellWithReuseIdentifier:@"selectAlbumItem2"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selectPhotosHeader"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"selectPhotosFooter"];
    [_collectionView setBackgroundColor:self.view.backgroundColor];
    _collectionView.alwaysBounceVertical = YES;
    [self beginRefresh];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.frameWidth, 44)];
    [bottomView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:bottomView];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(winSize.width - 60 , 11.5, 50, 21)];
    [rightBut setBackgroundColor:rgba(25, 161, 86, 1)];
    [rightBut setTitle:@"确认" forState:UIControlStateNormal];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:12]];
    rightBut.layer.masksToBounds = YES;
    rightBut.layer.cornerRadius = 2;
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut addTarget:self action:@selector(addImageAndVideo:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rightBut];
}

- (void)createLeftBut
{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateSelected];
    [backBtn addTarget:self action:@selector(backToFather:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
}

- (void)backToFather:(id)sender
{
    if (_editType == 3 && [_album_id integerValue] != 0) {
        for (id controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[SelectMileageViewController class]]) {
                SelectMileageViewController *createController = (SelectMileageViewController *)controller;
                createController.theme_id = _theme_id;
                createController.album_id = _album_id;
                createController.editType = 3;
                createController.editTitle = _editTitle;
                createController.otherArr = _otherArr;
                [self.navigationController popToViewController:createController animated:YES];
            }else if ([controller isKindOfClass:[PlayMileageListController class]]) {
                [(PlayMileageListController *)controller isRefresh];
            }
        }
    }else{
        if (_editType == 3) {
            for (id controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[PlayMileageListController class]]) {
                    [(PlayMileageListController *)controller isRefresh];
                }
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)createRightButton{
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 60.0, 30.0);
    [moreBtn setTitle:@"预览" forState:UIControlStateNormal];
    [moreBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(previewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)previewAction:(id)sender
{
    if ([_otherArr count] <= 0) {
        [self.view makeToast:@"您还没有选择照片，无法预览" duration:1.0 position:@"center"];
        return;
    }
    
    _mwphotos = [NSMutableArray arrayWithArray:_otherArr];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:0];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    browser.selectedCount = [_otherArr count];
    browser.totalCount = [_otherArr count];

    [self.navigationController pushViewController:browser animated:YES];
}

- (void)addImageAndVideo:(id)sender
{
    if ([_otherArr count] <= 0) {
        [self.view makeToast:@"您还没有选择照片，无法制作里程视频" duration:1.0 position:@"center"];
        return;
    }
    CreatePlayMileageViewController *createController = [[CreatePlayMileageViewController alloc] init];
    createController.selectDataArray = _otherArr;
    createController.album_id = _album_id;
    createController.createType = _editType;
    createController.theme_id = _theme_id;
    createController.editTitle = _editTitle;
    [self.navigationController pushViewController:createController animated:YES];
}

- (void)createTipView
{
    if ([self.dataSource count] == 0) {
        if (!_tipView) {
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 128)];
            [_tipView setCenter:_collectionView.center];
            [_tipView setBackgroundColor:_collectionView.backgroundColor];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 0, 100, 100)];
            [imageView setImage:CREATE_IMG(@"contact_a")];
            [imageView setBackgroundColor:_tipView.backgroundColor];
            [_tipView addSubview:imageView];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frameBottom + 10, _tipView.frameWidth, 18)];
            [label1 setFont:[UIFont systemFontOfSize:14]];
            [label1 setTextColor:[UIColor whiteColor]];
            [label1 setBackgroundColor:_tipView.backgroundColor];
            [label1 setTextAlignment:NSTextAlignmentCenter];
            [label1 setText:@"对应里程中无照片或视频..."];
            [_tipView addSubview:label1];
        }
        [self.view addSubview:_tipView];
    }
    else{
        [_tipView removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = CreateColor(33.0, 27.0, 25.0);
    }
    else
    {
        navBar.tintColor = CreateColor(33.0, 27.0, 25.0);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAlbumPhotos2"];
    [param setObject:_album_id forKey:@"album_id"];
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
        if (data && [data isKindOfClass:[NSArray class]]) {
            array = [GrowAlbumListItem arrayOfModelsFromDictionaries:data error:nil];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
    }
    [_collectionView reloadData];
    [self createTipView];
}

- (void)requestFinish2:(BOOL)success Data:(id)result
{
    [super requestFinish2:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        id pageSize = [ret_data valueForKey:@"pageCount"];
        _lastPage = _pageIdx >= [pageSize integerValue];
        
        NSArray *data = [ret_data valueForKey:@"list"];
        NSMutableArray *paths = [NSMutableArray array];
        NSInteger count = [self.dataSource count];
        NSMutableArray *array = [NSMutableArray array];
        if (data && [data isKindOfClass:[NSArray class]]) {
            array = [GrowAlbumListItem arrayOfModelsFromDictionaries:data error:nil];
            for (NSInteger i = 0; i < array.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count++ inSection:1];
                [paths addObject:indexPath];
            }
        }
        
        if (!self.dataSource) {
            self.dataSource = [NSMutableArray array];
            [self createTipView];
        }
        [self.dataSource addObjectsFromArray:array];
        [_collectionView insertItemsAtIndexPaths:paths];
    }
    else
    {
        if (_pageIdx > 1) {
            _pageIdx -= 1;
        }
    }
}

#pragma mark - SelectPhotosCellDelegate
- (void)preShowBigView:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    GrowAlbumListItem *item = self.dataSource[indexPath.item];
    NSInteger count = 0;
    BOOL shouldSel = (_otherArr.count < 30);
    for (GrowAlbumListItem *subItem in _otherArr) {
        if ([subItem.photo_id isEqualToString:item.photo_id]) {
            count = 1;
            shouldSel = YES;
            item = subItem;
            break;
        }
    }
    
    _mwphotos = [NSMutableArray arrayWithObject:item];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    if (shouldSel) {
        browser.selectedCount = count;
        browser.totalCount = 1;
    }
    
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = 10,midMargin = (indexPath.section == 0) ? 2 : 5;
    CGFloat count = (indexPath.section == 0) ? 5 : 4;
    
    CGFloat itemWei = (SCREEN_WIDTH - margin * 2 - midMargin * (count - 1)) / count,itemHei = itemWei;
    return CGSizeMake(itemWei, itemHei);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH, 16);
    }
    else{
        return CGSizeMake(0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return (section == 0) ? 2 : 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (section == 0) ? 2 : 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH, 1);
    }
    else{
        return CGSizeMake(0, 0);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        if ([_otherArr count] > 0) {
            return UIEdgeInsetsMake(10, 10, 10, 10);
        }
        else{
            return UIEdgeInsetsMake(0, 10, 0, 10);
        }
    }
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_otherArr count];
    }
    
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        SelectedPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectAlbumItem1" forIndexPath:indexPath];
        [cell resetDataSource:_otherArr[indexPath.item]];
        
        return cell;
    }
    else{
        SelectPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectAlbumItem2" forIndexPath:indexPath];
        cell.selBut.hidden = NO;
        cell.fromLab.hidden = YES;
        cell.delegate = self;
        GrowAlbumListItem *item = self.dataSource[indexPath.item];
        [cell resetDataSource:item];
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            UICollectionReusableView *headerView =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selectPhotosHeader" forIndexPath:indexPath];
            UILabel *hSub = (UILabel *)[headerView viewWithTag:1];
            if (!hSub) {
                hSub = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 16)];
                [hSub setBackgroundColor:[UIColor clearColor]];
                [hSub setTag:1];
                [hSub setTextColor:[UIColor whiteColor]];
                [hSub setFont:[UIFont systemFontOfSize:12]];
                [headerView addSubview:hSub];
            }
            int count = 0;
            for (GrowAlbumListItem *model in _otherArr) {
                if (model.type.integerValue != 0) {
                    count++;
                }
            }
            [hSub setText:[NSString stringWithFormat:@"已经添加了%ld张照片/%ld个视频",(long)_otherArr.count - count,(long)count]];
            hSub.hidden = ([self.dataSource count] == 0);
            
            return headerView;
        }
        else if([kind isEqualToString:UICollectionElementKindSectionFooter]){
            UICollectionReusableView *footerView =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"selectPhotosFooter" forIndexPath:indexPath];
            UIView *fSub = [footerView viewWithTag:1];
            if (!fSub) {
                fSub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerView.bounds.size.width, 1)];
                [fSub setBackgroundColor:rgba(54, 44, 41, 1)];
                [fSub setTag:1];
                [fSub setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                [footerView addSubview:fSub];
            }
            
            fSub.hidden = ([_otherArr count] == 0);
            return footerView;
        }
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isRefreshing]) {
        [self.view makeToast:@"数据正在刷新,请稍候再试" duration:1.0 position:@"center"];
        return;
    }
    
    if (indexPath.section == 1) {
        SelectPhotosCell *cell = (SelectPhotosCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.contentImg.image) {
            if ([_otherArr count] >= 30) {
                [self.view makeToast:@"最多只能添加30张图片或视频" duration:1.0 position:@"center"];
            }
            else{
                BOOL hasSel = NO;
                GrowAlbumListItem *item = self.dataSource[indexPath.item];
                for (GrowAlbumListItem *subItem in _otherArr) {
                    if ([subItem.photo_id isEqualToString:item.photo_id]) {
                        hasSel = YES;
                        break;
                    }
                }
                if (!hasSel) {
                    [_otherArr addObject:item];
                    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                }
            }
        }
    }
    else{
        [_otherArr removeObjectAtIndex:indexPath.item];
        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }
    
    [self setTitleWithSelectedIndexPaths:_otherArr];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _mwphotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _mwphotos.count)
    {
        GrowAlbumListItem *item = _mwphotos[index];
        NSString *path = item.path;
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
        }
        MWPhoto *photo = nil;
        if (item.type.integerValue != 0) {
            BOOL mp4 = [[[[item.thumb lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
            if (mp4) {
                photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:path]]];
            }
            else{
                NSString *tmpStr = item.thumb;
                if (![tmpStr hasPrefix:@"http"]) {
                    tmpStr = [G_IMAGE_ADDRESS stringByAppendingString:tmpStr ?: @""];
                }
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpStr]];
            }
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            NSURL *url = [NSURL URLWithString:path];
            photo = [MWPhoto photoWithURL:url];
        }
        return photo;
    }
    return nil;
}

- (BOOL)shouldSelectItemAt:(NSInteger)index
{
    MWPhoto *photo = _mwphotos[index];
    return [_otherArr containsObject:photo];
}

- (void)cancelSelectedItemAt:(NSInteger)index Should:(BOOL)sel
{
    MWPhoto *photo = _mwphotos[index];
    if (sel) {
        if (![_otherArr containsObject:photo]) {
            [_otherArr addObject:photo];
            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    else{
        [_otherArr removeObject:photo];
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    
    [self setTitleWithSelectedIndexPaths:_otherArr];
}

- (void)finishPreView:(NSInteger)index
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)selectItems
{
    UIButton *finishBtn = (UIButton *)[[self.navigationItem.rightBarButtonItems lastObject] customView];
    NSString *str = (selectItems.count == 0) ? @"预览" : [NSString stringWithFormat:@"预览(%ld)",(long)[selectItems count]];
    [finishBtn setTitle:str forState:UIControlStateNormal];
}

@end
