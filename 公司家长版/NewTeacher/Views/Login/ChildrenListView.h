//
//  ChildrenListView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/5/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
@protocol ChildrenListViewDelegate <NSObject>

@optional
- (void)selectIndexPath:(NSIndexPath *)indexPath;

@end
 */

@interface ChildrenListView : UIView<UITableViewDataSource,UITableViewDelegate>

//@property(nonatomic,assign)id<ChildrenListViewDelegate> delegate;

@end
