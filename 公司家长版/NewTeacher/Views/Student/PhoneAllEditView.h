//
//  PhoneAllEditView.h
//  NewTeacher
//
//  Created by 张雪松 on 15/10/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhoneAllEditViewDelegate <NSObject>

@optional
- (void)selectEditIndex:(NSString *)phone;

@end

@interface PhoneAllEditView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,assign)id<PhoneAllEditViewDelegate> delegate;

- (void)showInView:(UIView *)view;

//- (void)editStudentPhoto:(id)sender;

@end
