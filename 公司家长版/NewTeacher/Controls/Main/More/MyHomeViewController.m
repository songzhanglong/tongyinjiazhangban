//
//  MyHomeViewController.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/6.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MyHomeViewController.h"
#import "PersonInfoViewController.h"
#import "DJTWebViewController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "FamilNumberModel.h"
#import "NSObject+Reflect.h"
#import "MJRefresh.h"
#import "EditFamilyInfo.h"
#import "CTAssetsPickerController.h"
#import "UIButton+WebCache.h"
#import "AppDelegate.h"

@interface MyHomeViewController ()<SetPersonPhoneNumberDelegate,UITextFieldDelegate,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,EditFamilyInfoDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate>{
    
    UICollectionView    *_collectionView;
    MJRefreshHeaderView *_hView;
    BOOL                _editing;
    
    NSMutableArray      *_directFamily,*_collateralFamily;
    NSIndexPath         *_indexPath;
    NSInteger           _nIndex;
    EditFamilyInfo      *_editFamilyInfo;
    
    UILabel             *_otherLab;
}
@end

@implementation MyHomeViewController

- (void)dealloc
{
    [_hView free];
}

#pragma  mark  - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"我的家人";

    _directFamily = [NSMutableArray array];
    _collateralFamily = [NSMutableArray array];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIImage *backImg = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"w_bg" ofType:@"png"]];
    CGFloat hei = backImg.size.height * winSize.width / backImg.size.width;
    ;
    //UICollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWei = 45,itemHei = 64;
    NSInteger count = winSize.width / (itemWei + 10);
    CGFloat margin = (winSize.width - count * itemWei) / (count + 1);
    layout.itemSize = CGSizeMake(itemWei, itemHei);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, margin, 10, margin);
    layout.headerReferenceSize = CGSizeMake(winSize.width, hei + 30);
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myHomeCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHomeHeader"];
    [_collectionView setBackgroundColor:[UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1.0]];
    [self.view addSubview:_collectionView];
    
    MJRefreshHeaderView *hView = [MJRefreshHeaderView header];
    hView.scrollView = _collectionView;
    _hView = hView;
    __weak typeof(self)weakSelf = self;
    hView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView){
        [weakSelf getFamilyInfo];
    };
    [hView beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    if (_editFamilyInfo) {
        [self performSelector:@selector(addFaimilyInfoAfterOneSecond:) withObject:nil afterDelay:0.1];
    }
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collateralFamily.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myHomeCell" forIndexPath:indexPath];
    UIImageView *faceImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!faceImg) {
        //face
        faceImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 40, 40)];
        [faceImg.layer setMasksToBounds:YES];
        [faceImg.layer setCornerRadius:20];
        faceImg.layer.borderColor = [UIColor colorWithRed:147 / 255.0 green:96 / 255.0 blue:68 / 255.0 alpha:1.0].CGColor;
        [faceImg setTag:1];
        [cell.contentView addSubview:faceImg];
        
        //del
        UIButton *delBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBut setFrame:CGRectMake(25, 0, 20, 20)];
        [delBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w18" ofType:@"png"]] forState:UIControlStateNormal];
        [delBut setTag:2];
        [delBut addTarget:self action:@selector(delUserFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:delBut];
        
        //label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 40, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTag:3];
        [cell.contentView addSubview:label];
    }
    
    UIButton *delBut = (UIButton *)[cell.contentView viewWithTag:2];
    delBut.hidden = ((indexPath.item == 0) || !_editing);
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:3];
    if (indexPath.item == 0) {
        [label setText:@"添加"];
        [label setTextColor:[UIColor colorWithRed:97 / 255.0 green:187 / 255.0 blue:248 / 255.0 alpha:1]];
        [faceImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w9" ofType:@"png"]]];
        faceImg.layer.borderWidth = 0;
    }
    else
    {
        [label setTextColor:[UIColor blackColor]];
        faceImg.layer.borderWidth = 2;
    }
    
    if (indexPath.item == 0) {
        
    }
    else
    {
        FamilNumberModel *model = _collateralFamily[indexPath.item - 1];
        NSString *url = model.face;
        if (![url hasPrefix:@"http"]) {
            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
        }
        [faceImg setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[DJTGlobalManager shareInstance] getFamilyPicture:model.name] ofType:@"png"]]];
        [label setText:model.name];
        [label adjustsFontSizeToFitWidth];
    }
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    if (_editing) {
        if (indexPath.item != 0) {
            [self delUserFriend:nil];
        }else{
            _editing = !_editing;
            _otherLab.text = _editing ? @"取消" : @"编辑";
            [_collectionView reloadData];
            
            BOOL add = (indexPath.item == 0);
            [self popEditFamilyView:add ? kEditTypeAdd : kEditTypeCheck2 Model:add ? nil : _collateralFamily[indexPath.item - 1]];
        }
    }
    else
    {
        BOOL add = (indexPath.item == 0);
        [self popEditFamilyView:add ? kEditTypeAdd : kEditTypeCheck2 Model:add ? nil : _collateralFamily[indexPath.item - 1]];
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHomeHeader" forIndexPath:indexPath];
    
    UIView *subView = [view viewWithTag:10];
    if (!subView) {
        CGSize headerSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).headerReferenceSize;
        subView = [self createSectionHeaderView:headerSize.height - 30];
        [subView setTag:10];
        [view addSubview:subView];
    }
    
    return view;
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


#pragma mark - 表头
- (UIView *)createSectionHeaderView:(CGFloat)hei
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, hei + 30)];
    
    //backImg
    UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, hei)];
    [backImg setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"w_bg" ofType:@"png"]]];
    [backView addSubview:backImg];
    
    //mid img
    UIImageView *midImg = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 255) / 2, 20, 255, 255)];
    [midImg setImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"w13" ofType:@"png"]]];
    [backView addSubview:midImg];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    //head Img
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    [headImg setCenter:midImg.center];
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = 45;
    headImg.layer.borderColor = [UIColor whiteColor].CGColor;
    headImg.layer.borderWidth = 2.0;
    [headImg setUserInteractionEnabled:YES];
    [headImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchHeadImg:)]];
    [headImg setImageWithURL:[NSURL URLWithString:user.face] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [backView addSubview:headImg];
    
    //宝宝
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(headImg.center.x - 30, headImg.frame.origin.y - 30 + 5, 60, 20)];
    [label setTextAlignment:1];
    [label setFont:[UIFont systemFontOfSize:18]];
    [label setText:@"宝宝"];
    [label setBackgroundColor:[UIColor clearColor]];
    [backView addSubview:label];
    
    NSArray *tips = @[@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"外公",@"外婆"];
    NSArray *butRecs = @[NSStringFromCGRect(CGRectMake(headImg.frame.origin.x - 10 - 50, label.frame.origin.y, 50, 50)),NSStringFromCGRect(CGRectMake(headImg.frame.origin.x + headImg.frame.size.width + 10, label.frame.origin.y, 50, 50)),NSStringFromCGRect(CGRectMake(midImg.frame.origin.x, midImg.frame.origin.y + midImg.frame.size.height - 80, 40, 40)),NSStringFromCGRect(CGRectMake(headImg.frame.origin.x - 15, midImg.frame.origin.y + midImg.frame.size.height - 25, 40, 40)),NSStringFromCGRect(CGRectMake(headImg.frame.origin.x + headImg.frame.size.width - 25, midImg.frame.origin.y + midImg.frame.size.height - 25, 40, 40)),NSStringFromCGRect(CGRectMake(midImg.frame.origin.x + midImg.frame.size.width - 40, midImg.frame.origin.y + midImg.frame.size.height - 80, 40, 40))];
    NSArray *imgs = @[@"share9_big",@"share6_big",@"share7",@"share8",@"share7",@"share8"];
    for (NSInteger i = 0; i < tips.count; i++) {
        //button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectFromString(butRecs[i])];
        if (_directFamily.count > i) {
            FamilNumberModel *tmpModel = _collateralFamily[i];
            NSString *url = tmpModel.face;
            if (![url hasPrefix:@"http"]) {
                url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
            }
            
            [button setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgs[i] ofType:@"png"]]];
        }
        else
        {
            [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgs[i] ofType:@"png"]] forState:UIControlStateNormal];
        }
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = button.frame.size.width / 2;
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.tag = 1 + i;
        [button addTarget:self action:@selector(myHomeIndex:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:button];
        
        //label
        CGFloat xOri = (i < 2) ? (button.frame.origin.x + ((i == 1) ? button.frame.size.width : 0) - 30) : (button.center.x - 30);
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOri, button.frame.origin.y + button.frame.size.height + 2, 60, 20)];
        [tmpLabel setTextAlignment:1];
        [tmpLabel setText:tips[i]];
        [tmpLabel setFont:[UIFont systemFontOfSize:15]];
        [tmpLabel setBackgroundColor:[UIColor clearColor]];
        [backView addSubview:tmpLabel];
    }
    
    //other
    UIView *otherView = [[UIView alloc] initWithFrame:CGRectMake(0, hei, winSize.width, 30)];
    [otherView setBackgroundColor:[UIColor whiteColor]];
    [backView addSubview:otherView];
    
    UILabel *otherLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
    [otherLab setText:@"其他亲友"];
    [otherLab setFont:[UIFont systemFontOfSize:13]];
    [otherView addSubview:otherLab];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bianji" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(winSize.width - 70, 7, 15, 14)];
    [imageView setImage:image];
    [otherView addSubview:imageView];
    
    otherLab = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x + 15 + 5, 5, 40, 20)];
    otherLab.text = _editing ? @"取消" : @"编辑";
    _otherLab = otherLab;
    [otherLab setFont:[UIFont systemFontOfSize:13]];
    [otherLab setBackgroundColor:[UIColor clearColor]];
    otherLab.textColor = [UIColor colorWithRed:97 / 255.0 green:187 / 255.0 blue:248 / 255.0 alpha:1];
    [otherView addSubview:otherLab];
    
    UIButton *editBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBut setBackgroundColor:[UIColor clearColor]];
    editBut.frame = CGRectMake(imageView.frame.origin.x, 5, imageView.frame.size.width + 5 + otherLab.frame.size.width, 20);
    [editBut addTarget:self action:@selector(editUserFriend:) forControlEvents:UIControlEventTouchUpInside];
    [otherView addSubview:editBut];
    
    return backView;
}

- (void)myHomeIndex:(id)sender
{
    _indexPath = nil;
    if (_directFamily.count == 0) {
        [self.view makeToast:@"数据异常，请刷新重试" duration:1.0 position:@"center"];
        return;
    }
    _nIndex = [sender tag] - 1;
    FamilNumberModel *model = _directFamily[_nIndex];
    [self popEditFamilyView:(model.id ? kEditTypeCheck : kEditTypeAdd) Model:model];
}

- (void)touchHeadImg:(UITapGestureRecognizer *)gesture
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.childrens.count <= 1) {
        return;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popSelectedChildrenView];
}

#pragma mark - EditFamilyInfo
- (void)popEditFamilyView:(kEditType)editType Model:(FamilNumberModel *)model
{
    self.view.userInteractionEnabled = NO;
    _editFamilyInfo = nil;
    EditFamilyInfo *familyInfo = [[EditFamilyInfo alloc] initWithFrame:[UIScreen mainScreen].bounds];
    familyInfo.editTyppe = editType;
    familyInfo.delegate = self;
    familyInfo.familyModel = model;
    familyInfo.alpha = 0;
    familyInfo.userInteractionEnabled = NO;
    [self.view.window addSubview:familyInfo];
    
    __weak typeof(familyInfo)weakInfo = familyInfo;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakInfo.alpha = 1.0;
    } completion:^(BOOL finished) {
        weakInfo.userInteractionEnabled = YES;
        weakSelf.view.userInteractionEnabled = YES;
    }];
}

#pragma mark - actions
- (void)editUserFriend:(id)sender
{
    _indexPath = nil;
    _editing = !_editing;
    _otherLab.text = _editing ? @"取消" : @"编辑";
    [_collectionView reloadData];
}

- (void)delUserFriend:(id)sender
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (self.httpOperation) {
        return;
    }
    
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSIndexPath *indexPath = nil;
    if (!sender) {
        indexPath = _indexPath;
    }
    else
    {
        UICollectionViewCell *cell = [DJTGlobalManager viewController:sender Class:[UICollectionViewCell class]];
        indexPath = [_collectionView indexPathForCell:cell];
    }
    
    FamilNumberModel *model = _collateralFamily[indexPath.item - 1];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteMember"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:model.id forKey:@"id"];
    //[param setObject:model.name forKey:@"name"];
    NSString *text=[NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    _collectionView.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(indexPath)weakPath = indexPath;
    
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"family"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf delFamilyNumerFinish:success Data:data Path:weakPath];
    } failedBlock:^(NSString *description) {
        [weakSelf delFamilyNumerFinish:NO Data:nil Path:weakPath];
    }];
}

#pragma mark - 删除家庭成员
- (void)delFamilyNumerFinish:(BOOL)success Data:(id)data Path:(NSIndexPath *)indexPath
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    _collectionView.userInteractionEnabled = YES;
    if (!success) {
        NSString *ret_msg = [data valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
    else
    {
        [_collateralFamily removeObjectAtIndex:indexPath.item - 1];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark - 查询家庭成员
- (void)getFamilyInfo{
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        [_hView performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.1];
        return;
    }
    _collectionView.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAllMember"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"family"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf selectFamilyNumerFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf selectFamilyNumerFinish:NO Data:nil];
    }];
}

- (void)selectFamilyNumerFinish:(BOOL)success Data:(id)data
{
    [_hView endRefreshing];
    self.httpOperation = nil;
    _collectionView.userInteractionEnabled = YES;
    if (!success) {
        NSString *ret_msg = [data valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
    else{
        [_directFamily removeAllObjects];
        [_collateralFamily removeAllObjects];
        id ret_data = [data objectForKey:@"ret_data"];
        for (NSInteger i = 0; i < [ret_data count];i++) {
            id subDic = ret_data[i];
            FamilNumberModel *model = [[FamilNumberModel alloc] init];
            [model reflectDataFromOtherObject:subDic];
            if (i < 6) {
                [_directFamily addObject:model];
            }
            else
            {
                [_collateralFamily addObject:model];
            }
        }
        
        [_collectionView reloadData];
    }
}

#pragma mark - 增加家庭成员
- (void)addFamilyNumerFinish:(BOOL)success Data:(id)data Family:(EditFamilyInfo *)familyInfo
{
    self.httpOperation = nil;
    [self.view.window hideToastActivity];
    _collectionView.userInteractionEnabled = YES;
    familyInfo.userInteractionEnabled = YES;
    if (!success) {
        familyInfo.userInteractionEnabled = YES;
        NSString *ret_msg = [data valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view.window makeToast:ret_msg duration:1.0 position:@"center"];
    }
    else{
        /*
        __weak typeof(familyInfo)weakInfo = familyInfo;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            [weakInfo setAlpha:0];
        } completion:^(BOOL finished) {
            [weakSelf editFamilyInfoSucces:weakInfo Data:data];
        }];
         */
        [self editFamilyInfoSucces:familyInfo Data:data];
    }
}

- (void)editFamilyInfoSucces:(EditFamilyInfo *)editFamily Data:(id)data
{
    NSString *str = nil;
    switch (editFamily.editTyppe) {
        case kEditTypeCheck:
        {
            FamilNumberModel *model = _directFamily[_nIndex];
            if ((editFamily.commitType == kCommitTypePhone) || (editFamily.commitType == kCommitTypeAll)) {
                model.mobile = editFamily.phoneField.text;
                [editFamily cancelPhoneEdit];
            }
            
            if ((editFamily.commitType == kCommitTypeImage) || (editFamily.commitType == kCommitTypeAll)) {
                model.face = editFamily.faceNew;
            }
            str = @"亲友信息修改成功";
        }
            break;
        case kEditTypeCheck2:
        {
            FamilNumberModel *model = _collateralFamily[_indexPath.item - 1];
            if ((editFamily.commitType == kCommitTypePhone) || (editFamily.commitType == kCommitTypeAll)) {
                model.mobile = editFamily.phoneField.text;
                model.name = editFamily.nameField.text;
                [editFamily cancelPhoneEdit];
            }
            if ((editFamily.commitType == kCommitTypeName) || (editFamily.commitType == kCommitTypeAll)) {
                model.name = editFamily.nameField.text;
            }
            if (editFamily.commitType == kCommitTypeImage || editFamily.commitType == kCommitTypeAll) {
                model.face = editFamily.faceNew;
            }

            [_collectionView reloadItemsAtIndexPaths:@[_indexPath]];
            str = @"亲友信息修改成功";
        }
            break;
        case kEditTypeAdd:
        {
            id ret_data = [data objectForKey:@"ret_data"];
            if (ret_data && ![ret_data isKindOfClass:[NSNull class]]) {
                if (_indexPath) {
                    FamilNumberModel *model = [[FamilNumberModel alloc] init];
                    model.id = ret_data;
                    model.mobile = editFamily.phoneField.text;
                    model.name = editFamily.nameField.text;
                    if (editFamily.faceNew) {
                        model.face = editFamily.faceNew;
                    }
                    [_collateralFamily addObject:model];
                    NSInteger count = _collateralFamily.count;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count inSection:0];
                    [_collectionView insertItemsAtIndexPaths:@[indexPath]];
                    //[self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
                    _indexPath = indexPath;
                    editFamily.editTyppe = kEditTypeCheck2;
                    editFamily.familyModel = model;
                }
                else
                {
                    FamilNumberModel *model = _directFamily[_nIndex];
                    model.id = ret_data;
                    model.mobile = editFamily.phoneField.text;
                    if (editFamily.faceNew) {
                        model.face = editFamily.faceNew;
                    }
                    editFamily.editTyppe = kEditTypeCheck;
                    //[self popEditFamilyView:(model.id ? kEditTypeCheck : kEditTypeAdd) Model:model];
                }
                
            }
            str = @"亲友信息添加成功";
            [editFamily cancelPhoneEdit];
            [editFamily cancelNameEdit];
        }
            break;
        default:
            break;
    }
    
    [self.view.window makeToast:str duration:1.0 position:@"center"];
}

#pragma mark - EditFamilyInfoDelegate
- (void)checkAddressBook:(EditFamilyInfo *)editFamily
{
    _editFamilyInfo = editFamily;
    [_editFamilyInfo removeFromSuperview];
    PersonInfoViewController *personViewContoller = [[PersonInfoViewController alloc]init];
    personViewContoller.delegate = self;
    [self.navigationController pushViewController:personViewContoller animated:YES];
}

- (void)editFamilyInfo:(EditFamilyInfo *)editFamily Name:(NSString *)name Phone:(NSString *)phone
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (self.httpOperation) {
        return;
    }
    
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    editFamily.userInteractionEnabled = NO;
    _collectionView.userInteractionEnabled = NO;
    [self.view.window makeToastActivity];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"addMember"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    if (_indexPath && _indexPath.item == 0) {
        
    }
    else
    {
        FamilNumberModel *model = nil;
        if (_indexPath) {
            model = _collateralFamily[_indexPath.item - 1];
        }
        else
        {
            model = _directFamily[_nIndex];
        }
        if (model.id) {
            [param setObject:model.id forKey:@"id"];
        }
    }
    
    if (editFamily.commitType == kCommitTypeImage || editFamily.commitType == kCommitTypeAll) {
        [param setObject:editFamily.faceNew forKey:@"face"];
    }
    
    [param setObject:name forKey:@"name"];
    [param setObject:phone forKey:@"mobile"];
    
    NSString *type = (editFamily.editTyppe == kEditTypeAdd) ? @"0" : @"1";
    [param setObject:type forKey:@"type"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
 
    __weak typeof(self)weakSelf = self;
    __weak typeof(editFamily)weakInfo = editFamily;
    self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"family"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf addFamilyNumerFinish:success Data:data Family:weakInfo];
    } failedBlock:^(NSString *description) {
        [weakSelf addFamilyNumerFinish:NO Data:nil Family:weakInfo];
    }];
}

- (void)selectFamilyDynamic:(EditFamilyInfo *)editFamily
{
    _editFamilyInfo = editFamily;
    [_editFamilyInfo removeFromSuperview];
    DJTWebViewController *web = [[DJTWebViewController alloc]init];
    web.baby_id = editFamily.familyModel.baby_id;
    web.phone = editFamily.familyModel.mobile;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)changeFace:(EditFamilyInfo *)editFamily
{
    _editFamilyInfo = editFamily;
    [_editFamilyInfo removeFromSuperview];
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 1;
    
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)cancelEditInfo:(EditFamilyInfo *)editFamily
{
    _editFamilyInfo = nil;
}

#pragma mark - SetPersonPhoneNumberDelegate
- (void)setPersonPhoneNumber:(NSString *)phoneString Name:(NSString *)name{
    [self performSelector:@selector(addFaimilyInfoAfterOneSecond:) withObject:@{@"name":name,@"phone":phoneString} afterDelay:0.1];
}

- (void)addFaimilyInfoAfterOneSecond:(NSDictionary *)dic
{
    if (dic) {
        _editFamilyInfo.phoneField.text = [dic valueForKey:@"phone"];
        if ((_editFamilyInfo.editTyppe == kEditTypeCheck) || ((_editFamilyInfo.editTyppe == kEditTypeAdd) && (_editFamilyInfo.familyModel && !_editFamilyInfo.familyModel.id))) {
            
        }
        else
        {
            _editFamilyInfo.nameField.text = [dic valueForKey:@"name"];
        }
    }
    [self.view.window addSubview:_editFamilyInfo];
    _editFamilyInfo.userInteractionEnabled = YES;
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    UIImage *image = nil;
    if (assets.count > 0) {
        ALAsset *asset = [assets firstObject];
        image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    }
    [self performSelector:@selector(uploadImage:) withObject:image afterDelay:0.1];
}

- (void)uploadImage:(UIImage *)img
{
    //[self.view.window addSubview:_editFamilyInfo];
    if (img) {
        [_editFamilyInfo.headBut setImage:img forState:UIControlStateNormal];
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        if (self.httpOperation) {
            return;
        }
        
        if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
            
            [_editFamilyInfo makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
            return;
        }
        
        NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]]]];
        NSData *data = UIImageJPEGRepresentation(img, 0.8);
        [data writeToFile:filePath atomically:NO];
        [self changeHead:filePath];
    }
}

#pragma mark - 图片上传
- (void)changeHead:(NSString *)filePath
{
    [_editFamilyInfo makeToastActivity];
    _editFamilyInfo.userInteractionEnabled = NO;
    _collectionView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    //图片上传队列
    NSDictionary *dicOne = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1",@"img": @[@"160,160"]};    //1－图片
    NSData *json = [NSJSONSerialization dataWithJSONObject:dicOne options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPathImg = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:urlPathImg parameters:nil filePath:filePath ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [weakSelf changeHeadFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [weakSelf changeHeadFinish:nil Suc:NO];
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
    }];
}

- (void)changeHeadFinish:(id)result Suc:(BOOL)success
{
    self.httpOperation = nil;
    [_editFamilyInfo hideToastActivity];
    _collectionView.userInteractionEnabled = YES;
    _editFamilyInfo.userInteractionEnabled = YES;
    if (success) {
        NSString *face = nil;
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result firstObject];
        }
        NSString *original = [result valueForKey:@"original"];
        
        if (original && [original length] > 0) {
            NSString *extension = [original pathExtension];
            NSString *thumbnail = [NSString stringWithFormat:@"%@_160_160.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
            face = thumbnail;
            _editFamilyInfo.faceNew = face;
            
            _editFamilyInfo.commitType = kCommitTypeImage;
            if (_editFamilyInfo.editTyppe != kEditTypeAdd) {
                //单独提交图片
                [self editFamilyInfo:_editFamilyInfo Name:_editFamilyInfo.familyModel.name Phone:_editFamilyInfo.familyModel.mobile];
            }
        }
        else
        {
            [_editFamilyInfo makeToast:@"头像修改失败" duration:1.0 position:@"center"];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        if ([result valueForKey:@"message"]) {
            str = [result valueForKey:@"message"];
        }
        [_editFamilyInfo makeToast:str duration:1.0 position:@"center"];
    }
}

@end
