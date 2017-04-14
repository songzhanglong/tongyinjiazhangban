//
//  TimeCardViewCell.h
//  NewTeacher
//
//  Created by songzhanglong on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeCardViewCellDelegate <NSObject>

@optional
- (void)cancelBindAndChangeInfo:(UITableViewCell *)cell Tag:(NSInteger)index;   //0-解绑，1-修改信息

@end

@interface TimeCardViewCell : UITableViewCell

@property (nonatomic,assign)id<TimeCardViewCellDelegate> delegate;

- (void)resetTimeCard:(id)dataSource;

@end
