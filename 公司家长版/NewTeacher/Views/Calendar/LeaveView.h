//
//  LeaveView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/8/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeaveViewDelegate <NSObject>

@optional
- (void)askForLeave:(NSString *)startTime End:(NSString *)endTime Type:(NSString *)type Content:(NSString *)content;

@end

@interface LeaveView : UIView<UITextViewDelegate>

@property (nonatomic,assign)id<LeaveViewDelegate> delegate;

- (void)showInView:(UIView *)father;

@end
