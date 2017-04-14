//
//  ClassReplyDetailController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/17.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ClassReplyDetailController.h"
#import "ClassCircleModel.h"
#import "NSString+Common.h"
#import "ResuableHeadImages.h"
#import "ResuableButton.h"
#import "NSObject+Reflect.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "InputBar.h"
#import "UIImage+Caption.h"
#import "UMSocial.h"
#import "DJTShareView.h"
#import "DynamicDetailCell.h"

@interface ClassReplyDetailController ()<ColleagueImageViewDelegate,ResuableButtonDelegate,InputBarDelegate,UIActionSheetDelegate,DJTShareViewDelegate,UMSocialUIDelegate,DynamicDetailCellDelegate>

@end

@implementation ClassReplyDetailController
{
    UILabel *_timeLab,*_numLab;
    ResuableButton *_digistBut,*_commentBut;
    InputBar *_inputBar;
    UILabel  *_views;
    NSIndexPath *_indexPath,*_delIndexPath;
    NSString *_content;
    UIImageView *_heartImg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"回复详情";
    [self createRightButton];
    self.useNewInterface = YES;

    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"dynamicDetail"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:manager.userInfo.class_id forKey:@"class_id"];
    [param setObject:@"0" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
    [param setObject:_circleId ?: _circleModel.tid forKey:@"id"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createTableViewAndRequestAction:@"dynamic" Param:param Header:YES Foot:NO];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 44)];
    _tableView.separatorColor = [UIColor lightGrayColor];
    [_tableView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    [self.view setBackgroundColor:_tableView.backgroundColor];
    
    //input
    _inputBar = [[InputBar alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height, _tableView.frame.size.width, 44)];
    _inputBar.delegate = self;
    _inputBar.hidden = YES;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.hidden = YES;
    [self.view addSubview:_inputBar];
    [self beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)createRightButton
{
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"down4_1@2x" ofType:@"png"]] forState:UIControlStateHighlighted];
    [moreBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"down4_2@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(popMoreItems:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)popMoreItems:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: @"分享",nil];
    [sheet showInView:self.navigationController.view];
}

- (void)resetSubViewFrames:(NSArray *)subViews
{
    for (UIView *subView in subViews) {
        CGRect rect = subView.frame;
        [subView setFrame:CGRectMake(rect.origin.x + 10, rect.origin.y + 5, rect.size.width, rect.size.height)];
    }
}

- (UIView *)createTableHeaderView
{
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    //head
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    headImg.clipsToBounds = YES;
    headImg.contentMode = UIViewContentModeScaleAspectFill;
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = 20;
    NSString *faceUrl = _circleModel.face;
    if (![faceUrl hasPrefix:@"http"]) {
        faceUrl = [G_IMAGE_ADDRESS stringByAppendingString:faceUrl ?: @""];
    }
    [headImg setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:[UIImage imageNamed:@"s21.png"]];
    [headerView addSubview:headImg];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    //time
    _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width - 10 - 150, 21, 150, 18)];
    [_timeLab setFont:[UIFont systemFontOfSize:14]];
    [_timeLab setBackgroundColor:[UIColor clearColor]];
    [_timeLab setTextColor:CreateColor(196, 196, 196)];
    [_timeLab setTextAlignment:2];
    [_timeLab setText:[NSString calculateTimeDistance:_circleModel.dateline]];
    [headerView addSubview:_timeLab];
    
    //name
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 100, 20)];
    [nameLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
    [nameLab setFont:[UIFont systemFontOfSize:16]];
    [nameLab setBackgroundColor:[UIColor clearColor]];
    [nameLab setText:_circleModel.author];
    [headerView addSubview:nameLab];
    
    NSArray *images = [_circleModel.picture_thumb componentsSeparatedByString:@"|"];
    //提示
    UILabel *tipLab = [[UILabel alloc] initWithFrame:_circleModel.tipRect];
    [tipLab setTextColor:[UIColor darkGrayColor]];
    [tipLab setFont:[UIFont systemFontOfSize:13]];
    [tipLab setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:tipLab];
    if (_circleModel.album_name && [_circleModel.album_name length] > 0) {
        [tipLab setText:[NSString stringWithFormat:@"上传%ld张照片到《%@》",(long)images.count,_circleModel.album_name]];
    }else {
        [tipLab setText:[NSString stringWithFormat:@"上传%ld张照片到班级圈",(long)images.count]];
    }
    
    //图片
    if (_circleModel.imagesRect.size.height > 0) {
        //imageViews
        ResuableImageViews *resumeImageView = [[ResuableImageViews alloc] initWithFrame:_circleModel.imagesRect];
        resumeImageView.delegate = self;
        [headerView addSubview:resumeImageView];
        [resumeImageView setType:_circleModel.type];
        [resumeImageView setImages:images];
        if (images.count>5) {
            [resumeImageView.morePicture setHidden:NO];
            
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            CGFloat wei = roundf((winSize.width - 10 * 5) / 4);
            
            [resumeImageView.morePicture setFrame:CGRectMake(_circleModel.imagesRect.origin.x+_circleModel.imagesRect.size.width-wei-10,_circleModel.imagesRect.size.height-30, wei, 28)];
        }
    }
    
    if (_circleModel.contentRect.size.height > 0) {
        UILabel *contentLab = [[UILabel alloc] initWithFrame:_circleModel.contentRect];
        [contentLab setNumberOfLines:0];
        [contentLab setTextColor:[UIColor blackColor]];
        [contentLab setFont:[UIFont systemFontOfSize:16]];
        [contentLab setText:_circleModel.message];
        [headerView addSubview:contentLab];
    }
    
    //@对象
    if (_circleModel.attentionRect.size.height > 0) {
        UILabel *attentionLab = [[UILabel alloc] initWithFrame:_circleModel.attentionRect];
        [attentionLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [attentionLab setFont:[UIFont systemFontOfSize:16]];
        [attentionLab setNumberOfLines:0];
        [headerView addSubview:attentionLab];
        NSMutableArray *attentions = [NSMutableArray array];
        for (NSDictionary *dic in _circleModel.attention) {
            [attentions addObject:[NSString stringWithFormat:@"@%@",[dic.allValues firstObject]]];
        }
        attentionLab.text = [attentions componentsJoinedByString:@" "];
    }
    
    //多少人看过
    _views=[[UILabel alloc]initWithFrame:CGRectMake(headImg.frame.origin.x, _circleModel.butYori,120 , 24)];
    _views.textColor=CreateColor(147,146,142);
    _views.text=[NSString stringWithFormat:@"%d人看过",[_circleModel.views intValue]];
    _views.font=[UIFont systemFontOfSize:14];
    [headerView addSubview:_views];
    
    //buttons
    _digistBut = [[ResuableButton alloc] initWithFrame:CGRectMake(winSize.width - (60 + 10) * 2, _circleModel.butYori, 60, 24)];
    [_digistBut setCommentNumber:[_circleModel.digg_count stringValue]];
    BOOL hasDig = ([_circleModel.have_digg integerValue] == 1);
    [_digistBut setLeftImage:[UIImage imageNamed:hasDig ? @"s29_1.png" : @"s29.png"]];
    _digistBut.delegate = self;
    [headerView addSubview:_digistBut];
    
    _commentBut = [[ResuableButton alloc] initWithFrame:CGRectMake(winSize.width - 60 - 10, _circleModel.butYori, 60, 24)];
    [_commentBut setLeftImage:[UIImage imageNamed:@"s30.png"]];
    _commentBut.delegate = self;
    [_commentBut setCommentNumber:[_circleModel.replies stringValue]];
    [headerView addSubview:_commentBut];
    
    //点赞人员头像
    if (_circleModel.diggRect.size.height > 0) {
        ResuableHeadImages *_resumeHeaderImgs = [[ResuableHeadImages alloc] initWithFrame:CGRectMake(0, _circleModel.diggRect.origin.y, winSize.width, _circleModel.diggRect.size.height + 10)];
        [_resumeHeaderImgs setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
        [_resumeHeaderImgs setImages:_circleModel.digg];
        [headerView addSubview:_resumeHeaderImgs];
        [self resetSubViewFrames:_resumeHeaderImgs.subviews];
        
        [headerView setFrame:CGRectMake(0, 0, winSize.width, _circleModel.diggRect.size.height + _circleModel.diggRect.origin.y + 30 + 10)];
    }
    else
    {
        [headerView setFrame:CGRectMake(0, 0, winSize.width, _circleModel.butYori + 24 + 5 + 30)];
    }
    
    //bottom
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 30, winSize.width, 30)];
    [subView setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
    
    //line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 0.5)];
    [lineView setBackgroundColor:CreateColor(215, 217, 218)];
    [subView addSubview:lineView];
    
    //button
    UIImageView *heartImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    [heartImg setImage:[UIImage imageNamed:@"s32.png"]];
    _heartImg=heartImg;
    [subView addSubview:heartImg];
    
    //tip
    UILabel *subLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, winSize.width - 35, 20)];
    _numLab = subLab;
    [subLab setFont:[UIFont systemFontOfSize:16]];
    [subLab setTextColor:CreateColor(160, 160, 160)];
    [subLab setBackgroundColor:[UIColor clearColor]];
    [subLab setText:[NSString stringWithFormat:@"查看%@条评论",[_circleModel.replies stringValue]]];
    [subView addSubview:subLab];
    [headerView addSubview:subView];
    
    BOOL showNum = [_circleModel.replies intValue] > 0;
    [_numLab setHidden:!showNum];
    [_heartImg setHidden:!showNum];
    
    return headerView;
}

#pragma mark - 动态已被删除，返回上一层
- (void)unsavedDynamic
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteThisCircleDetail)]) {
        [_delegate deleteThisCircleDetail];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 删除
- (void)deleteClassCircle
{
    if (self.httpOperation) {
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if ([manager.userInfo.userid longLongValue] != [_circleModel.authorid longLongValue]) {
        [self.view makeToast:@"家长只能删除由自己发布的班级圈" duration:1.0 position:@"center"];
        return;
    }
    
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    if (!_circleModel) {
        return;
    }
    
    _tableView.userInteractionEnabled = NO;
    _inputBar.userInteractionEnabled = NO;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.userInteractionEnabled = NO;
    [self.view.window makeToastActivity];
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteDynamic"];
    [param setObject:_circleModel.tid forKey:@"tid"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:@"0" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf deleteFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf deleteFinish:NO Data:nil];
    }];
}

- (void)deleteFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = NO;
    _inputBar.userInteractionEnabled = NO;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.userInteractionEnabled = NO;
    [self.view.window hideToastActivity];
    if (suc) {
        if (_delegate && [_delegate respondsToSelector:@selector(deleteThisCircleDetail)]) {
            [_delegate deleteThisCircleDetail];
        }
        else
        {
            [self.view.window makeToast:@"成功删除该条记录" duration:1.0 position:@"center"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 点赞
- (void)diggRequest:(NSString *)tid
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    _tableView.userInteractionEnabled = NO;
    _inputBar.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"digg"];
    [param setObject:tid forKey:@"tid"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:@"0" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
    [param setObject:manager.userInfo.uname forKey:@"user_name"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self.view.window makeToastActivity];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf diggComplete:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf diggComplete:NO Data:nil];
    }];
}

- (void)diggComplete:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    _inputBar.userInteractionEnabled = YES;
    [self.view.window hideToastActivity];
    if (suc) {
        _circleModel.have_digg = [NSNumber numberWithInt:1];
        DiggItem *item = [[DiggItem alloc] init];
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        item.face = user.face;
        item.is_teacher = @"0";
        item.name = user.uname;
        item.userid = user.userid;
        if (!_circleModel.digg) {
            [_circleModel setDigg:(NSMutableArray<DiggItem> *)[NSMutableArray array]];
        }
        [_circleModel.digg addObject:item];
        _circleModel.digg_count = [NSNumber numberWithInteger:_circleModel.digg_count.integerValue + 1];
        [_circleModel calculateGroupCircleRects];
        
        [_tableView setTableHeaderView:[self createTableHeaderView]];
        [_tableView reloadData];
        if (_delegate && [_delegate respondsToSelector:@selector(changeReplyDetail)]) {
            [_delegate changeReplyDetail];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 回复
- (void)replyContent:(NSString *)content
{
    if (self.httpOperation) {
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    if (manager.userInfo.home_comment_open.integerValue != 1) {
        [self.view makeToast:@"暂无回复班级圈的权限" duration:1.0 position:@"center"];
        return;
    }
    
    if (manager.networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    _content = content;
    _tableView.userInteractionEnabled = NO;
    _inputBar.userInteractionEnabled = NO;

    //
    NSMutableDictionary *param = [manager requestinitParamsWith:@"comment"];
    [param setObject:_circleModel.tid forKey:@"tid"];
    [param setObject:@"0" forKey:@"is_teacher"];    //0-家长,1-老师 2-园长
    [param setObject:@"" forKey:@"subject"];
    [param setObject:manager.userInfo.userid forKey:@"authorid"];
    [param setObject:manager.userInfo.uname forKey:@"author"];
    [param setObject:content forKey:@"message"];
    if (_indexPath) {
        ReplyItem *item = self.dataSource[_indexPath.row];
        [param setObject:item.send_id forKey:@"reply_id"];
        [param setObject:item.is_teacher forKey:@"reply_is_teacher"];
        [param setObject:item.name forKey:@"reply_name"];
    }
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];

    __weak __typeof(self)weakSelf = self;
    [self.view.window makeToastActivity];
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf finishReplyContent:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf finishReplyContent:NO Data:nil];
    }];
}

- (void)finishReplyContent:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    _inputBar.userInteractionEnabled = YES;
    [self.view.window hideToastActivity];
    if (suc) {
        NSString *ret_data = [result valueForKey:@"ret_data"];  //pid
        
        DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
        ReplyItem *newItem = [[ReplyItem alloc] init];
        newItem.send_id = user.userid;
        newItem.pid = ret_data;
        newItem.send_name = user.uname;
        newItem.name = (user.relation && [user.relation length] > 0) ? [NSString stringWithFormat:@"%@的%@",user.realname,user.relation] : user.realname;
        newItem.face = user.face;
        newItem.is_teacher = @"0";
        newItem.replay_message = _content;
        newItem.tid = _circleModel.tid;
        if (_indexPath) {
            ReplyItem *item = self.dataSource[_indexPath.row];
            newItem.reply_id = item.send_id;
            newItem.reply_name = item.name;
            newItem.reply_is_teacher = item.is_teacher;
        }
        [newItem calculateItemRect:[UIScreen mainScreen].bounds.size.width - 60 Font:[UIFont systemFontOfSize:16]];
        if (!_circleModel.reply) {
            [_circleModel setReply:(NSMutableArray<ReplyItem> *)[NSMutableArray array]];
            self.dataSource = _circleModel.reply;
        }
        
        [_circleModel.reply insertObject:newItem atIndex:0];
        _circleModel.replies = [NSNumber numberWithInteger:[_circleModel.replies integerValue] + 1];
        [_commentBut setCommentNumber:_circleModel.replies.stringValue];
        [_numLab setText:[NSString stringWithFormat:@"查看%@条评论",[_circleModel.replies stringValue]]];
        if([_circleModel.replies intValue]>0){
            [_numLab setHidden:NO];
            [_heartImg setHidden:NO];
        }
        
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
        //上一页面修改
        [_circleModel calculateGroupCircleRects];
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeReplyDetail)]) {
            [_delegate changeReplyDetail];
        }
        
        _indexPath = nil;
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 网络请求结束
/**
 *	@brief	数据请求结果
 *
 *	@param 	success 	yes－成功
 *	@param 	result 	服务器返回数据
 */
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (!ret_data || [ret_data isKindOfClass:[NSNull class]] || ([ret_data isKindOfClass:[NSDictionary class]] && [ret_data allKeys].count == 0)) {
            [self.view makeToast:@"该条动态已被删除" duration:1.0 position:@"center"];
            [self performSelector:@selector(unsavedDynamic) withObject:nil afterDelay:1.0];
            return;
        }
        
        _inputBar.hidden = NO;
        ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.hidden = NO;
        
        NSError *error;
        ClassCircleModel *circle = [[ClassCircleModel alloc] initWithDictionary:ret_data error:&error];
        if (error) {
            NSLog(@"%@",error.description);
        }
        else
        {
            for (ReplyItem *item in circle.reply) {
                [item calculateItemRect:[UIScreen mainScreen].bounds.size.width - 60 Font:[UIFont systemFontOfSize:16]];
            }
            [circle calculateGroupCircleRects];
        }
        
        NSString *viewsCount = [ret_data valueForKey:@"views"];
        viewsCount = (!viewsCount || [viewsCount isKindOfClass:[NSNull class]]) ? @"0" : viewsCount;
        [_circleModel setViews:viewsCount];
        if (!_circleModel) {
            self.circleModel = [[ClassCircleModel alloc] init];
        }
        BOOL same = [circle.replies integerValue] == [_circleModel.replies integerValue];
        [_circleModel reflectDataFromOtherObject:circle];
        if (!same) {
            _circleModel.reply = circle.reply;
            if (_delegate && [_delegate respondsToSelector:@selector(changeReplyDetail)]) {
                [_delegate changeReplyDetail];
            }
        }
        
        self.dataSource = _circleModel.reply;
        _tableView.tableHeaderView = [self createTableHeaderView];
        [_tableView reloadData];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - ResuableButtonDelegate
- (void)touchResuableBut:(ResuableButton *)button
{
    if (button == _digistBut) {
        if ([_circleModel.have_digg integerValue] == 1) {
            [self.view makeToast:@"不可重复点赞" duration:1.0 position:@"center"];
        }
        else
        {
            [self diggRequest:_circleModel.tid];
        }
    }
    else
    {
        _indexPath = nil;
        if (!_inputBar.textField.isFirstResponder) {
            [_inputBar.textField becomeFirstResponder];
        }
        UIColor *color = [UIColor whiteColor];
        _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
    }
}

#pragma mark - InputBarDelegate
- (void)changeViewHeight:(CGFloat)height
{
    CGRect barRect = _inputBar.frame;
    CGRect tabRect = _tableView.frame;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    [_inputBar setFrame:CGRectMake(barRect.origin.x, winSize.height - height - barRect.size.height - 64, barRect.size.width, barRect.size.height)];
    [_tableView setFrame:CGRectMake(tabRect.origin.x, -height, tabRect.size.width, tabRect.size.height)];
}

- (void)sendComment:(NSString *)content
{
    if (content && ([content length] >= 1 && [content length] <= 200)) {
        NSString *newStr = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([newStr length] == 0) {
            [self.view.window makeToast:@"不能全部输入空字符串" duration:1.0 position:@"center"];
            
        }
        else
        {
            [self replyContent:content];
            [_inputBar.textField resignFirstResponder];
            [_inputBar.textField setText:@""];
            UIColor *color = [UIColor whiteColor];
            _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
        }
    }
    else
    {
        [self.view.window makeToast:@"请输入1-200的文本长度内容" duration:1.0 position:@"center"];
    }
}

#pragma mark - 视频播放
/**
 *	@brief	视频播放
 *
 *	@param 	filePath 	视频路径
 */
- (void)playVideo:(NSString *)filePath
{
    if (![filePath hasPrefix:@"http"]) {
        filePath = [G_IMAGE_ADDRESS stringByAppendingString:filePath ?: @""];
    }
    NSURL *movieURL = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.movieController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    [self.movieController prepareToPlay];
    [self.view addSubview:self.movieController.view];//设置写在添加之后   // 这里是addSubView
    self.movieController.shouldAutoplay=YES;
    [self.movieController setControlStyle:MPMovieControlStyleDefault];
    self.movieController.scalingMode = MPMovieScalingModeAspectFill;
    [self.movieController setFullscreen:YES];
    [self.movieController.view setFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}

- (void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}

#pragma mark - ColleagueImageViewDelegate
- (void)clickedImageWithIndex:(NSInteger)index
{
    if (index >= 100) {
        return;
    }
    //检测视频
    NSArray *pics = [_circleModel.picture componentsSeparatedByString:@"|"];
    NSArray *thumbs = [_circleModel.picture_thumb componentsSeparatedByString:@"|"];
    
    //图片
    _browserPhotos = [NSMutableArray array];
    for (int i = 0; i < pics.count; i++) {
        NSString *path = pics[i];
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
        }
        MWPhoto *photo = nil;
        NSString *name = [path lastPathComponent];
        if ([[[name pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
            NSString *tmpThumb = thumbs[i];
            if ([[[tmpThumb pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
                photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:path]]];
            }
            else
            {
                if (![tmpThumb hasPrefix:@"http"]) {
                    tmpThumb = [G_IMAGE_ADDRESS stringByAppendingString:tmpThumb ?: @""];
                }
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:tmpThumb]];
            }
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            NSURL *url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo = [MWPhoto photoWithURL:url];
        }
        [_browserPhotos addObject:photo];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:index];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)clickedMorePicture
{
    [self clickedImageWithIndex:0];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteClassCircle];
    }
    else if (buttonIndex == 1)
    {
        if (![DJTShareView isCanShareToOtherPlatform]) {
            [self.view.window makeToast:SHARE_TIP_INFO duration:1.0 position:@"center"];
            return;
        }
        
        DJTShareView *shareView = [[DJTShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [shareView setDelegate:self];
        [shareView showInView:self.view.window];
        
    }
}

#pragma mark - DynamicDetailCellDelegate
- (void)beginDelete:(UITableViewCell *)cell
{
    _delIndexPath = [_tableView indexPathForCell:cell];
    [self deleteContent:_delIndexPath];
}

#pragma mark - 删除评论
- (void)deleteContent:(NSIndexPath *)indexPath
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    ReplyItem *item = _circleModel.reply[indexPath.row];
    if (![manager.userInfo.userid isEqualToString:item.send_id]) {
        [self.view makeToast:@"您只能删除由自己发布的评论" duration:1.0 position:@"center"];
        return;
    }
    
    [self scrollViewWillBeginDragging:_tableView];
    
    _tableView.userInteractionEnabled = NO;
    _inputBar.userInteractionEnabled = NO;
    [self.view.window makeToastActivity];
    //
    
    NSMutableDictionary *param = [manager requestinitParamsWith:@"deleteDynamicReplies"];
    [param setObject:manager.userInfo.userid forKey:@"userid"];
    [param setObject:@"0" forKey:@"is_teacher"];    //0-家长,1-老师 2-园长
    
    [param setObject:(item.pid && ![item.pid isKindOfClass:[NSNull class]]) ? item.pid : @"" forKey:@"pid"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    __weak __typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"dynamic"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf deleteContentFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf deleteContentFinish:NO Data:nil];
    }];
}

- (void)deleteContentFinish:(BOOL)suc Data:(id)result
{
    self.httpOperation = nil;
    _tableView.userInteractionEnabled = YES;
    _inputBar.userInteractionEnabled = YES;
    
    [self.view.window hideToastActivity];
    
    if (suc) {
        [_circleModel.reply removeObjectAtIndex:_delIndexPath.row];
        _circleModel.replies = [NSNumber numberWithInteger:MAX([_circleModel.replies integerValue] - 1, 0)];
        [_commentBut setCommentNumber:_circleModel.replies.stringValue];
        [_numLab setText:[NSString stringWithFormat:@"查看%@条评论",[_circleModel.replies stringValue]]];
        BOOL showNum = [_circleModel.replies intValue] > 0;
        [_numLab setHidden:!showNum];
        [_heartImg setHidden:!showNum];
        [_tableView deleteRowsAtIndexPaths:@[_delIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //上一页面修改
        [_circleModel calculateGroupCircleRects];
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeReplyDetail)]) {
            [_delegate changeReplyDetail];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - DJTShareViewDelegate
- (void)shareViewTo:(NSInteger)index
{
    NSString *str = [NSString stringWithFormat:@"http://wap.goonbaby.com/dynamic_share/t%@_b%@_f1.htm",_circleModel.tid,[DJTGlobalManager shareInstance].userInfo.userid];
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            
            NSString *shareType = nil;
            if (index == 0) {
                [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatSessionData.url = str;
                shareType = UMShareToWechatSession;
            }
            else if (index == 1)
            {
                [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = str;
                shareType = UMShareToWechatTimeline;
            }
            else if (index == 2)
            {
                [UMSocialData defaultData].extConfig.qqData.url = str;
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                shareType = UMShareToQQ;
            }
            else
            {
                [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeMusic url:str];
                shareType = UMShareToSina;
            }
            
            NSString *lastStr = str;
            [[UMSocialControllerService defaultControllerService] setShareText:lastStr shareImage:nil socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:shareType].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        }
            break;
        case 4:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        case 5:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = str;
        }
            break;
        case 6:
        {
            //[_webView reload];
            NSLog(@"%@",str);
        }
            break;
        default:
            break;
    }
}

#pragma mark - UMSocialUIDelegate
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        NSLog(@"分享成功！");
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *dynamicDetailCellId = @"dynamicDetailCell";
    DynamicDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:dynamicDetailCellId];
    if (cell == nil) {
        cell = [[DynamicDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dynamicDetailCellId];
        cell.delegate = self;
    }
    
    [cell resetDynamicDetailData:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyItem *item = self.dataSource[indexPath.row];
    return MAX(item.itemSize.height, 10) + 40;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    if (!_inputBar.textField.isFirstResponder) {
        [_inputBar.textField becomeFirstResponder];
    }
    ReplyItem *item = [self.dataSource objectAtIndex:indexPath.row];
    if ([item.send_id isEqualToString:[DJTGlobalManager shareInstance].userInfo.userid]) {
        //是自己发的消息
        _indexPath = nil;
        UIColor *color = [UIColor whiteColor];
        _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
    }
    else
    {
        UIColor *color = [UIColor whiteColor];
        _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"回复%@:",item.name] attributes:@{NSForegroundColorAttributeName: color}];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _indexPath = nil;
    if (_inputBar.textField.isFirstResponder) {
        [_inputBar.textField resignFirstResponder];
        _inputBar.textField.text = @"";
        UIColor *color = [UIColor whiteColor];
        _inputBar.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"说点什么..." attributes:@{NSForegroundColorAttributeName: color}];
    }
}

@end
