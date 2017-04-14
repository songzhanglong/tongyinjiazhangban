//
//  ClassActivityNewCell.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/14.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassActivityNewCell : UITableViewCell
{
    UIImageView *_imageView,*_videoImg;
    UILabel *_numLabel,*_titleLab,*_timeLab,*_tipLabl;
}

- (void)resetClassActivityData:(id)object;

@end
