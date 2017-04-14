//
//  MileagePermissionsViewController.m
//  NewTeacher
//
//  Created by 张雪松 on 15/12/5.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileagePermissionsViewController.h"

@interface MileagePermissionsViewController ()

@end

@implementation MileagePermissionsViewController
{
    int lastIndex;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLable.text = @"谁可以看";
    self.view.backgroundColor = CreateColor(238, 239, 243);
    
    if ([_indexToType integerValue] == 3) {
        lastIndex = 1;
    }else if ([_indexToType integerValue] == 2) {
        lastIndex = 2;
    }else {
        lastIndex = 3;
    }
    //lastIndex = 1;
    
    [self createNavButton];
    
    [self creatUI];
}

- (void)createNavButton{
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60.0, 30.0)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [backBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, backBarButtonItem];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightView setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rigBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer2.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer2,rigBtn];
    
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50.0, 30.0)];
    [moreBtn setTitle:@"确定" forState:UIControlStateNormal];
    [moreBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [moreBtn setTitleColor:CreateColor(43, 203, 40) forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[rightNegativeSpacer,rightBarButtonItem];
}

- (void)backToPreControl:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(permissionsToSelect:)]) {
        int _indexType = 3;
        if (lastIndex == 1) {
            _indexType = 3;
        }else if (lastIndex == 2) {
            _indexType = 2;
        }else {
            _indexType = 1;
        }
        [_delegate permissionsToSelect:_indexType];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)creatUI
{
    NSArray *nameArray = @[@"公开",@"部分可见",@"私密"];
    NSArray *contArray = @[@"所有使用APP用户可见",@"仅班级成员可见",@"仅自己可见"];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    for (int i = 0; i < 3; i++) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 70 * i, winSize.width, 60)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.tag = i + 1;
        bgView.userInteractionEnabled = YES;
        [self.view addSubview:bgView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (bgView.frame.size.height - 30) / 2, 30, 30)];
        imgView.image = CREATE_IMG((i != lastIndex - 1) ? @"bb2@2x" : @"bb2_1@2x");
        imgView.tag = i + 1 + 10;
        [bgView addSubview:imgView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 5, 10, winSize.width - imgView.frame.origin.x - imgView.frame.size.width - 15, 20)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = nameArray[i];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [bgView addSubview:nameLabel];
        
        UILabel *contLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 5, nameLabel.frame.origin.y + nameLabel.frame.size.height, winSize.width - imgView.frame.origin.x - imgView.frame.size.width - 15, 20)];
        contLabel.backgroundColor = [UIColor clearColor];
        contLabel.text = contArray[i];
        contLabel.textColor = [UIColor darkTextColor];
        contLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:contLabel];
        
        UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesturRecognizer:)];
        [bgView addGestureRecognizer:tapGesturRecognizer];
    }
}

- (void)tapGesturRecognizer:(UITapGestureRecognizer *)sender{

    UIView *lastView = (UIView *)[self.view viewWithTag:lastIndex];
    UIImageView *lastImgView = (UIImageView *)[lastView viewWithTag:lastView.tag + 10];
    if (lastImgView) {
        lastImgView.image = CREATE_IMG(@"bb2@2x");
    }
    
    UIView *currView = sender.view;
    UIImageView *imgView = (UIImageView *)[currView viewWithTag:currView.tag + 10];
    if (imgView) {
        imgView.image = CREATE_IMG(@"bb2_1@2x");
        lastIndex = (int)currView.tag;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
