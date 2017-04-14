//
//  ChildrenListView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/5/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ChildrenListView.h"
#import "DJTGlobalManager.h"
#import "AppDelegate.h"

@implementation ChildrenListView
{
    NSInteger nSelecetedIdx;
    UITableView *_tableView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader:) name:CHANGE_USER_HEADER object:nil];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 44.0) style:UITableViewStylePlain];
        _tableView = tableView;
        //[tableView setBackgroundColor:[UIColor clearColor]];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
        [tableView setTableFooterView:footView];
        [self addSubview:tableView];
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100)];
        [headView setBackgroundColor:[UIColor clearColor]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, frame.size.width, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:1];
        [label setText:@"选择一个宝宝"];
        [headView addSubview:label];
        [tableView setTableHeaderView:headView];
        
        //delete
        UIView *delView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 44)];
        [delView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:delView];
        
        UIButton *deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBut setImage:[UIImage imageNamed:@"closed1.png"] forState:UIControlStateNormal];
        [deleteBut setFrame:CGRectMake((frame.size.width - 25) / 2, (44 - 25) / 2, 25, 25)];
        [deleteBut setBackgroundColor:[UIColor clearColor]];
        [deleteBut addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
        [delView addSubview:deleteBut];
        
        tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"childBG" ofType:@"png"]]];
        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        if (manager.userInfo) {
            nSelecetedIdx = [manager.childrens indexOfObject:manager.userInfo];
        }
        else
        {
            nSelecetedIdx = 0;
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_USER_HEADER object:nil];
}

- (void)refreshHeader:(NSNotification *)notifi
{
    [_tableView reloadData];
}

- (void)deleteSelf:(id)sender
{
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    if (user) {
        //非登录
        self.userInteractionEnabled = NO;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
        }];
    }
    else
    {
        //默认选择第一个
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app selectLoginChildIdx:0];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DJTGlobalManager shareInstance].childrens.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierCell];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(44, 2, self.frame.size.width - 44 + 15, 80)];
        [backView setTag:1];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 15.0;
        [cell.contentView addSubview:backView];
        
        //selected img
        UIImageView *selectedImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 44 - 10 - 28, 26, 28, 28)];
        [selectedImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"childSelected" ofType:@"png"]]];
        [backView addSubview:selectedImg];
        
        //image
        UIView *headBack = [[UIView alloc] initWithFrame:CGRectMake(12.5, 12.5, 55, 55)];
        headBack.layer.masksToBounds = YES;
        headBack.layer.cornerRadius = 27.5;
        headBack.layer.borderColor = [UIColor redColor].CGColor;
        [headBack setTag:2];
        [headBack setBackgroundColor:[UIColor whiteColor]];
        [backView addSubview:headBack];
        
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = 25;
        [headImg setTag:3];
        [headImg setBackgroundColor:[UIColor whiteColor]];
        [backView addSubview:headImg];
        
        //name
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(headBack.frame.origin.x + headBack.frame.size.width + 15, 20, backView.frame.size.width - 70 - 70, 40)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTag:4];
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:16];
        [backView addSubview:label];
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    DJTUser *user = manager.childrens[indexPath.row];
    BOOL selected = (indexPath.row == nSelecetedIdx);
    
    UIView *backView = [cell.contentView viewWithTag:1];
    CGRect backRec = backView.frame;
    [backView setFrame:CGRectMake(selected ? 44 : 110, backRec.origin.y, backRec.size.width, backRec.size.height)];
    [backView setBackgroundColor:selected ? [UIColor redColor] : [UIColor colorWithRed:246.0 / 255 green:241.0 / 255 blue:238.0 / 255 alpha:1.0]];
    UIView *headBack = [backView viewWithTag:2];
    headBack.layer.borderWidth = selected ? 0 : 1;
    UIImageView *headImg = (UIImageView *)[backView viewWithTag:3];
    UILabel *label = (UILabel *)[backView viewWithTag:4];
    [label setFrame:CGRectMake(headBack.frame.origin.x + headBack.frame.size.width + 15, 20, backView.frame.size.width - 70 - 70 - (selected ? 0 : 30), 40)];
    [headImg setImageWithURL:[NSURL URLWithString:user.face ?: @""] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    [label setText:user.uname];
    [label setTextColor:selected ? [UIColor whiteColor] : [UIColor blackColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != nSelecetedIdx) {
        NSInteger preIdx = nSelecetedIdx;
        nSelecetedIdx = indexPath.row;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:preIdx inSection:indexPath.section],indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    self.userInteractionEnabled = NO;
    NSArray *children = [DJTGlobalManager shareInstance].childrens;
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    BOOL changeNone = (user && ([children indexOfObject:user] == indexPath.row));
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    __weak typeof(app)weakApp = app;
    __weak typeof(self)weakSelf = self;
    NSInteger index = indexPath.row;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = changeNone ? 0 : 1;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        if (!changeNone) {
            [weakApp selectLoginChildIdx:index];
        }
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
