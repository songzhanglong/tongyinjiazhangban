//
//  StudentAllEditView.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StudentAllEditViewDelegate <NSObject>

@optional
- (void)selectEditIndex:(NSInteger)index;

@end

@interface StudentAllEditView : UIView

@property (nonatomic,assign)id<StudentAllEditViewDelegate> delegate;

- (void)showInView:(UIView *)view;

- (void)editStudentPhoto:(id)sender;

@end
