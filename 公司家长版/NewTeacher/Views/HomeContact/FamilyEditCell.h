//
//  FamilyEditCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FamilyEditCellDelegate<NSObject>

@optional
- (void)selectOptions:(UITableViewCell *)cell Option_title:(NSString *)title;
@end

@interface FamilyEditCell : UITableViewCell

@property (nonatomic, assign) id<FamilyEditCellDelegate> delegate;
@property (nonatomic, assign) BOOL isEdit;

- (void)resetFamilyEditData:(id)object Options:(NSArray *)option;

@end
