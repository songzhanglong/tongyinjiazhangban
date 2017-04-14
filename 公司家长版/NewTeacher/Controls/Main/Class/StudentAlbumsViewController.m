//
//  StudentAlbumsViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentAlbumsViewController.h"
#import "DJTUser.h"
#import "NSString+Common.h"

@interface StudentAlbumsViewController ()

@end

@implementation StudentAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 参数配置
- (void)resetRequestParam
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getPhotoList2"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageCount] forKey:@"pageSize"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_pageIdx] forKey:@"page"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.param = param;
}

@end
