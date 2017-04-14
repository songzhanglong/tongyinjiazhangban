//
//  WeatherTableViewCell.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "WeatherTableViewCell.h"

@implementation WeatherTableViewCell
{
    UILabel *_label, *_showLabel1, *_showLabel2, *_showLabel3, *_showLabel4;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 95)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        [bgView setTag:11];
        //[bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:bgView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 48, 48)];
        [imgView setImage:CREATE_IMG(@"weather4")];
        [self.contentView addSubview:imgView];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 5, 20, SCREEN_WIDTH / 2 - imgView.frameRight - 5, 20)];
        _label = label1;
        label1.backgroundColor = [UIColor clearColor];
        label1.text = @"空气质量";
        label1.textColor = [UIColor whiteColor];
        label1.alpha = 0.6;
        label1.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 5, label1.frameBottom, 38, 30)];
        _showLabel1 = label2;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.font = [UIFont boldSystemFontOfSize:18];
        [self.contentView addSubview:label2];
        
        UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(label2.frameRight + 5, label1.frameBottom + 7.5, 25, 15)];
        _showLabel2 = label7;
        label7.layer.masksToBounds = YES;
        label7.layer.cornerRadius = 2;
        label7.backgroundColor = CreateColor(47, 202, 10);
        label7.textAlignment = NSTextAlignmentCenter;
        label7.textColor = [UIColor whiteColor];
        label7.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label7];
        
        
        UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, 10, 48, 48)];
        [imgView2 setImage:CREATE_IMG(@"weather5")];
        [self.contentView addSubview:imgView2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, 5, SCREEN_WIDTH - imgView.frameRight - 20 - 5, 16)];
        label3.backgroundColor = [UIColor clearColor];
        label3.textColor = [UIColor whiteColor];
        label3.text = @"风向";
        label3.alpha = 0.6;
        label3.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label3];
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, label3.frameBottom, SCREEN_WIDTH - imgView.frameRight - 20 - 5, 16)];
        _showLabel3 = label4;
        label4.backgroundColor = [UIColor clearColor];
        label4.textColor = [UIColor whiteColor];
        label4.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label4];
        
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, label4.frameBottom, SCREEN_WIDTH - imgView.frameRight - 20 - 5, 16)];
        label5.backgroundColor = [UIColor clearColor];
        label5.text = @"风力";
        label5.alpha = 0.6;
        label5.textColor = [UIColor whiteColor];
        label5.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label5];
        
        UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, label5.frameBottom, SCREEN_WIDTH - imgView.frameRight - 20 - 5, 16)];
        _showLabel4 = label6;
        label6.backgroundColor = [UIColor clearColor];
        label6.textColor = [UIColor whiteColor];
        label6.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label6];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, bgView.frameBottom - 25, SCREEN_WIDTH - 40, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"*天气数据来源：中国天气网";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:label];
    }
    return self;
}

- (void)resetDataSource:(WeatherModel *)object {
    _showLabel1.text = object.aqi;
    _showLabel2.text = object.aqi_desc;
    [_showLabel2 setFrame:CGRectMake(_showLabel1.frameRight + 5, _label.frameBottom + 7.5, object.descSize.width, 15)];
    _showLabel3.text = object.fx_name;
    _showLabel4.text = object.fl_name;
}

@end
