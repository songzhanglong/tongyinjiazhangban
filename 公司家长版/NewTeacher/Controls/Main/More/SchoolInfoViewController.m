//
//  SchoolInfoViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/26.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "SchoolInfoViewController.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"

@interface SchoolInfoViewController ()

@end

@implementation SchoolInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBack = YES;
    self.titleLable.text = @"用户信息";
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    //scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    //top
    CGFloat margin = 20;
    UIView *babyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 126)];
    babyView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:babyView];
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSArray *infoArray = @[user.uname,user.sex,user.birthday,[user.province stringByAppendingString:user.city]];
    NSArray *tipArray = @[@"学生姓名",@"学生性别",@"学生生日",@"所在地"];
    CGFloat width = (winSize.width - margin * 3) / 2;
    for (int i = 0; i < [infoArray count]; i ++) {
        NSInteger col = i % 2;
        NSInteger row = i / 2;
        UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(margin + (width + margin) * col, margin + (margin + 33) * row, 2, 33)];
        lineLab.backgroundColor = CreateColor(221, 221, 221);
        [babyView addSubview:lineLab];
        
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(lineLab.frame.origin.x + 8, lineLab.frame.origin.y, width - 10, 20)];
        nameLab.text = [infoArray objectAtIndex:i];
        nameLab.font = [UIFont systemFontOfSize:16];
        nameLab.textColor= [UIColor blackColor];
        nameLab.backgroundColor = [UIColor clearColor];
        [babyView addSubview:nameLab];
    
        UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height,nameLab.frame.size.width,13)];
        tipLab.text = [tipArray objectAtIndex:i];
        tipLab.font = [UIFont systemFontOfSize:12];
        tipLab.textColor = CreateColor(197, 197, 197);
        tipLab.backgroundColor = [UIColor clearColor];
        [babyView addSubview:tipLab];
    }
    
    //imageView
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w21" ofType:@"png"]];
    CGFloat hei = image.size.height * winSize.width / winSize.height;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, babyView.frame.size.height + babyView .frame.origin .y, winSize.width, hei)];
    [imageView setImage:image];
    [scrollView addSubview:imageView];
    
    NSString *teacherFace = user.teacher_face;
    if (![teacherFace hasPrefix:@"http"]) {
        teacherFace = [G_IMAGE_ADDRESS stringByAppendingString:user.teacher_face ?: @""];
    }
    NSString *schoolLogo = user.school_logo;
    if (![schoolLogo hasPrefix:@"http"]) {
        schoolLogo = [G_IMAGE_ADDRESS stringByAppendingString:user.school_logo ?: @""];
    }
    NSArray *imgStrArray = @[teacherFace,schoolLogo];
    CGFloat itemHei = (hei - 10 * 3) / 2;
    for (int i = 0 ;i < 2; i ++ ) {
        UIView *backView = [[UIImageView alloc]initWithFrame:CGRectMake(10 , 10 + (10 + itemHei) * i, winSize.width - 20, itemHei)];
        [backView setBackgroundColor:[UIColor whiteColor]];
        [imageView addSubview:backView];
        
        CGFloat tmpWei = (winSize.width - 20) / 3;
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake((tmpWei - 60) / 2, (itemHei - 60) / 2, 60, 60)];
        [imgView setBackgroundColor:BACKGROUND_COLOR];
        if (i == 0) {
            [imgView setImageWithURL:[NSURL URLWithString:[imgStrArray objectAtIndex:i]] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
        }
        else{
            [imgView setImageWithURL:[NSURL URLWithString:[imgStrArray objectAtIndex:i]]];
        }
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 30;
        [backView addSubview:imgView];
        
        UILabel *lineLab = [[UILabel alloc]initWithFrame:CGRectMake(tmpWei - 1, 0, 2, backView.frame.size.height)];
        lineLab.backgroundColor = CreateColor(221, 221, 221);
        [backView addSubview:lineLab];
        
        if (i == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tmpWei + 10, imgView.frame.origin.y, tmpWei * 2 - 20, 30)];
            [label setBackgroundColor:[UIColor clearColor]];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"教师姓名:%@",user.teacher_name]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,5)];
            [label setAttributedText:str];
            [backView addSubview:label];
            
            UILabel *teaTelLab = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x,label.frame.origin.y + label.frame.size.height, label.frame.size.width, 30)];
            teaTelLab.backgroundColor = [UIColor clearColor];
            teaTelLab.textColor = CreateColor(57, 157, 247);
            [teaTelLab setFont:[UIFont systemFontOfSize:18]];
            teaTelLab.text  = user.teacher_tel;
            [backView addSubview:teaTelLab];
        }
        else{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tmpWei + 10, imgView.frame.origin.y + 15, tmpWei * 2 - 20, 30)];
            [label setBackgroundColor:[UIColor clearColor]];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"校园名称:%@",user.school_name]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,5)];
            [label setAttributedText:str];
            [backView addSubview:label];
        }
    }
    
    NSString *str = user.intro;
    CGSize lastSize = CGSizeZero;
    UIFont *font = [UIFont systemFontOfSize:18];
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [str boundingRectWithSize:CGSizeMake(winSize.width - 40, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;

    UIView *mview = [[UIView alloc] initWithFrame:CGRectMake(20, imageView.frame.origin.y + imageView.frame.size.height+20, 100, 30)];
    mview.backgroundColor = CreateColor(63, 71, 98);
    [[mview layer]setCornerRadius:15];
    [scrollView addSubview:mview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"校园简介";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    [mview addSubview:label];
    
    UILabel *schoolIntro = [[UILabel alloc]initWithFrame:CGRectMake(20, 60+imageView.frame.origin.y + imageView.frame.size.height, winSize.width - 40, lastSize.height)];
    [schoolIntro setText:str];
    [schoolIntro setFont:font];
    [schoolIntro setNumberOfLines:0];
    [scrollView addSubview:schoolIntro];


    [scrollView setContentSize:CGSizeMake(winSize.width, MAX(winSize.height - 64, schoolIntro.frame.origin.y + schoolIntro.frame.size.height+60))];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden =NO;
}

@end
