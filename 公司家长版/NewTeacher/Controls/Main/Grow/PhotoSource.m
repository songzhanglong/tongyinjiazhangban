//
//  PhotoSource.m
//  NewTeacher
//
//  Created by szl on 16/6/22.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "PhotoSource.h"
#import "SelectedPhotosCell.h"
#import "SelectPhotosModel.h"
#import "Toast+UIView.h"

@implementation PhotoSource
{
    NSIndexPath *_indexPath,*_beginIndexPath;
    BOOL _isShowTip;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isShowTip = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowSelectPhotos"];
    }
    
    return self;
}

- (void)createCollectionViewTo:(UIView *)view{
    DJTCollectionViewFlowLayout *layout = [[DJTCollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc]initWithFrame:view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[SelectedPhotosCell class] forCellWithReuseIdentifier:@"selectAlbumItem1"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selectPhotosHeader"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"selectPhotosHeader2"];
    [_collectionView setBackgroundColor:view.backgroundColor];
    [view addSubview:_collectionView];
}

- (void)cancelPromptAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"使用提示" message:@"您希望下次还看到这条提示语吗？" delegate:self cancelButtonTitle:@"不用了" otherButtonTitles:@"还要看", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _isShowTip = YES;
    [_collectionView reloadData];
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:_isShowTip forKey:@"isShowSelectPhotos"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SelectPhotosModel *model = [_resource objectAtIndex:_indexPath.item];
    if (buttonIndex == 1) {
        [_resource removeObject:model];
        if (model.isCover) {
            for (SelectPhotosModel *tmpModel in _resource) {
                if ((tmpModel.type == 0) && (_isSmallPicLimit || (tmpModel.width.floatValue >= _minWei && tmpModel.height.floatValue >= _minHei))) {
                    tmpModel.isCover = YES;
                    break;
                }
            }
        }
        [_collectionView reloadData];
    }
    if (buttonIndex == 2) {
        if (model.type != 0) {
            //[[_collectionView superview] makeToast:@"视频不能设置成封面" duration:1.0 position:@"center"];
            return;
        }
        //
        if (_isSmallPicLimit || (model.width.floatValue >= _minWei && model.height.floatValue >= _minHei)) {
            for (SelectPhotosModel *item in _resource) {
                if (item.isCover) {
                    item.isCover = NO;
                    break;
                }
            }
            model.isCover = YES;
            [_collectionView reloadData];
        }
    }
    else{
        if (_delegate && [_delegate respondsToSelector:@selector(actionDidIndex:PhotoModel:)]) {
            [_delegate actionDidIndex:buttonIndex PhotoModel:model];
        }
    }
    
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margin = 10,midMargin = 2;
    CGFloat count = 5;
    
    CGFloat itemWei = (SCREEN_WIDTH - margin * 2 - midMargin * (count - 1)) / count,itemHei = itemWei;
    return CGSizeMake(itemWei, itemHei);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (!_isShowTip && ([_resource count] > 0)) {
        return CGSizeMake(SCREEN_WIDTH, 14);
    }
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([_resource count] > 0) {
        return CGSizeMake(SCREEN_WIDTH, 20);
    }
    return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([_resource count] > 0) {
        return UIEdgeInsetsMake(0, 2, 10, 10);
    }
    else{
        return UIEdgeInsetsMake(0, 10, 0, 10);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_resource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SelectedPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectAlbumItem1" forIndexPath:indexPath];
    SelectPhotosModel *phtotModel = _resource[indexPath.item];
    if ([_resource count] > 1) {
        cell.fmImgView.hidden = !phtotModel.isCover;
    }else {
        cell.fmImgView.hidden = YES;
    }
    [cell resetDataSource:phtotModel];
    [cell.hdImg setHidden:(phtotModel.type != 0) || (phtotModel.width.floatValue < _minWei || phtotModel.height.floatValue < _minHei)];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([_resource count] > 0) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            UICollectionReusableView *headerView =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"selectPhotosHeader" forIndexPath:indexPath];
            UILabel *hSub = (UILabel *)[headerView viewWithTag:1];
            if (!hSub) {
                hSub = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 80, 14)];
                [hSub setBackgroundColor:[UIColor clearColor]];
                [hSub setTag:1];
                [hSub setTextColor:[UIColor whiteColor]];
                [hSub setFont:[UIFont systemFontOfSize:10]];
                [headerView addSubview:hSub];
            }
            [hSub setText:@"点击可查看、删除或设为封面，长按可拖动调整顺序。"];
            
            UIButton *btn = (UIButton *)[headerView viewWithTag:2];
            if (!btn) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(hSub.frameRight, 0, 42, 14)];
                [btn setImage:CREATE_IMG(@"close_tip") forState:UIControlStateNormal];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 1, 30)];
                [btn addTarget:self action:@selector(cancelPromptAction:) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:btn];
            }
            
            return headerView;
        }
        else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
            UICollectionReusableView *headerView =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"selectPhotosHeader2" forIndexPath:indexPath];
            UILabel *hSub = (UILabel *)[headerView viewWithTag:1];
            if (!hSub) {
                hSub = [[UILabel alloc] init];
                [hSub setBackgroundColor:[UIColor clearColor]];
                [hSub setTag:1];
                [hSub setTextColor:[UIColor whiteColor]];
                [hSub setFont:[UIFont systemFontOfSize:10]];
                [headerView addSubview:hSub];
            }
            [hSub setFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 14)];
            [hSub setText:[NSString stringWithFormat:@"当前已选%ld张，还能再选%ld张",(long)[_resource count], 9 - (long)[_resource count]]];
            
            UILabel *lineSub = (UILabel *)[headerView viewWithTag:2];
            if (!lineSub) {
                lineSub = [[UILabel alloc] init];
                [lineSub setBackgroundColor:[UIColor clearColor]];
                [lineSub setTag:2];
                lineSub.lineBreakMode = NSLineBreakByCharWrapping;
                [lineSub setTextColor:[UIColor whiteColor]];
                [lineSub setFont:[UIFont systemFontOfSize:8]];
                [headerView addSubview:lineSub];
                [lineSub setFrame:CGRectMake(10, hSub.frameBottom, SCREEN_WIDTH - 20, 6)];
                [lineSub setText:@"--------------------------------------------------------------------------------------------------------------"];
            }
            
            return headerView;
        }
    }
    
    return nil;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    SelectPhotosModel *model = [_resource objectAtIndex:_indexPath.item];
    if (model.type != 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看",@"删除", nil];
        [actionSheet showInView:[collectionView superview]];
    }else {
        if (_isSmallPicLimit || (model.width.floatValue >= _minWei && model.height.floatValue >= _minHei)) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看",@"删除",@"设为封面", nil];
            [actionSheet showInView:[collectionView superview]];
        }
        else{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看",@"删除", nil];
            [actionSheet showInView:[collectionView superview]];
        }
    }
}

#pragma mark - DJTCollectionViewDataSource methods
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    _beginIndexPath = indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = _resource[_beginIndexPath.item];
    if (_beginIndexPath.item < indexPath.item) {
        [_resource insertObject:object atIndex:indexPath.item + 1];
        [_resource removeObjectAtIndex:_beginIndexPath.item];
    }
    else if (_beginIndexPath.item > indexPath.item){
        [_resource removeObject:object];
        [_resource insertObject:object atIndex:indexPath.item];
    }
}

@end
