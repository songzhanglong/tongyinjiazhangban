//
//  TeacherMyViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "TeacherMyViewController.h"
#import "TeacherManagerViewController.h"
#import "VerticalButton.h"

@interface TeacherMyViewController ()

@end

@implementation TeacherMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 重载
- (void)createTableFooterView{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 15 + 100 + 15 + 18 + 15 + 14 + 15 + 14 + 30 + 75 + 20)];
        [footView setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - 100) / 2, 30, 100, 100)];
        imgView.image = CREATE_IMG(@"contact_a");
        [footView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, imgView.frameBottom + 15, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:@"无照片或小视频"];
        [footView addSubview:label];
        
        UIFont *font = [UIFont systemFontOfSize:10];
        NSArray *tips = @[@"添加照片或小视频，记录宝贝成长每一步。",@"将“班级”中的照片或小视频同步加入到“我的”中。"];
        NSArray *imgs = @[@"addMileageN",@"refreshTopN"];
        NSArray *butNors = @[@"addBabyN",@"refreshBabyN"],*butHlis = @[@"addBabyH",@"refreshBabyH"],*butTips = @[@"添加",@"同步"];
        CGFloat margin = (winSize.width - 114) / 3;
        for (NSInteger i = 0; i < 2; i++) {
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, label.frameBottom + 15 + (15 + 14) * i, winSize.width, 14)];
            [label1 setTextColor:[UIColor darkGrayColor]];
            [label1 setFont:font];
            [label1 setTag:i * 3 + 1];
            [label1 setText:[NSString stringWithFormat:@"%ld.您可以通过点击",(long)i + 1]];
            [label1 sizeToFit];
            [footView addSubview:label1];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:label1.frame];
            [label2 setTextColor:[UIColor darkGrayColor]];
            [label2 setFont:font];
            [label2 setText:tips[i]];
            [label2 setTag:i * 3 + 2];
            [label2 sizeToFit];
            [footView addSubview:label2];
            
            UIImageView *addView = [[UIImageView alloc] initWithFrame:CGRectMake(0, label1.frameY - 3, 20, 20)];
            NSString *str = imgs[i];
            [addView setImage:CREATE_IMG(str)];
            [addView setTag:i * 3 + 3];
            [footView addSubview:addView];
            
            if (i == 1) {
                [label1 setFrameX:(winSize.width - label1.frameWidth - label2.frameWidth - addView.frameWidth) / 2];
                [addView setFrameX:label1.frameRight];
                [label2 setFrameX:addView.frameRight];
                
                UIView *view1 = [footView viewWithTag:1];
                UIView *view2 = [footView viewWithTag:2];
                UIView *view3 = [footView viewWithTag:3];
                [view1 setFrameX:label1.frameX];
                [view2 setFrameX:label2.frameX];
                [view3 setFrameX:addView.frameX];
            }
            
            VerticalButton *button = [VerticalButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(margin + (margin + 57) * i, label.frameBottom + (15 + 14) * 2 + 15, 57, 75)];
            button.imgSize = CGSizeMake(57, 57);
            button.textSize = CGSizeMake(57, 18);
            [button setTitle:butTips[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            [button setTitleColor:rgba(248, 151, 55, 1) forState:UIControlStateNormal];
            [button.titleLabel setTextAlignment:1];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setImage:CREATE_IMG(butNors[i]) forState:UIControlStateNormal];
            [button setImage:CREATE_IMG(butHlis[i]) forState:UIControlStateHighlighted];
            if (i == 0) {
                [button addTarget:self action:@selector(addImageAndVideo:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [button addTarget:self action:@selector(findPeople:) forControlEvents:UIControlEventTouchUpInside];
            }
            [footView addSubview:button];
        }
        
        [_tableView setTableFooterView:footView];
    }
}

- (void)addImageAndVideo:(id)sender
{
    [(MyThemeManagerController *)self.parentViewController addTheme:nil];
}

- (void)findPeople:(id)sender
{
    [(TeacherManagerViewController *)self.parentViewController changeToClassSelected];
}

@end
