//
//  DeleteFamilyView.m
//  NewTeacher
//
//  Created by ZhangChengcai on 15/5/14.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DeleteFamilyView.h"

@implementation DeleteFamilyView

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height )];
        _contentImg.layer.masksToBounds = YES;
        _contentImg.layer.cornerRadius = MIN(frame.size.width - 20, frame.size.height - 20) / 2;
        [self addSubview:_contentImg];
        
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(_contentImg.frame.origin.x, _contentImg.frame.size.height + _contentImg.frame.origin.y + 1, _contentImg.frame.size.width, 20 )];
        _contentLab.text = @"测试";
        _contentLab.font = [UIFont systemFontOfSize:12];
        _contentLab.textAlignment = 1;
        [self addSubview:_contentLab];
        
        _deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBut.hidden = YES;
        [_deleteBut setImage:[UIImage imageNamed:@"closed2.png"] forState:UIControlStateNormal];
        [_deleteBut setFrame:CGRectMake(frame.size.width - 20, -5, 30, 30)];
        [_deleteBut setBackgroundColor:[UIColor clearColor]];
        [_deleteBut addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBut];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGR:)];
        longPressGR.minimumPressDuration = 1;
        [self addGestureRecognizer:longPressGR];
    }
    return self;
}
- (void)longPressGR:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.deleteBut.hidden = NO;
    }
}
# pragma  mark - DeleteImageDelegate
- (void)deleteImage:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteFamilyImageView:)]) {
        [_delegate deleteFamilyImageView:self];
    }
    [self removeFromSuperview];
}


@end
