//
//  PlayMileageTableViewCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "PlayMileageTableViewCell.h"
#import "MileagePlayModel.h"
#import "NSString+Common.h"
#import "HorizontalButton.h"

@implementation PlayMileageTableViewCell
{
    UIView *_bgView;
    UIImageView *_imgView;
    UILabel *_titleLabel;
    UILabel *_contLabel;
    UILabel *_tipLabel;
    UILabel *_numLabel;
    UILabel *_timeLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 100)];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        [_bgView.layer setMasksToBounds:YES];
        [_bgView.layer setCornerRadius:3];
        [self.contentView addSubview:_bgView];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 57, 57)];
        [_imgView setContentMode:UIViewContentModeScaleAspectFill];
        [_imgView setClipsToBounds:YES];
        [_imgView setBackgroundColor:BACKGROUND_COLOR];
        [_bgView addSubview:_imgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 5, 5, _bgView.frameWidth - _imgView.frameRight - 15, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_bgView addSubview:_titleLabel];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 5, _titleLabel.frameBottom + 5, 45, 17)];
        [_tipLabel setBackgroundColor:CreateColor(42, 180, 72)];
        [_tipLabel setFont:[UIFont systemFontOfSize:10]];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [_tipLabel.layer setMasksToBounds:YES];
        [_tipLabel.layer setCornerRadius:2];
        [_tipLabel setText:@"里程主题"];
        [_bgView addSubview:_tipLabel];
        
        _contLabel = [[UILabel alloc] initWithFrame:CGRectMake(_tipLabel.frameRight + 5, _tipLabel.frame.origin.y, _bgView.frameWidth - _tipLabel.frameRight - 15, 17)];
        [_contLabel setBackgroundColor:[UIColor clearColor]];
        [_contLabel setFont:[UIFont systemFontOfSize:10]];
        [_contLabel setTextColor:CreateColor(42, 180, 72)];
        [_bgView addSubview:_contLabel];
        
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 5, _tipLabel.frameBottom + 5, _bgView.frameWidth - _imgView.frameRight - 15, 20)];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setFont:[UIFont systemFontOfSize:12]];
        [_numLabel setTextColor:CreateColor(42, 180, 72)];
        [_bgView addSubview:_numLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bgView.frameWidth - 100, 75, 90, 20)];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:10]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        [_bgView addSubview:_timeLabel];
        
        NSArray *imgArr = @[@"play_share",@"play_chang",@"play_changname",@"play_delete"];
        NSArray *nameArr = @[@"分享",@"编辑",@"重命名",@"删除"];
        for (int i = 0; i < 4; i++) {
            HorizontalButton *horButton = [[HorizontalButton alloc] initWithFrame:CGRectMake(10 + 50 * i, 75, 42, 20)];
            [horButton setImgSize:CGSizeMake(12, 12)];
            [horButton setTextSize:CGSizeMake(30,20)];
            [horButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [horButton setImage:CREATE_IMG(imgArr[i]) forState:UIControlStateNormal];
            [horButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [horButton setTag:i + 1];
            [horButton setTitle:nameArr[i] forState:UIControlStateNormal];
            [horButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [horButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [_bgView addSubview:horButton];
        }
    }
    
    return self;
}

- (void)buttonAction:(id)sender
{
    HorizontalButton *btn = (HorizontalButton *)sender;
    if ([btn tag] == 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(sharePlayMileage:ShareImage:)]) {
            [_delegate sharePlayMileage:self ShareImage:[_imgView image]];
        }
    }else if ([btn tag] == 2){
        if (_delegate && [_delegate respondsToSelector:@selector(editPlayMileage:)]) {
            [_delegate editPlayMileage:self];
        }
    }else if ([btn tag] == 3){
        if (_delegate && [_delegate respondsToSelector:@selector(changePlayMileage:)]) {
            [_delegate changePlayMileage:self];
        }
    }else if ([btn tag] == 4){
        if (_delegate && [_delegate respondsToSelector:@selector(deletePlayMileage:)]) {
            [_delegate deletePlayMileage:self];
        }
    }
}

- (void)resetDataSource:(id)object
{
    MileagePlayModel *item = (MileagePlayModel *)object;
    NSString *str = item.cover_img;
    if (![str hasPrefix:@"http"]) {
        str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
    }
    [_imgView setImageWithURL:[NSURL URLWithString:str]];
    if ([item.album_id integerValue] > 0) {
        [_contLabel setText:item.name];
        [_contLabel setHidden:NO];
        [_tipLabel setHidden:NO];
    }else{
        [_contLabel setHidden:YES];
        [_tipLabel setHidden:YES];
    }
    [_titleLabel setText:item.title];
    [_numLabel setText:[NSString stringWithFormat:@"%@/%@",item.num,item.max_num]];
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:item.create_time.doubleValue];
    [_timeLabel setText:[NSString stringWithFormat:@"%@ 创建",[NSString stringByDate:@"yyyy/MM/dd" Date:updateDate]]];
}

@end
