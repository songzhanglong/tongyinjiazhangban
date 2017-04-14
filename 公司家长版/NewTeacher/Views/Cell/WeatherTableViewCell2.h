//
//  WeatherTableViewCell2.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherModel.h"

@interface WeatherTableViewCell2 : UITableViewCell

- (void)resetDataSource:(WeatherModel *)model;

@end
