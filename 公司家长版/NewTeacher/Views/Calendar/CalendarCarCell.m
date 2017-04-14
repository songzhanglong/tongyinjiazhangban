//
//  CalendarCarCell.m
//  NewTeacher
//
//  Created by szl on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "CalendarCarCell.h"

@implementation CalendarCarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [_leftImgView setImage:CREATE_IMG(@"car_2")];
        
        CGFloat backX = _leftImgView.frameRight + _leftImgView.frameX;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(backX, 15, SCREEN_WIDTH - backX - 10, 60)];
        [backView setBackgroundColor:rgba(233, 233, 233, 1)];
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 5;
        //backView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        //backView.layer.borderWidth = 1;
        [self.contentView addSubview:backView];
        [self.contentView sendSubviewToBack:backView];
    }
    return self;
}

@end
