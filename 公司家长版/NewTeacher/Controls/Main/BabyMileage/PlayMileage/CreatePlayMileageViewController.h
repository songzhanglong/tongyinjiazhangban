//
//  CreatePlayMileageViewController.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CreatePlayMileageViewController : DJTBaseViewController

@property (nonatomic, assign) NSInteger createType;
@property (nonatomic, strong) NSMutableArray *selectDataArray;
@property (nonatomic, strong) NSString *album_id;
@property (nonatomic, strong) NSString *theme_id;
@property (nonatomic, strong) NSString *editTitle;
@property (nonatomic, strong) MPMoviePlayerController *movieController;

@end
