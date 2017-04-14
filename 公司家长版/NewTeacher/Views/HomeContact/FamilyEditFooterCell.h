//
//  FamilyEditFooterCell.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/17.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FamilyEditFooterCellDelegate<NSObject>

@optional
- (void)selectOptions:(UITableViewCell *)cell Option_title:(NSString *)title;
@end

@interface FamilyEditFooterCell : UITableViewCell
@property (nonatomic, assign) id<FamilyEditFooterCellDelegate> delegate;
@property (nonatomic, assign) BOOL isEdit;

- (void)resetFamilyEditFooterData:(id)object Options:(NSArray *)option;;

@end
