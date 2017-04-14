//
//  PlayViewController.h
//  NewTeacher
//
//  Created by szl on 16/3/31.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

typedef void(^PlayResult)(NSString *filePath);

@interface PlayViewController : DJTBaseViewController

@property (nonatomic,strong)NSURL *fileUrl;
@property (nonatomic,strong)NSString *myPath;
@property (nonatomic,copy)PlayResult playResult;

@end
