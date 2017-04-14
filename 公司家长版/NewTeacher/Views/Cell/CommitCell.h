//
//  CommitCell.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommitCell;
@protocol CommitCellDelegate <NSObject>

-(void)betterBtnClick:(CommitCell *)cell;
-(void)bestBtnClick:(CommitCell *)cell;

@end

@interface CommitCell : UITableViewCell
@property (nonatomic,retain) id<CommitCellDelegate >delegate;
@property (nonatomic,retain) UILabel    *contantLabel;
@property (nonatomic,retain) UIButton   *bestBtn;
@property (nonatomic,retain) UIButton   *betterBtn;
@end
