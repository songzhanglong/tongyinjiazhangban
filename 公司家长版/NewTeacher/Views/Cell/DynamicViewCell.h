//
//  DynamicViewCell.h
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DynamicViewCellDelegate <NSObject>

@optional
- (void)diggAndCommentCell:(UITableViewCell *)cell At:(NSInteger)idx;
- (void)touchImageCell:(UITableViewCell *)cell At:(NSInteger)idx;
- (void)selectListByPeople:(UITableViewCell *)cell;

@end

@interface DynamicViewCell : UITableViewCell

@property (nonatomic,assign)id<DynamicViewCellDelegate> delegate;

- (void)resetClassGroupData:(id)object;

@end
