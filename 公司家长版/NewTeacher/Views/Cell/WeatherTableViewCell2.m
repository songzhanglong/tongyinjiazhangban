//
//  WeatherTableViewCell2.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/15.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "WeatherTableViewCell2.h"
#import "DJTGlobalManager.h"

@implementation WeatherTableViewCell2
{
    UILabel *_showLabel1, *_showLabel2, *_showLabel3, *_showLabel4, *_showLabel5, *_showLabel6;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 215)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        [bgView setTag:11];
        //[bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:bgView];
        
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, 35)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@%@",user.school_name,user.grade_name,user.class_name];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:nameLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nameLabel.frameBottom, SCREEN_WIDTH - 20, 0.5)];
        lineLabel.backgroundColor = [UIColor whiteColor];
        lineLabel.alpha = 0.1;
        [self.contentView addSubview:lineLabel];
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(10, lineLabel.frameBottom + 90, SCREEN_WIDTH - 20, 0.5)];
        lineLabel1.backgroundColor = [UIColor whiteColor];
        lineLabel1.alpha = 0.1;
        [self.contentView addSubview:lineLabel1];
        
        
        UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 20 - 0.5) / 2, lineLabel.frameBottom, 0.5, 180)];
        lineLabel2.backgroundColor = [UIColor whiteColor];
        lineLabel2.alpha = 0.1;
        [self.contentView addSubview:lineLabel2];
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, lineLabel.frameBottom + 20, 48, 48)];
        [imgView setImage:CREATE_IMG(@"weather6")];
        [self.contentView addSubview:imgView];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 5, lineLabel.frameBottom + 30, SCREEN_WIDTH / 2 - imgView.frameRight - 5, 20)];
        label1.backgroundColor = [UIColor clearColor];
        label1.text = @"室内温度";
        label1.textColor = [UIColor whiteColor];
        label1.alpha = 0.6;
        label1.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frameRight + 5, label1.frameBottom, SCREEN_WIDTH / 2 - imgView.frameRight - 5, 30)];
        _showLabel1 = label2;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.font = [UIFont boldSystemFontOfSize:22];
        [self.contentView addSubview:label2];
        
        
        UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, lineLabel.frameBottom + 20, 48, 48)];
        [imgView2 setImage:CREATE_IMG(@"weather7")];
        [self.contentView addSubview:imgView2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, lineLabel.frameBottom + 5, SCREEN_WIDTH - imgView2.frameRight - 20 - 5, 16)];
        label3.backgroundColor = [UIColor clearColor];
        label3.text = @"μg/m3";
        label3.textColor = [UIColor whiteColor];
        label3.alpha = 0.6;
        label3.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label3];
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, label3.frameBottom, SCREEN_WIDTH - imgView2.frameRight - 5, 16)];
        _showLabel2 = label4;
        label4.backgroundColor = [UIColor clearColor];
        label4.textColor = [UIColor whiteColor];
        label4.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label4];
        
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, label4.frameBottom, SCREEN_WIDTH - imgView2.frameRight - 5, 16)];
        label5.backgroundColor = [UIColor clearColor];
        label5.text = @"威胁指数";
        label5.textColor = [UIColor whiteColor];
        label5.alpha = 0.6;
        label5.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label5];
        
        UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(imgView2.frameRight + 5, label5.frameBottom, SCREEN_WIDTH - imgView2.frameRight - 5, 16)];
        _showLabel3 = label6;
        label6.backgroundColor = [UIColor clearColor];
        label6.text = @"无";
        label6.textColor = [UIColor whiteColor];
        label6.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label6];
        
        //第二行
        UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, lineLabel1.frameBottom + 20, 48, 48)];
        [imgView3 setImage:CREATE_IMG(@"weather8")];
        [self.contentView addSubview:imgView3];
        
        UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(imgView3.frameRight + 5, lineLabel1.frameBottom + 30, SCREEN_WIDTH / 2 - imgView3.frameRight - 5, 20)];
        label7.backgroundColor = [UIColor clearColor];
        label7.text = @"室内湿度";
        label7.textColor = [UIColor whiteColor];
        label7.alpha = 0.6;
        label7.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label7];
        
        UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(imgView3.frameRight + 5, label7.frameBottom, SCREEN_WIDTH / 2 - imgView3.frameRight - 5, 30)];
        _showLabel4 = label8;
        label8.backgroundColor = [UIColor clearColor];
        label8.textColor = [UIColor whiteColor];
        label8.font = [UIFont boldSystemFontOfSize:22];
        [self.contentView addSubview:label8];
        
        
        UIImageView *imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, lineLabel1.frameBottom + 20, 48, 48)];
        [imgView4 setImage:CREATE_IMG(@"weather9")];
        [self.contentView addSubview:imgView4];
        
        UILabel *label9 = [[UILabel alloc] initWithFrame:CGRectMake(imgView4.frameRight + 5, lineLabel1.frameBottom + 5, SCREEN_WIDTH - imgView4.frameRight - 20 - 5, 16)];
        label9.backgroundColor = [UIColor clearColor];
        label9.text = @"μg/m3";
        label9.textColor = [UIColor whiteColor];
        label9.alpha = 0.6;
        label9.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label9];
        
        UILabel *label10 = [[UILabel alloc] initWithFrame:CGRectMake(imgView4.frameRight + 5, label9.frameBottom, SCREEN_WIDTH - imgView4.frameRight - 20 - 5, 16)];
        _showLabel5 = label10;
        label10.backgroundColor = [UIColor clearColor];
        label10.textColor = [UIColor whiteColor];
        label10.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label10];
        
        UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(imgView4.frameRight + 5, label10.frameBottom, SCREEN_WIDTH - imgView4.frameRight - 20 - 5, 16)];
        label11.backgroundColor = [UIColor clearColor];
        label11.text = @"威胁指数";
        label11.textColor = [UIColor whiteColor];
        label11.alpha = 0.6;
        label11.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label11];
        
        UILabel *label12 = [[UILabel alloc] initWithFrame:CGRectMake(imgView4.frameRight + 5, label11.frameBottom, SCREEN_WIDTH - imgView4.frameRight - 5, 16)];
        _showLabel6 = label12;
        label12.backgroundColor = [UIColor clearColor];
        label12.textColor = [UIColor whiteColor];
        label12.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:label12];
        
    }
    return self;
}

- (void)resetDataSource:(WeatherModel *)model {
    PMModel *pm = model.pmMdel;
    _showLabel1.text = pm.temp ? [NSString stringWithFormat:@"%@°",pm.temp] : @"";
    _showLabel2.text = pm.HCHO;
    _showLabel3.text = pm.hchoStr;
    _showLabel4.text = pm.humity ? [NSString stringWithFormat:@"%@%%",pm.humity] : @"";
    _showLabel5.text = pm.PM25;
    _showLabel6.text = pm.pm25Str;
}

@end
