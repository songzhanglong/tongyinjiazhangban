//
//  ResuableHeadImages.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResuableImageViews.h"

@interface ResuableHeadImages : UIView
{
    NSMutableArray *imageViews;
}

@property (nonatomic,assign)id<ColleagueImageViewDelegate> delegate;
@property (nonatomic,strong)NSArray *images;

@end
