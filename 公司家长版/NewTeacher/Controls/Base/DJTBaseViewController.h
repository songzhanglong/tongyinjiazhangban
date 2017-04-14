//
//  DJTBaseViewController.h
//  MZJD
//
//  Created by mac on 14-4-14.
//  Copyright (c) 2014年 DIGIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJTHttpClient.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"
#import "SDWebImageManager.h"

@interface DJTBaseViewController : UIViewController

@property (nonatomic,assign)BOOL showBack;  //初始化时指明
@property (nonatomic,assign)BOOL showNewBack;   //点击区域控制
@property (nonatomic,assign)BOOL showClearRightBut; //空按钮，保证标题居中
@property (nonatomic,retain)UILabel *titleLable;    //标题拦
@property (nonatomic,retain)AFHTTPRequestOperation *httpOperation;


@end
