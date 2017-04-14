//
//  ChannelListViewController.h
//  NewTeacher
//
//  Created by szl on 16/4/19.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#include "PlayerApi.h"
#import "ChannelModel.h"

@interface ChannelListViewController : DJTTableViewController

@property (nonatomic,strong)NSArray *deviceList;
@property (nonatomic,strong)NSArray *powerList;

@end
