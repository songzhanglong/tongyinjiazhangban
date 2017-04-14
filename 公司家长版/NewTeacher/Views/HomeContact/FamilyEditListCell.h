//
//  FamilyEditListCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FamilyEditListCellDelegate <NSObject>

@optional

- (void)deleteSection:(UITableViewCell *)cell;
- (void)playRecording:(UITableViewCell *)cell AtBtn:(id)sender;

@end

@interface FamilyEditListCell : UITableViewCell
@property (nonatomic,assign)id<FamilyEditListCellDelegate> delegate;

- (void)resetFamilyEditListData:(id)object;
@end
