//
//  NotificationCommentCell.h
//  NewTeacher
//
//  Created by songzhanglong on 15/2/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationCommentCellDelegate <NSObject>

@optional
- (void)expandAndDrawback:(UITableViewCell *)cell;

@end

@interface NotificationCommentCell : UITableViewCell

@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,assign)id<NotificationCommentCellDelegate> delegate;

- (void)resetNotificationDetailData:(id)object;

@end
