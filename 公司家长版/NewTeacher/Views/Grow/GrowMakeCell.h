//
//  GrowMakeCell.h
//  NewTeacher
//
//  Created by szl on 16/1/29.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GrowMakeCellDelegate <NSObject>

@optional
- (void)selectGrowCell:(UITableViewCell *)cell At:(NSInteger)index;
- (void)editGrowCell:(UITableViewCell *)cell At:(NSInteger)index;

@end

@interface GrowMakeCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,assign)id<GrowMakeCellDelegate> delegate;

- (void)resetDataSource:(id)object;

- (void)reloadIndexPath:(NSInteger)index;

@end
