//
//  GrowMakeCell.m
//  NewTeacher
//
//  Created by szl on 16/1/29.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "GrowMakeCell.h"
#import "GrowTermModel.h"
#import "DJTGlobalManager.h"

@interface GrowMakeCell()

@property (nonatomic,strong)UICollectionView *collectionView;

@end

@implementation GrowMakeCell
{
    UIImageView *_imageView;
    UILabel *_titleLab;
    NSArray *_dataSource;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 25, 166)];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_imageView];
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 15, 20, _imageView.frame.size.height - 30)];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        [_titleLab setNumberOfLines:0];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont boldSystemFontOfSize:16];
        [_imageView addSubview:_titleLab];
        
        //视图
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(81, 146);
        CGFloat margin = 10;
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = margin;
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(_imageView.frameRight, 0, [UIScreen mainScreen].bounds.size.width - _imageView.frameRight, 166) collectionViewLayout:layout];
        _collectionView.backgroundColor = CreateColor(33.0, 27.0, 25.0);
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GrowMakeCell"];
        [self.contentView addSubview:_collectionView];
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    GrowExtendModel *extendModel = (GrowExtendModel *)object;
    _dataSource = extendModel.list;
    [_collectionView reloadData];
    [_titleLab setText:extendModel.album_title];
    NSString *str = @"grow_bg_type2@2x";
    if ([extendModel.album_type integerValue] == 3) {
        str = @"grow_bg_type3@2x";
    }else if ([extendModel.album_type integerValue] == 2){
        str = @"grow_bg_type1@2x";
    }
    [_imageView setImage:CREATE_IMG(str)];
}

- (void)reloadIndexPath:(NSInteger)index
{
    [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)editTemplate:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(editGrowCell:At:)]) {
        UICollectionViewCell *collec = [DJTGlobalManager viewController:sender Class:[UICollectionViewCell class]];
        NSIndexPath *indexPath = [_collectionView indexPathForCell:collec];
        [_delegate editGrowCell:self At:indexPath.item];
    }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GrowMakeCell" forIndexPath:indexPath];
    
    CGSize itemSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg) {
        //face
        faceImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height - 16)];
        faceImg.contentMode = UIViewContentModeScaleAspectFill;
        faceImg.clipsToBounds = YES;
        [faceImg setBackgroundColor:CreateColor(220, 220, 221)];
        [faceImg setTag:1];
        
        [cell.contentView addSubview:faceImg];
        
        UIButton *tipBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [tipBut setTag:2];
        [tipBut addTarget:self action:@selector(editTemplate:) forControlEvents:UIControlEventTouchUpInside];
        [tipBut setFrame:CGRectMake(0, itemSize.height - 16 - 22, itemSize.width, 22)];
        [tipBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tipBut.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [cell.contentView addSubview:tipBut];
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, itemSize.height - 14, itemSize.width, 14)];
        [nameLab setBackgroundColor:collectionView.backgroundColor];
        [nameLab setTextAlignment:NSTextAlignmentCenter];
        [nameLab setTextColor:[UIColor whiteColor]];
        [nameLab setFont:[UIFont boldSystemFontOfSize:10]];
        [nameLab setTag:3];
        [cell.contentView addSubview:nameLab];
    }
    
    UIButton *tipBut = (UIButton *)[cell.contentView viewWithTag:2];
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:3];
    
    [faceImg setImage:nil];
    GrowAlbumModel *growAlbum = _dataSource[indexPath.item];
    [nameLab setText:growAlbum.template_title];
    
    NSString *str = growAlbum.image_path;
    BOOL newStr = NO;
    if ((str && ![str isKindOfClass:[NSNull class]]) && ([str length] > 2)) {
        str = growAlbum.image_thumb ?: str;
        newStr = YES;
    }
    str = newStr ? str : growAlbum.template_path_thumb;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_GROW_ADDRESS stringByAppendingString:str ?: @""];
    }
    [faceImg setImageWithURL:[NSURL URLWithString:str]];
    
    if ([growAlbum.allow_parent integerValue] != 0) {
        [tipBut setHidden:NO];
        [tipBut setTitle:newStr ? @"编辑" : @"制作" forState:UIControlStateNormal];
        [tipBut setBackgroundColor:newStr ? rgba(139, 203, 87, 0.8) : rgba(101, 205, 205, 0.8)];
    }
    else{
        [tipBut setHidden:YES];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //查看
    if (_delegate && [_delegate respondsToSelector:@selector(selectGrowCell:At:)]) {
        [_delegate selectGrowCell:self At:indexPath.item];
    }
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
