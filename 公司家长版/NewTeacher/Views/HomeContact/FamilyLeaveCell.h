//
//  FamilyLeaveCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamilyDetailModel.h"

@protocol FamilyLeaveCellDelegate<NSObject>

@optional
- (void)replyOrDelMessage:(ReplysItem *)model;

@end

@interface FamilyLeaveCell : UITableViewCell

@property (nonatomic, assign) id<FamilyLeaveCellDelegate> delegate;

- (void)resetFamilyLeaveData:(id)object;

@end
