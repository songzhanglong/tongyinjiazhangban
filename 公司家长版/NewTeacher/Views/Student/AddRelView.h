//
//  AddRelView.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddRelView;
@protocol AddRelViewDelegate <NSObject>

@required
- (void)modFamNumber:(AddRelView *)relativeView;
- (void)lookBabyInfo:(AddRelView *)relativeView;
- (void)readIPhonefromMobile:(AddRelView *)realtiveView;
- (void)addFamNumber:(AddRelView *)relativeView;
@end

@interface AddRelView : UIView

@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,assign) id <AddRelViewDelegate> addRelDelegate;
@property (nonatomic,strong) UIImageView *relativeHeaderView;
@property (nonatomic,strong) UILabel     *relNameLab;
@property (nonatomic,strong) UITextField *relNameField;
@property (nonatomic,strong) UIButton    *modNameBut;
@property (nonatomic,strong) UIButton    *makeSureBut;
@property (nonatomic,strong) UIButton    *updateBut;
@property (nonatomic,strong) UIButton    *phoneView;
@property (nonatomic,strong) UITextField *phoneNumberLab;
@property (nonatomic,strong) UIButton    *RightBut;

@end
