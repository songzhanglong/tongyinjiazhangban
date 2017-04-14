//
//  DeleteFamilyView.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/14.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeleteFamilyView;
@protocol DeleteFamilyViewDelegate <NSObject>

@optional

- (void)deleteFamilyImageView:(DeleteFamilyView *)imageView;

@end

@interface DeleteFamilyView : UIView

@property (nonatomic,assign)id<DeleteFamilyViewDelegate> delegate;
@property (nonatomic,strong)UIImageView *contentImg;
@property (nonatomic,strong)UIButton    *deleteBut;
@property (nonatomic,strong)UILabel     *contentLab;

@end
