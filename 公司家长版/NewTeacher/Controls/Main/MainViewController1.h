//
//  MainViewController1.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/16.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@class ClassCircleModel;

@interface MainViewController1 : DJTTableViewController

@property (nonatomic,strong)MPMoviePlayerController *movieController;
@property (nonatomic,strong)ClassCircleModel *activityModel;

@end
