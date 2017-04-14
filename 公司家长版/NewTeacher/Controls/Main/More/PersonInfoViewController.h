//
//  PersonInfoViewController.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTBaseViewController.h"

@protocol SetPersonPhoneNumberDelegate <NSObject>

@optional
- (void)setPersonPhoneNumber:(NSString *)phoneString Name:(NSString *)name;

@end


@interface PersonInfoViewController : DJTBaseViewController
@property (nonatomic,assign) id<SetPersonPhoneNumberDelegate> delegate;
@end
