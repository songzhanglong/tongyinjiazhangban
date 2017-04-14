//
//  ResuableButton.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResuableButton;
@protocol ResuableButtonDelegate <NSObject>

- (void)touchResuableBut:(ResuableButton *)button;

@end

@interface ResuableButton : UIView
{
    UIImageView *_imageView;
    UILabel *_numLab;
}

@property (nonatomic,assign)id<ResuableButtonDelegate> delegate;

- (void)setLeftImage:(UIImage *)image;

- (void)setCommentNumber:(NSString *)num;

@end
