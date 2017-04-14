//
//  FamilyEditListCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/5/6.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "FamilyEditListCell.h"
#import "DJTPieChart.h"
#import "EditFamilyModel.h"
#import "NSString+Common.h"

#define PCColor1 CreateColor(225, 143, 143)
#define PCColor2 CreateColor(243, 217, 58)
#define PCColor3 CreateColor(98, 168, 246)
#define PCColor4 CreateColor(195, 242, 65)
#define PCColor5 CreateColor(157, 235, 233)
@interface FamilyEditListCell () <DJTPieChartDataSource,DJTPieChartDelegate>
{
    UIImageView *_tipImgView;
    UILabel *_titleLabel;
    
    NSMutableArray *_slices;
    NSMutableArray *_sliceColors;
    
    DJTPieChart *_pieChartRight;
    
    //////
    UILabel *_contLabel;
    UIButton *_palyBtn;
    UILabel *_timeLabel;
    
    UIView *_bgView,*_lineView,*_textView;
}
@end

@implementation FamilyEditListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat width = 301.5,xOri = (SCREEN_WIDTH - width) / 2;
        
        //middle
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(xOri, 10, width, self.contentView.frameHeight - 16)];
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
        
        //top
        CGRect topRect = CGRectMake(xOri, 0, middleView.frameWidth, 60);
        UIImageView *topImg = [[UIImageView alloc] initWithFrame:topRect];
        [topImg setImage:CREATE_IMG(@"contact_cell_bg1")];
        [self.contentView addSubview:topImg];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24.5, topImg.frameWidth, 18)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [topImg addSubview:_titleLabel];
        
        _tipImgView = [[UIImageView alloc] initWithImage:CREATE_IMG(@"contact_teacher")];
        [_tipImgView setFrame:CGRectMake(topImg.frameWidth - 13.5 - 10, 7, 13.5, 34)];
        [topImg addSubview:_tipImgView];
        
        //bottom
        UIImageView *bottomImg = [[UIImageView alloc] initWithFrame:CGRectMake(topImg.frameX, self.contentView.frameHeight - 6, topImg.frameWidth, 6)];
        [bottomImg setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [bottomImg setImage:CREATE_IMG(@"contact_cell_bg2")];
        [self.contentView addSubview:bottomImg];
        
        _sliceColors = [NSMutableArray array];
        
        _pieChartRight = [[DJTPieChart alloc] initWithFrame:CGRectMake(40, topImg.frameBottom - middleView.frameY, 130, 130)];
        [_pieChartRight setDelegate:self];
        [_pieChartRight setDataSource:self];
        [_pieChartRight setShowPercentage:NO];
        [_pieChartRight setLabelColor:[UIColor blackColor]];
        [_pieChartRight setShowLabel:NO];
        [middleView addSubview:_pieChartRight];
        
        //textView
        UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(_pieChartRight.frameRight + 30, _pieChartRight.frameY + 15, middleView.frameWidth - _pieChartRight.frameRight - 40, 100)];
        _textView = textView;
        [textView setBackgroundColor:[UIColor whiteColor]];
        [textView setTag:1507];
        [middleView addSubview:textView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _pieChartRight.frameBottom + 10, middleView.frameWidth, 0.5)];
        [lineView setBackgroundColor:CreateColor(235, 235, 240)];
        [middleView addSubview:lineView];
        
        _contLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, lineView.frameBottom + 5, middleView.frameWidth - 10, 35)];
        [_contLabel setBackgroundColor:[UIColor clearColor]];
        [_contLabel setTextColor:[UIColor lightGrayColor]];
        _contLabel.numberOfLines = 0;
        [_contLabel setFont:[UIFont systemFontOfSize:12]];
        [middleView addSubview:_contLabel];
        
        _palyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_palyBtn setFrame:CGRectMake(5, middleView.frameHeight - 20 - 10 - 26.5, 176, 26.5)];
        [_palyBtn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_palyBtn setBackgroundImage:CREATE_IMG(@"contact_play") forState:UIControlStateNormal];
        [_palyBtn setBackgroundColor:CreateColor(44, 188, 64)];
        [_palyBtn.layer setCornerRadius:13];
        [_palyBtn setTag:1011];
        [_palyBtn setTitle:@"播放录音" forState:UIControlStateNormal];
        [_palyBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [_palyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_palyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [middleView addSubview:_palyBtn];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, middleView.frameHeight - 20, middleView.frameWidth - 35, 14)];
        [_timeLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_timeLabel setBackgroundColor:[UIColor whiteColor]];
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:10]];
        [middleView addSubview:_timeLabel];
        
        UIButton *delBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBut setFrame:CGRectMake(_timeLabel.frameRight, _timeLabel.frameY, 30, 20)];
        [delBut addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [delBut setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [delBut setImage:CREATE_IMG(@"contact_delete_n") forState:UIControlStateNormal];
        [delBut setImageEdgeInsets:UIEdgeInsetsMake(3, 8, 3, 8)];
        [middleView addSubview:delBut];
    }
    return self;
}

- (void)playAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(playRecording:AtBtn:)]) {
        [_delegate playRecording:self AtBtn:sender];
    }
}

- (void)deleteAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteSection:)]) {
        [_delegate deleteSection:self];
    }
}

- (void)resetFamilyEditListData:(id)object
{
    EditFamilyModel *model = (EditFamilyModel *)object;
    
    BOOL parent = ![model.create_user_type isEqualToString:@"2"];
    
    [_titleLabel setText:model.title];
    NSInteger total = 0;
    for (Options *option in model.options) {
        total += [option.count_option integerValue];
    }
    NSMutableArray *numbers = [NSMutableArray array];
    for (Options *option in model.options) {
        [numbers addObject:[NSNumber numberWithFloat:[option.count_option floatValue] / total]];
    }
    _slices = numbers;
    
    [_sliceColors removeAllObjects];
    
    NSArray *arr = @[PCColor1,PCColor2,PCColor3,PCColor4,PCColor5];
    NSInteger count = arr.count;
    for (int i = 0; i < [model.options count]; i++)
    {
        [_sliceColors addObject:[arr objectAtIndex:i % count]];
    }
    
    [_textView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < [model.options count]; i++) {
        Options *option = [model.options objectAtIndex:i];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, (_textView.frameHeight - 20 * [model.options count]) / 2 + 20 * i, _bgView.frameWidth - _pieChartRight.frameRight - 40, 20)];
        [bgView setBackgroundColor:CreateColor(235, 235, 240)];
        [bgView setTag:10 + i];
        [_textView addSubview:bgView];
        
        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        [colorLabel setBackgroundColor:arr[i]];
        [bgView addSubview:colorLabel];
        
        NSString *str = [NSString stringWithFormat:@"%@：%@项",option.option,option.count_option];
        NSMutableAttributedString *attributring = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:option.count_option];
        [attributring addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0,[attributring length])];
        [attributring addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0.5, bgView.frameWidth - 5 - 0.5, (i == [model.options count] - 1) ? 19 : 19.5)];
        [tipLabel setBackgroundColor:[UIColor whiteColor]];
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [tipLabel setFont:[UIFont systemFontOfSize:12]];
        [tipLabel setAttributedText:attributring];
        [bgView addSubview:tipLabel];
    }
    [_pieChartRight reloadData];
    
    [_contLabel setFrameHeight:model.class_commentHei];
    [_contLabel setText:model.comment];
    BOOL isShow = ([model.voice_url length] > 0);
    [_palyBtn setHidden:!isShow];
    
    _lineView.hidden = parent;
    NSString *imgName = parent ? @"contact_parent" : @"contact_teacher";
    [_tipImgView setImage:CREATE_IMG(imgName)];
    
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:model.update_time.doubleValue];
    [_timeLabel setText:[NSString stringWithFormat:@"%@  %@教师填写",[NSString stringByDate:@"yyyy/MM/dd   HH:mm:ss" Date:updateDate],model.teacher_name]];
    
}

#pragma mark - DJTPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(DJTPieChart *)pieChart
{
    NSLog(@"%@",_slices);
    return _slices.count;
}

- (CGFloat)pieChart:(DJTPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[_slices objectAtIndex:index] floatValue];
}

- (UIColor *)pieChart:(DJTPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [_sliceColors objectAtIndex:(index % _sliceColors.count)];
}

#pragma mark - DJTPieChart Delegate
- (void)pieChart:(DJTPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    UIView *tempView = (UIView *)[_bgView viewWithTag:1507];
    if (tempView) {
        UIView *bgView = (UIView *)[tempView viewWithTag:10 + index];
        if (bgView) {
            CGRect rec = bgView.frame;
            rec.origin.x += 15;
            [UIView animateWithDuration:0.35 animations:^{
                [bgView setFrame:rec];
            }];
        }
    }
}
- (void)pieChart:(DJTPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    UIView *tempView = (UIView *)[_bgView viewWithTag:1507];
    if (tempView) {
        UIView *bgView = (UIView *)[tempView viewWithTag:10 + index];
        if (bgView) {
            CGRect rec = bgView.frame;
            rec.origin.x -= 15;
            [UIView animateWithDuration:0.35 animations:^{
                [bgView setFrame:rec];
            }];
        }
    }
}

@end
