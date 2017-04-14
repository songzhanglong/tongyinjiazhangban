//
//  CalendarNoPhotoCell.h
//  NewTeacher
//
//  Created by szl on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeCardRecord.h"

@interface CalendarNoPhotoCell : UITableViewCell
{
    UIImageView *_leftImgView;
    UILabel *_nameLab,*_timeLab;
}

- (void)resetTimeCard:(TimeCardRecord *)record;

@end
