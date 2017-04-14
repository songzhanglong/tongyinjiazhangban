//
//  MoreCell.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MoreCell.h"

@implementation MoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //imageView
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 20, 20)];
        [_imgView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_imgView];
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        //title
        CGFloat xOri = _imgView.frame.origin.x + _imgView.frame.size.width + 5;
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(xOri, _imgView.frame.origin.y, winSize.width - xOri - 37 - 30 - 25, 20)];
        [_titleLab setFont:[UIFont systemFontOfSize:18]];
        [_titleLab setTextColor:[UIColor blackColor]];
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_titleLab];
        
        _contLab = [[UILabel alloc] initWithFrame:CGRectMake(_titleLab.frame.origin.x + _titleLab.frame.size.width + 5,_imgView.frame.origin.y, 60, 20)];
        [_contLab setTextAlignment:NSTextAlignmentRight];
        [_contLab setFont:[UIFont systemFontOfSize:18]];
        [_contLab setTextColor:[UIColor blackColor]];
        [_contLab setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_contLab];
        
        //imageView
        _tipImg = [[UIImageView alloc] initWithFrame:CGRectMake(winSize.width - 37 - 30, 13, 37, 17)];
        [_tipImg setBackgroundColor:[UIColor clearColor]];
        [_tipImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"w6" ofType:@"png"]]];
        [self.contentView addSubview:_tipImg];
    }
    return self;
}

@end
