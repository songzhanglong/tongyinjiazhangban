//
//  BabyMileageToClassViewController.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "BabyMileageToClassViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "UIImage+Caption.h"
#import "MileagePermissionsViewController.h"

@interface BabyMileageToClassViewController ()<MileagePermissionsDelegate>

@end

@implementation BabyMileageToClassViewController
{
    BOOL _lastPage;
    NSMutableArray *_selectedArr;
    int _indexType;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    self.titleLable.text = @"宝宝里程";
    
    self.useNewInterface = YES;
    _indexType = 3;
    
    _selectedArr = [NSMutableArray array];
    if (_selectModel) {
        [_selectedArr addObject:_selectModel];
    }
    
    //[self createRightButton];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWei = (winSize.width - 4 * margin) / 3,itemHei = itemWei;
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    [self createCollectionViewLayout:layout Action:@"photo" Param:[self requestParam] Header:YES Foot:NO];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"mileagePhotoCell"];
    
    [self beginRefresh];
}

- (void)createRightButton{
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60.0, 30.0)];
    [moreBtn setTitle:@"权限" forState:UIControlStateNormal];
    [moreBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(selectPresed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)selectPresed:(id)sender
{
    MileagePermissionsViewController *permissor = [[MileagePermissionsViewController alloc] init];
    permissor.indexToType = [NSString stringWithFormat:@"%d",_indexType];
    permissor.delegate = self;
    [self.navigationController pushViewController:permissor animated:YES];
}

#pragma mark - MileagePermissionsDelegate
- (void)permissionsToSelect:(int)indexType
{
    _indexType = indexType;
}

#pragma mark - 重载
- (void)backToPreControl:(id)sender
{
    if (_selectedArr.count > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(synchronizedTheme:PermissionsType:)]) {
            MileageModel *model = _selectedArr[0];
            [_delegate synchronizedTheme:model PermissionsType:_indexType];
        }
    }else {
        if (_delegate && [_delegate respondsToSelector:@selector(setDesSelectButton)]) {
            [_delegate setDesSelectButton];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 参数配置
- (NSMutableDictionary *)requestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getMileageAlbums"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    return param;
}
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        
        NSMutableArray *array = [NSMutableArray array];
        ret_data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (id subDic in ret_data) {
            NSError *error;
            MileageThumbItem *model = [[MileageThumbItem alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            [model caculateNameHei];
            [array addObject:model];
        }
        
        self.dataSource = array;
    }
    else{
        self.dataSource = nil;
    }
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mileagePhotoCell" forIndexPath:indexPath];
    UIImageView *contentImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!contentImg) {
        //face
        contentImg = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [contentImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [contentImg setContentMode:UIViewContentModeScaleAspectFill];
        contentImg.clipsToBounds = YES;
        [contentImg setTag:1];
        [contentImg setBackgroundColor:BACKGROUND_COLOR];
        [cell.contentView addSubview:contentImg];
        
        //video
        UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((contentImg.frame.size.width - 30) / 2, (contentImg.frame.size.height - 30) / 2, 30, 30)];
        [videoImg setImage:CREATE_IMG(@"mileageVideo")];
        [videoImg setTag:2];
        [videoImg setBackgroundColor:[UIColor clearColor]];
        videoImg.translatesAutoresizingMaskIntoConstraints = NO;
        [contentImg addSubview:videoImg];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, contentImg.frame.size.height - 26, contentImg.frame.size.width, 26)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.6;
        [bgView setTag:3];
        [contentImg addSubview:bgView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, contentImg.frame.size.height - 20 - 3, contentImg.frame.size.width - 10, 20)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:12];
        nameLabel.numberOfLines = 0;
        [nameLabel setTag:4];
        [contentImg addSubview:nameLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(contentImg.frame.size.width - 35, 5, 30, 30)];
        imgView.image = CREATE_IMG(@"bb2_1@2x");
        [imgView setTag:5];
        imgView.hidden = YES;
        [contentImg addSubview:imgView];
        
        [contentImg addConstraints:[NSArray arrayWithObjects:[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentImg attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],[NSLayoutConstraint constraintWithItem:videoImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentImg attribute:NSLayoutAttributeCenterY multiplier:1 constant:0], nil]];
    }
    
    MileageThumbItem *item = self.dataSource[indexPath.item];
    [contentImg setImage:nil];
    NSString *fileName = [item.thumb lastPathComponent];
    BOOL mp4 = [[[fileName pathExtension] lowercaseString] isEqualToString:@"mp4"];
    NSString *url = [item.thumb hasPrefix:@"http"] ? item.thumb : (mp4 ? [G_IMAGE_ADDRESS stringByAppendingString:item.thumb ?: @""] : [G_IMAGE_ADDRESS stringByAppendingString:item.thumb ?: @""]);
    if (mp4) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] atTime:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [contentImg setImage:image];
            });
        });
    }
    else
    {
        [contentImg setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    //video
    UIImageView *videoImg = (UIImageView *)[contentImg viewWithTag:2];
    videoImg.hidden = !mp4;
    
    UIView *_bgView = (UIView *)[contentImg viewWithTag:3];
    [_bgView setFrame:CGRectMake(0, contentImg.frame.size.height - item.nameHei - 6, contentImg.frame.size.width, item.nameHei + 6)];

    UILabel *_nameLabel = (UILabel *)[contentImg viewWithTag:4];
    [_nameLabel setFrame:CGRectMake(5, contentImg.frame.size.height - item.nameHei - 3, contentImg.frame.size.width - 10, item.nameHei)];
    _nameLabel.text = item.name;
    
    int indexItem = -1;
    if ([_selectedArr count] > 0) {
        MileageModel *model = [_selectedArr objectAtIndex:0];
        for (int i = 0; i < [self.dataSource count]; i++) {
            MileageModel *lastModel = [self.dataSource objectAtIndex:i];
            if ([model.album_id isEqualToString:lastModel.album_id]) {
                indexItem = i;
                break;
            }
        }
    }
    UIImageView *_imgView = (UIImageView *)[contentImg viewWithTag:5];
    _imgView.hidden = !(indexPath.item == indexItem);

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MileageModel *currModel = [self.dataSource objectAtIndex:indexPath.item];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *contentImg = (UIImageView *)[cell.contentView viewWithTag:1];
    UIImageView *tipImg = (UIImageView *)[contentImg viewWithTag:5];
    tipImg.hidden = NO;
    
    if ([_selectedArr count] == 0) {
        [_selectedArr addObject:currModel];
    }else {
        int item = -1;
        MileageModel *model = [_selectedArr objectAtIndex:0];
        for (int i = 0; i < [self.dataSource count]; i++) {
            MileageModel *lastModel = [self.dataSource objectAtIndex:i];
            if ([model.album_id isEqualToString:lastModel.album_id]) {
                item = i;
                break;
            }
        }
        if (item < 0) {
            return;
        }else if (item == indexPath.item) {
            [_selectedArr removeAllObjects];
            tipImg.hidden = YES;
            return;
        }
        UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
        UIImageView *lastContentImg = (UIImageView *)[lastCell.contentView viewWithTag:1];
        UIImageView *lastTipImg = (UIImageView *)[lastContentImg viewWithTag:5];
        lastTipImg.hidden = YES;
        [_selectedArr removeAllObjects];
        [_selectedArr addObject:currModel];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
