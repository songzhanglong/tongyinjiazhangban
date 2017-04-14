//
//  MileageAllEditView.h
//  NewTeacher
//
//  Created by 张雪松 on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MileageAllEditViewDelegate <NSObject>

@optional
- (void)selectEditIndex:(NSInteger)index;
- (void)cancelEditIndex;
@end

@interface MileageAllEditView : UIView

@property (nonatomic,assign)id<MileageAllEditViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles;

- (id)initWithFrame:(CGRect)frame Titles:(NSArray *)titles NImageNames:(NSArray *)nimgNames HImageNames:(NSArray *)himgNames;

- (void)showInView:(UIView *)view;

- (void)resetColorOfGrowAlbum;

@end
