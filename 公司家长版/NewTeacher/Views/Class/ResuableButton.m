//
//  ResuableButton.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ResuableButton.h"

@implementation ResuableButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
        self.layer.cornerRadius = 2.0;
        
        //imageView
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, (frame.size.height - 15) / 2, 18, 18)];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_imageView];
        
        //label
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(28, _imageView.frame.origin.y, frame.size.width - 28 - 2, _imageView.frame.size.height)];
        [_numLab setTextAlignment:1];
        [_numLab setTextColor:CreateColor(134, 135, 136)];
        [_numLab setBackgroundColor:[UIColor clearColor]];
        [_numLab adjustsFontSizeToFitWidth];
        [self addSubview:_numLab];
        
    }
    
    return self;
}

- (void)setLeftImage:(UIImage *)image
{
    [_imageView setImage:image];
}

- (void)setCommentNumber:(NSString *)num
{
    [_numLab setText:num];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    if (_delegate && [_delegate respondsToSelector:@selector(touchResuableBut:)]) {
        [_delegate touchResuableBut:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
}

@end
