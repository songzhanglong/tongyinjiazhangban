//
//  RelativeView.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/7.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamilNumberModel.h"

@class RelativeView;
@protocol RelativeViewDelegate <NSObject>

@required
- (void)callPhone:(RelativeView *)relativeView;
- (void)babyActivity:(RelativeView *)relativeView;
- (void)changePhoneNumber:(RelativeView *)relativeView;
- (void)readPhoneNumFromPhone:(RelativeView *)realtiveView;
@end



@interface RelativeView : UIView
@property (nonatomic,strong) FamilNumberModel *model;
@property (nonatomic,assign) id <RelativeViewDelegate> relDelegate;
@property (nonatomic,strong) UIImageView *relativeHeaderView;
@property (nonatomic,strong) UILabel *relativeNameLab;
@property (nonatomic,strong) UIButton *updateBut;
@property (nonatomic,strong) UIButton *phoneView;
@property (nonatomic,strong) UILabel *phoneNumberLab;
@property (nonatomic,strong) UIButton *changePhoneBut;
@property (nonatomic,strong) UIImageView *deleteBut;
@property (nonatomic,strong) UIButton *callPoneBut;
@end
