//
//  SortStudentView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/13.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SortStudentView.h"

@implementation SortStudentView
{
    UIImageView *_imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat minWei = 150,maxWei = 200;
        NSArray *titles = @[@"照片数量从高到低",@"照片数量从低到高",@"成长档案完成度从高到低",@"成长档案完成度从低到高"];
        CGFloat yOri = 20;
        for (NSInteger i = 0; i < 4; i++) {
            CGFloat xOri = (i < 2) ? (frame.size.width - minWei) / 2 : (frame.size.width - maxWei) / 2;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button setFrame:CGRectMake(xOri, yOri, (i < 2) ? minWei : maxWei, 20)];
            [button addTarget:self action:@selector(startSort:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setTag:i + 1];
            [self addSubview:button];
            
            yOri += 20 + 10;
        }
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gou1.png"]];
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)startSort:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_nSortIndex != index) {
        self.nSortIndex = index;
    }
    
    [_delegate selectSortType:self];
}

- (void)setNSortIndex:(NSInteger)nSortIndex
{
    _nSortIndex = nSortIndex;
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:i + 1];
        [button setTitleColor:(i == nSortIndex) ? [UIColor greenColor] : [UIColor blackColor] forState:UIControlStateNormal];
        if (i == nSortIndex) {
            [_imageView setFrame:CGRectMake(button.frame.origin.x - 10 - 30, button.frame.origin.y + button.frame.size.height - 30, 30, 30)];
        }
    }
}

@end
