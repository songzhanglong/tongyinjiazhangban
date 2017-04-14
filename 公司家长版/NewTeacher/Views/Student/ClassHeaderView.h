//
//  ClassHeaderView.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/24.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassHeaderView;
@protocol ClassHeaderViewDelegate <NSObject>
@optional
-(void)touchHeadView:(ClassHeaderView *)click;

@end

@interface ClassHeaderView : UIView
@property (nonatomic,assign)id<ClassHeaderViewDelegate> delegate;
@property (nonatomic,strong) UIImageView *headImg;
@property (nonatomic,strong) UILabel *nameLab;
@end
