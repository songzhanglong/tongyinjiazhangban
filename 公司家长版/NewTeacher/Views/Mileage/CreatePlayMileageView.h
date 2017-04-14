//
//  CreatePlayMileageView.h
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreatePlayMileageView;
@protocol CreatePlayMileageViewDelegate <NSObject>

@optional
- (void)selectCreateIndex:(NSInteger)type;
- (void)cancelToView:(CreatePlayMileageView *)view;
@end
@interface CreatePlayMileageView : UIView

@property (nonatomic,assign)id<CreatePlayMileageViewDelegate> delegate;

@end
