//
//  FamilyEditFooterCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/17.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyEditFooterCell.h"
#import "FamilyDetailModel.h"

@interface FamilyEditFooterCell ()
{
    UILabel *_contLabel;
    UIView *_bgView;
    NSInteger _curIdx;
    OptionsItem *_item;
}
@end

@implementation FamilyEditFooterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor clearColor]];
        CGFloat width = 301.5,xOri = (SCREEN_WIDTH - width) / 2;
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(xOri, 0, width, self.contentView.frameHeight - 6)];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        [_bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_bgView];
        
        _contLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, _bgView.frameWidth - 20, _bgView.frameHeight - 10 - 20)];
        _contLabel.backgroundColor = [UIColor clearColor];
        [_contLabel setFont:[UIFont systemFontOfSize:12]];
        [_contLabel setTextColor:[UIColor lightGrayColor]];
        _contLabel.numberOfLines = 0;
        [_bgView addSubview:_contLabel];
        
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
        
        //bottom
        UIImageView *bottomImg = [[UIImageView alloc] initWithFrame:CGRectMake(xOri, self.contentView.frameHeight - 6, width, 6)];
        [bottomImg setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [bottomImg setImage:CREATE_IMG(@"contact_cell_bg2")];
        [self.contentView addSubview:bottomImg];
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

- (void)resetFamilyEditFooterData:(id)object Options:(NSArray *)option;
{
    OptionsItem *item = (OptionsItem *)object;
    _item = item;
    _curIdx = item.nIdx;

    [_contLabel setFrameHeight:item.class_contHei];
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
