//
//  GrowNewCell.h
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GrowNewCellDelegate <NSObject>

@optional
- (void)startToPrint:(UITableViewCell *)cell;

@end

@interface GrowNewCell : UITableViewCell
{
    UIView *_backView;
}

@property (nonatomic,assign)id<GrowNewCellDelegate> delegate;

- (void)resetDataSource:(id)dataSource;

@end
