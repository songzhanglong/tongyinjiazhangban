//
//  SortStudentView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SortStudentView;
@protocol SortStudentViewDelegate <NSObject>

- (void)selectSortType:(SortStudentView *)sortView;

@end

@interface SortStudentView : UIView

@property (nonatomic,assign)NSInteger nSortIndex;
@property (nonatomic,assign)id<SortStudentViewDelegate> delegate;

@end
