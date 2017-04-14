//
//  MyTableBar.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/23.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MyTableBar.h"
#import "DJTGlobalDefineKit.h"
#import "DJTGlobalManager.h"

@implementation MyTableBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

       // self.backgroundColor = [UIColor colorWithRed:44/255.0 green:47/255.0 blue:50/255.0 alpha:1];
       self.backgroundColor = [UIColor colorWithRed:88/255.0 green:73/255.0 blue:67/255.0 alpha:1];
        CGFloat butWei1 = 40;
        CGFloat margin = (frame.size.width - butWei1 * 4) / 5;
        
        NSArray *titles = @[@"班级圈",@"幼儿园",@"学堂",@"更多"];
        NSArray *titleImgArray = @[@"sy1.png",@"sy4",@"sy5.png",@"down4.png"];
        NSArray *titleHeilightImgArray = @[@"sy1_1.png",@"sy4_1.png",@"sy5_1.png",@"down4_1.png"];
        
        for (int i = 0 ; i < titles.count; i++) {
            CGFloat xOri = margin + (butWei1 + margin) * i;
            CGFloat yOri = (frame.size.height - 44) / 2;
            UIImage *image = [UIImage imageNamed:titleImgArray[i]];
            
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            [but setFrame:CGRectMake(xOri, yOri, butWei1, 44)];
            [but setBackgroundColor:[UIColor clearColor]];
            [but setImage:[UIImage imageNamed:[titleHeilightImgArray objectAtIndex:i] ] forState:UIControlStateSelected];
            [but setImage:image forState:UIControlStateNormal];
            [but addTarget:self action:@selector(buttonPre:) forControlEvents:UIControlEventTouchUpInside];
            but.tag = i + 1;
            but.selected = (i == 0);
            [self addSubview:but];
            
            NSString *title = titles[i];
            UIFont *font = [UIFont systemFontOfSize:11];
            CGSize bigSize = CGSizeZero;
            NSDictionary *attribute = @{NSFontAttributeName: font};
            bigSize = [title sizeWithAttributes:attribute];
            [but setTitle:titles[i] forState:UIControlStateNormal];
            [but.titleLabel setFont:font];
            [but setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [but setTitleColor:CreateColor(255, 177, 85) forState:UIControlStateSelected];
            //top, left, bottom, right
            [but setImageEdgeInsets:UIEdgeInsetsMake(-13, 0, 0, -bigSize.width)];
            [but setTitleEdgeInsets:UIEdgeInsetsMake(30, -image.size.width, 0, 0)];
        }
    }
    
    return self;
}

- (void)buttonPre:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_nSelectedIndex != index) {
        UIButton *button = (UIButton *)[self viewWithTag:_nSelectedIndex + 1];
        button.selected = NO;
        
        [(UIButton *)sender setSelected:YES];
        _nSelectedIndex = index;
        
        if (_delegate && [_delegate respondsToSelector:@selector(selectTableIndex:)]) {
            [_delegate selectTableIndex:index];
        }
    }    
    
}

- (void)setNSelectedIndex:(NSInteger)nSelectedIndex
{
    _nSelectedIndex = nSelectedIndex;
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [(UIButton *)subView setSelected:(subView.tag - 1 == nSelectedIndex)];
        }
    }
}

@end
