
//
//  FindPeopleViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/31.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "FindMyBabyViewController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "ThemeBatchModel.h"
#import "UIImage+Caption.h"

#define PLACE_BABY_MSG   @"对孩子里程的寄语"

@interface FindMyBabyViewController ()<UITextViewDelegate>

@end

@implementation FindMyBabyViewController
{
    UITextView *_textView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    [self createRightBarButton];    //右侧按钮
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = rgba(224, 224, 224, 1);
    _tableView.backgroundView = view;
    
    [self createTableHeadView];
}

- (void)createRightBarButton
{
    //返回按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    sureBtn.backgroundColor = [UIColor clearColor];
    [sureBtn setImage:[UIImage imageNamed:@"gou1.png"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(makeSure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)createTableHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    [headView setBackgroundColor:[UIColor whiteColor]];
    //text
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 60)];
    _textView.text = PLACE_BABY_MSG;
    _textView.delegate = self;
    _textView.returnKeyType=UIReturnKeyDone;
    [headView addSubview:_textView];
    
    CGFloat margin = (SCREEN_WIDTH - 90 * 3) / 4;
    CGFloat yOri = 75;
    for (NSInteger i = 0; i < [_themeItems count]; i++) {
        NSInteger col = i % 3;
        
        UIImageView *deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake((margin + 90) * col + margin, yOri, 90, 90)];

        ThemeBatchItem *item = _themeItems[i];
        NSString *str = item.thumb ?: item.path;
        if (![str hasPrefix:@"http"]) {
            str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if (item.type.integerValue != 0){
            //video
            UIImageView *videoImg = [[UIImageView alloc] initWithFrame:CGRectMake((deleteImg.frameWidth - 30) / 2, (deleteImg.frameHeight - 30) / 2, 30, 30)];
            [videoImg setImage:CREATE_IMG(@"mileageVideo")];
            [videoImg setTag:2];
            [videoImg setBackgroundColor:[UIColor clearColor]];
            [deleteImg addSubview:videoImg];
            
            BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
            if (mp4) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [deleteImg setImage:image];
                    });
                });
            }
            else
            {
                [deleteImg setImageWithURL:[NSURL URLWithString:str]];
            }
        }
        else
        {
            [deleteImg setImageWithURL:[NSURL URLWithString:str]];
        }
        
        [deleteImg setBackgroundColor:BACKGROUND_COLOR];
        [headView addSubview:deleteImg];
        
        if (col == 2) {
            yOri += 90 + 5;
        }
    }
    
    [headView setFrameHeight:yOri + 90 + 5];
    [_tableView setTableHeaderView:headView];
}

#pragma mark - actions
- (void)makeSure:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"foundMyBaby"];
    [param addEntriesFromDictionary:_reqParam];
    if (([_textView.text length] > 0) && ![_textView.text isEqualToString:PLACE_BABY_MSG]) {
        //设置文本信息
        [param setObject:_textView.text forKey:@"digst"];
    }
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    self.view.window.userInteractionEnabled = NO;
    [self.view.window makeToastActivity];
    __weak typeof(self)weakSelf = self;
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf submitFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf submitFinish:NO Data:nil];
    }];
}

- (void)submitFinish:(BOOL)suc Data:(id)result
{
    self.view.window.userInteractionEnabled = YES;
    [self.view.window hideToastActivity];
    self.httpOperation = nil;
    if (suc) {
        if (_delegate && [_delegate respondsToSelector:@selector(findMyBabyFininsh:)]) {
            [_delegate findMyBabyFininsh:self];
        }
        else
        {
            [self.view.window makeToast:@"同步成功" duration:1.0 position:@"center"];
        }
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACE_BABY_MSG]) {
        textView.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginChange:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if (textView != _textView) {
        return;
    }
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            [self emojiStrSplit:toBeString];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % 10000;
        int location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        if ([lastStr length] > 140) {
            lastStr = [lastStr substringToIndex:140];
        }
        [_textView setText:lastStr];
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
}


@end
