//
//  ThemeBatchViewCell.h
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThemeBatchViewCellDelegate <NSObject>

@optional
- (void)selectThemeBatchCell:(UITableViewCell *)cell At:(NSInteger)index;
- (void)selectThemeBatchCell:(UITableViewCell *)cell Dig:(NSInteger)index;

@end

@interface ThemeBatchViewCell : UITableViewCell

@property (nonatomic,assign)id<ThemeBatchViewCellDelegate> delegate;

- (void)resetDataSource:(id)object;

@end
