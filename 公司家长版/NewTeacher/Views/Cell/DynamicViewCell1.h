//
//  DynamicViewCell1.h
//  NewTeacher
//
//  Created by ZhangChengcai on 15/4/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DynamicViewCell1Delegate <NSObject>

@optional
- (void)selectImgView:(UITableViewCell *)cell At:(NSInteger)idx;

@end

@interface DynamicViewCell1 : UITableViewCell

@property (nonatomic,assign)BOOL firstIdx;
@property (nonatomic,assign)id<DynamicViewCell1Delegate> delegate;

- (void)resetClassGroupData:(id)object;

@end
