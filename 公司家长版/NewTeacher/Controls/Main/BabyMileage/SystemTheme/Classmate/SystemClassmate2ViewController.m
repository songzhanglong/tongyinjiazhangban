//
//  SystemClassmate2ViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SystemClassmate2ViewController.h"
#import "MileageModel.h"
#import "NSString+Common.h"

@interface SystemClassmate2ViewController ()

@end

@implementation SystemClassmate2ViewController

- (void)changeTypeByParent
{
    //很重要，不可删除
}

- (void)startRequestData
{
    [self createTableViewAndRequestAction:nil Param:nil Header:YES Foot:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [self startPullRefresh];
}

#pragma mark - 重载
- (void)createTableHeaderView{
    if (!_tableView.tableHeaderView) {
        BOOL hasContent = ([self.dataSource count] > 0);
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 30 + 100 + 30 + 18 + 10 + 18 + 30 + (hasContent ? 40 : 0))];
        [footView setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 30, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:@"无照片或小视频"];
        [footView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(label.frameX, label.frameBottom + 10, label.frameWidth, label.frameHeight)];
        [label2 setTextAlignment:1];
        [label2 setTextColor:label.textColor];
        [label2 setFont:label.font];
        [label2 setText:@"去看看其他主题吧"];
        [footView addSubview:label2];
        
        if (hasContent) {
            UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, label2.frameBottom + 30, footView.frameWidth, 40)];
            [downView setBackgroundColor:rgba(231, 231, 231, 1)];
            [footView addSubview:downView];
            
            CGFloat moreWei = 100;
            UILabel *moreLab = [[UILabel alloc] initWithFrame:CGRectMake((downView.frameWidth - moreWei) / 2, 10, moreWei, 20)];
            [moreLab setFont:[UIFont systemFontOfSize:14]];
            moreLab.layer.masksToBounds = YES;
            moreLab.layer.cornerRadius = 10;
            moreLab.textAlignment = NSTextAlignmentCenter;
            moreLab.textColor = label.textColor;
            [moreLab setBackgroundColor:rgba(205, 205, 205, 1)];
            moreLab.text = @"更多精彩内容";
            [downView addSubview:moreLab];
        }
        
        [_tableView setTableHeaderView:footView];
    }
}

- (void)createTableFooterView{
    
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getClassmatePhotoList"];
    [param setObject:self.mileage.mileage_type.stringValue forKey:@"mileage_type"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
    self.action = @"photo";
}

@end
