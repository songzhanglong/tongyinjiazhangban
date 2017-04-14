//
//  PlayMileageTableViewCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayMileageTableViewCell;
@protocol PlayMileageTableViewCellDelegate <NSObject>

@optional
- (void)sharePlayMileage:(PlayMileageTableViewCell *)cell ShareImage:(UIImage *)image;
- (void)editPlayMileage:(PlayMileageTableViewCell *)cell;
- (void)deletePlayMileage:(PlayMileageTableViewCell *)cell;
- (void)changePlayMileage:(PlayMileageTableViewCell *)cell;

@end

@interface PlayMileageTableViewCell : UITableViewCell
@property (nonatomic,assign)id<PlayMileageTableViewCellDelegate> delegate;

- (void)resetDataSource:(id)object;

@end
