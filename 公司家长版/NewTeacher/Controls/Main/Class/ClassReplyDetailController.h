//
//  ClassReplyDetailController.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@class ClassCircleModel;

@protocol ClassReplyDetailDelegate <NSObject>

@optional
- (void)changeReplyDetail;
- (void)deleteThisCircleDetail;

@end

@interface ClassReplyDetailController : DJTTableViewController

@property (nonatomic,strong)ClassCircleModel *circleModel;
@property (nonatomic,strong)NSString *circleId;
@property (nonatomic,assign)id<ClassReplyDetailDelegate> delegate;
@property (nonatomic,strong)MPMoviePlayerController *movieController;

@end
