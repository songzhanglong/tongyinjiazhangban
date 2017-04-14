//
//  PlayVideoViewController.h
//  NewTeacher
//
//  Created by szl on 16/4/19.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import "PlayerApi.h"

@interface PlayVideoViewController : DJTBaseViewController

@property (nonatomic) int iNodeIndex;
@property (nonatomic) int iViindex;
@property (nonatomic) NSInteger selectIdx;
@property (nonatomic,strong)NSArray *nameList;

@end
