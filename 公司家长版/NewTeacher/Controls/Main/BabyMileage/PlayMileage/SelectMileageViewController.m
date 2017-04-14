//
//  SelectMileageViewController.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectMileageViewController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "GrowAlbumItem.h"
#import "SelectMileageTableViewCell.h"
#import "SelectPhotosMileageViewController.h"

@implementation SelectMileageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showBack = YES;
    self.titleLable.text = @"选择里程主题";
    self.view.backgroundColor = CreateColor(221, 221, 221);
    
    self.useNewInterface = YES;
    [self createTableViewAndRequestAction:@"mileage" Param:nil Header:YES Foot:NO];
    [_tableView setBackgroundColor:CreateColor(221, 221, 221)];
    [self beginRefresh];
}

- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 170)];
        [headView setBackgroundColor:_tableView.backgroundColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [headView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imgView.frame.origin.y + imgView.frame.size.height + 10, winSize.width - 10, 30)];
        [label setText:@"暂时还没有创建里程主题哦!"];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setBackgroundColor:_tableView.backgroundColor];
        [label setTextAlignment:1];
        [headView addSubview:label];
        
        [_tableView setTableFooterView:headView];
    }
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getAlbumByUser"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data && [ret_data isKindOfClass:[NSArray class]]) {
            NSArray *array = [GrowAlbumItem arrayOfModelsFromDictionaries:ret_data error:nil];
            self.dataSource = array;
        }
    }
    else{
        self.dataSource = nil;
    }
    [self createTableFooterView];
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self beginRefresh];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mileageCell = @"SelectMileageCellId";
    SelectMileageTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:mileageCell];
    if (cell == nil) {
        cell = [[SelectMileageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mileageCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    GrowAlbumItem *item = self.dataSource[indexPath.section];
    [cell resetDataSource:item];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GrowAlbumItem *item = self.dataSource[indexPath.section];
    SelectPhotosMileageViewController *selectPhotos = [[SelectPhotosMileageViewController alloc] init];
    if ([item.album_id integerValue] == [_album_id integerValue]) {
        selectPhotos.editType = _editType;
        selectPhotos.theme_id = _theme_id;
        selectPhotos.editTitle = _editTitle;
        selectPhotos.otherArr = _otherArr;
    }else{
         selectPhotos.editTitle = item.name;
    }
    selectPhotos.album_id = item.album_id;
   
    [self.navigationController pushViewController:selectPhotos animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}
@end
