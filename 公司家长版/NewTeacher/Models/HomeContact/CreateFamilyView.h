//
//  CreateFamilyView.h
//  NewTeacher
//
//  Created by zhangxs on 16/5/12.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamilyListModel.h"
#import "FamilyStudentModel.h"

@protocol CreateFamilyViewDelegate <NSObject>

@optional
- (void)createToFamilys:(FamilyListModel *)item;

@end

@interface CreateFamilyView : UIView
@property (nonatomic,assign)id<CreateFamilyViewDelegate> delegate;

- (void)createTableView:(FamilyStudentModel *)model;
@end
