//
//  ChangeRelView.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChangeRelView;
@protocol ChangeRelativeViewDelegate <NSObject>

@required
- (void)readiPhoneNumFromPhone:(ChangeRelView *)realtiveView;
- (void)makeSureRelativeInfo:(ChangeRelView *)relativeView;
@end

@interface ChangeRelView : UIView
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,assign) id <ChangeRelativeViewDelegate> changeRelDelegate;
@property (nonatomic,strong) UIImageView *relativeHeaderView;//头像
@property (nonatomic,strong) UILabel *relNameLab;//姓名
@property (nonatomic,strong) UIButton *updateBut;//班级动态
@property (nonatomic,strong) UIButton *phoneView;//电话
@property (nonatomic,strong) UITextField *phoneNumberLab;//
@property (nonatomic,strong) UIButton *RightBut;//确认按钮
@property (nonatomic,strong) UIImageView *deleteBut;//删除按钮
@end
