//
//  DynamicDetailCell.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/19.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DynamicDetailCellDelegate <NSObject>

@optional
- (void)beginDelete:(UITableViewCell *)cell;

@end

@interface DynamicDetailCell : UITableViewCell

@property (nonatomic,assign)id<DynamicDetailCellDelegate> delegate;

- (void)resetDynamicDetailData:(id)object;

@end
