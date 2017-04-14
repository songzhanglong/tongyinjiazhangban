//
//  FamilyEditCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/5.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyEditCell.h"
#import "FamilyDetailModel.h"

@interface FamilyEditCell ()
{
    UIView *_bgView;
    UILabel *_contLabel;
    UILabel *_lineLabel;
    
    NSInteger _curIdx;
    OptionsItem *_item;
}
@end

@implementation FamilyEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat width = 301.5,xOri = (SCREEN_WIDTH - width) / 2;
        
        //middle
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(xOri, 0, width, self.contentView.frameHeight)];
        [middleView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [middleView setBackgroundColor:[UIColor whiteColor]];
        _bgView = middleView;
        [self.contentView addSubview:middleView];
        
        //left + right
        UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.5, middleView.frameHeight)];
        [leftImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [leftImg setImage:CREATE_IMG(@"contact_cell_bg3")];
        [middleView addSubview:leftImg];
        
        UIImageView *rightImg = [[UIImageView alloc] initWithFrame:CGRectMake(middleView.frameWidth - 0.5, 0, 0.5, middleView.frameHeight)];
        [rightImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [rightImg setImage:CREATE_IMG(@"contact_cell_bg3")];
        [middleView addSubview:rightImg];
        
        //check
        CGFloat indexHei = 0;
        for (int i = 0; i < 5; i++) {
            UIButton *optionBtn = (UIButton *)[_bgView viewWithTag:100 + i];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_normal")];
            [imgView setTag:10];
            
            UIImageView *cheakImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-2, -2.5, 13, 9.5)];
            [cheakImgView setTag:11];
            [cheakImgView setImage:CREATE_IMG(@"contact_cheak")];
            [imgView addSubview:cheakImgView];
            
            [imgView setFrame:CGRectMake(-2, 3.5 + 3, 7, 7)];//26 19
            optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [optionBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            optionBtn.selected = NO;
            [optionBtn setFrame:CGRectMake(_bgView.frameWidth - (45 + 17) - indexHei, _contLabel.frameBottom + 2, 45 + 11, 20)];
            indexHei += optionBtn.frameWidth;
            [optionBtn setTag:100 + i];
            [optionBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [optionBtn addTarget:self action:@selector(checkPressed:) forControlEvents:UIControlEventTouchUpInside];
            [optionBtn addSubview:imgView];
            [_bgView addSubview:optionBtn];
        }
        
        _contLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, middleView.frameWidth - 20, 0)];
        _contLabel.backgroundColor = [UIColor clearColor];
        [_contLabel setFont:[UIFont systemFontOfSize:12]];
        [_contLabel setTextColor:[UIColor lightGrayColor]];
        _contLabel.numberOfLines = 0;
        [middleView addSubview:_contLabel];
        
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, middleView.frameHeight - 0.5, middleView.frameWidth, 0.5)];
        [_lineLabel setBackgroundColor:CreateColor(235, 235, 240)];
        [middleView addSubview:_lineLabel];
    }
    return self;
}

- (void)checkPressed:(id)sender
{
    if (_isEdit) {
        return;
    }
    
    UIButton *btn = (UIButton *)sender;
    NSInteger index = btn.tag - 100;
    if (_curIdx == index) {
        return;
    }
    
    _item.nIdx = index;
    UIView *preView = [[btn superview] viewWithTag:_curIdx + 100];
    if (preView) {
        UIImageView *cheakImgView = (UIImageView *)[preView viewWithTag:11];
        cheakImgView.hidden = YES;
    }
    
    UIImageView *sbuImg = (UIImageView *)[btn viewWithTag:11];
    sbuImg.hidden = NO;
    _curIdx = index;

    if (_delegate && [_delegate respondsToSelector:@selector(selectOptions:Option_title:)]) {
        [_delegate selectOptions:self Option_title:[btn.titleLabel text]];
    }
}
    
- (void)resetFamilyEditData:(id)object Options:(NSArray *)option
{
    OptionsItem *item = (OptionsItem *)object;
    _item = item;
    _curIdx = item.nIdx;
    
    [_contLabel setFrameHeight:item.class_contHei];
    [_lineLabel setFrameY:_contLabel.frameBottom + 2 + 26 - 0.5];
    [_contLabel setText:item.content ?: @""];
    
    for (NSInteger i = 0; i < 5; i++) {
        UIButton *optionBtn = (UIButton *)[_bgView viewWithTag:100 + i];
        if (i < option.count) {
            [optionBtn setHidden:NO];
            [optionBtn setFrameY:_contLabel.frameBottom + 2];
            [optionBtn setTitle:[option objectAtIndex:i] forState:UIControlStateNormal];
            UIImageView *imgView = (UIImageView *)[optionBtn viewWithTag:10];
            UIImageView *cheakImgView = (UIImageView *)[imgView viewWithTag:11];
            cheakImgView.hidden = (_curIdx != i);
        }else{
            [optionBtn setHidden:YES];
        }
    }
}

@end
