//
//  DJTShareImageView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/7/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTShareImageView.h"
#import "DJTGlobalManager.h"
#import "DJTGlobalDefineKit.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"

@implementation DJTShareImageView
{
    UIView *_downView;
}

+ (BOOL)isCanShareToOtherPlatform
{
    return [WXApi isWXAppInstalled] || [QQApiInterface isQQInstalled] || [WeiboSDK isWeiboAppInstalled];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        
        _downView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 98)];
        [_downView setBackgroundColor:CreateColor(32, 32, 32)];
        [self addSubview:_downView];
        
        NSMutableArray *titles = [NSMutableArray array];
        NSMutableArray *tags = [NSMutableArray array];
        NSMutableArray *imgs = [NSMutableArray array];
        if ([WXApi isWXAppInstalled]) {
            [titles addObjectsFromArray:@[@"微信好友",@"微信朋友圈"]];
            [imgs addObjectsFromArray:@[@"share1",@"share2"]];
            [tags addObjectsFromArray:@[@"1",@"2"]];
        }
        if ([QQApiInterface isQQInstalled]) {
            [titles addObjectsFromArray:@[@"手机QQ",@"QQ空间"]];
            [imgs addObjectsFromArray:@[@"share4",@"share14"]];
            [tags addObjectsFromArray:@[@"3",@"4"]];
        }
        
        if ([WeiboSDK isWeiboAppInstalled]) {
            [titles addObject:@"新浪微博"];
            [imgs addObject:@"share5"];
            [tags addObject:@"5"];
        }
        
        UIScrollView *downScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 68)];
        [downScroll setBackgroundColor:[UIColor clearColor]];
        [downScroll setContentSize:CGSizeMake(MAX(frame.size.width, (47 + 10) * titles.count + 10), 68)];
        downScroll.showsHorizontalScrollIndicator = NO;
        [_downView addSubview:downScroll];
        for (NSInteger i = 0; i < titles.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgs[i] ofType:@"png"]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[imgs[i] stringByAppendingString:@"_1"] ofType:@"png"]] forState:UIControlStateNormal];
            [button setTag:[tags[i] integerValue]];
            [button setBackgroundColor:[UIColor clearColor]];
            [button addTarget:self action:@selector(shareType:) forControlEvents:UIControlEventTouchUpInside];
            [button setFrame:CGRectMake(10 + (47 + 10) * i, 0, 47, 47)];
            [downScroll addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x - 7.5, 50, 62, 18)];
            [label setTextAlignment:1];
            [label setTextColor:[UIColor whiteColor]];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setText:titles[i]];
            [downScroll addSubview:label];
        }
    }
    return self;
}

- (void)dispissSelf:(id)sender
{
    [self cancelSelf:^(NSInteger index) {
        [self removeFromSuperview];
    } Idx:0];
}

- (void)shareType:(id)sender
{
    NSInteger index = [(UIButton *)sender tag] - 1;
    [self cancelSelf:^(NSInteger idx) {
        if (_delegate && [_delegate respondsToSelector:@selector(shareImageViewTo:)]) {
            [_delegate shareImageViewTo:idx];
        }
        [self removeFromSuperview];
    } Idx:index];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self cancelSelf:^(NSInteger idx) {
        [self removeFromSuperview];
    } Idx:0];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    UIViewController *control = [DJTGlobalManager viewController:self Class:[UIViewController class]];
    control.navigationController.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_downView setFrame:CGRectMake(0, self.frame.size.height - _downView.frame.size.height, _downView.frame.size.width, _downView.frame.size.height)];
    } completion:^(BOOL finished) {
        control.navigationController.view.userInteractionEnabled = YES;
    }];
}

- (void)cancelSelf:(void (^)(NSInteger index))comple Idx:(NSInteger)idx
{
    UIViewController *control = [DJTGlobalManager viewController:self Class:[UIViewController class]];
    control.navigationController.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_downView setFrame:CGRectMake(0, self.frame.size.height, _downView.frame.size.width, _downView.frame.size.height)];
    } completion:^(BOOL finished) {
        comple(idx);
        control.navigationController.view.userInteractionEnabled = YES;
    }];
    
}

@end
