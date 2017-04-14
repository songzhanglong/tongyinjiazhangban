//
//  DynamicViewCell.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DynamicViewCell.h"
#import "ClassCircleModel.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import "ResuableButton.h"
#import "ResuableHeadImages.h"
#import "ClassHeaderView.h"

#pragma mark - 回复

@protocol ResuableReplysDelegate <NSObject>

@optional
- (void)selectReplyIndex:(NSInteger)index;
- (void)selectReplyId:(NSString *)userId;
- (void)selectAllComments;

@end

@interface ResuableReplys : UIView

@property (nonatomic,assign)id<ResuableReplysDelegate> delegate;

- (void)setImages:(NSArray *)items Rects:(NSArray *)rects Count:(long)replies;

@end

@implementation ResuableReplys
{
    UIView *_selectedView;
    UILabel *_tipLabel;
    UIButton *_tipButton;
    UIView *_lineView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        //line
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        _lineView = lineView;
        [lineView setBackgroundColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [lineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:lineView];
        
        //button
        _tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tipButton setFrame:CGRectMake(0, 5, 20, 20)];
        [_tipButton setImage:[UIImage imageNamed:@"s32.png"] forState:UIControlStateNormal];
        [_tipButton addTarget:self action:@selector(gotoAllComment:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_tipButton];
        
        //tip
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 200, 20)];
        [_tipLabel setFont:[UIFont systemFontOfSize:16]];
        [_tipLabel setTextColor:CreateColor(91, 89, 89)];
        [self addSubview:_tipLabel];
        
        //最多3个，多了不显示
        for (NSInteger i = 0; i < 3; i++) {
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
            [lable setTag:i + 1];
            [lable setTextColor:CreateColor(91, 89, 89)];
            [lable setFont:[UIFont systemFontOfSize:16]];
            [lable setNumberOfLines:0];
            lable.lineBreakMode = NSLineBreakByWordWrapping;
            [self addSubview:lable];
        }
    }
    return self;
}

- (void)gotoAllComment:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectAllComments)]) {
        [_delegate selectAllComments];
    }
}

- (void)setImages:(NSArray *)items Rects:(NSArray *)rects Count:(long)replies
{
    NSInteger count = items.count;
    BOOL hidden = (count <= 0);
    _tipLabel.hidden = hidden;
    _tipButton.hidden = hidden;
    _lineView.hidden = hidden;
    
    [_tipLabel setText:[NSString stringWithFormat:@"查看%ld条评论",(long)replies]];
    
    for (int i = 0; i < 3; i++) {
        UILabel *lable = (UILabel *)[self viewWithTag:i + 1];
        if (i >= count) {
            lable.hidden = YES;
            [lable setFrame:CGRectZero];
        }
        else
        {
            NSAttributedString *attStr = [items[i] generalHTMLStr];
            [lable setAttributedText:attStr];
            [lable setFrame:CGRectFromString(rects[i])];
            lable.hidden = NO;
        }
    }
}

@end

#pragma mark - cell
@interface DynamicViewCell()<ResuableButtonDelegate,ColleagueImageViewDelegate,ClassHeaderViewDelegate>

@end

@implementation DynamicViewCell
{
    UILabel *_topLab,*_tipLab,*_contentLab,*_attentionLab,*_timeLab;
    
    ResuableImageViews *_resumeImageView;
    ResuableHeadImages *_resumeHeaderImgs;
    ResuableButton *_digistBut,*_commentBut;
    ResuableReplys *_replyView;
    ClassHeaderView *_headerView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        //前置层
        UIView *backView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        backView.opaque = YES;
        [self.contentView addSubview:backView];
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        //top
        _topLab = [[UILabel alloc] initWithFrame:CGRectMake(0, backView.frame.size.height - 18, winSize.width, 18)];
        [_topLab setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_topLab setBackgroundColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]];
        [backView addSubview:_topLab];
        //header
        _headerView = [[ClassHeaderView alloc]initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width - 90, 40)];
        _headerView.delegate  = self;
        [backView addSubview:_headerView];
        
        //time
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width - 10 - 150, 21, 150, 18)];
        [_timeLab setFont:[UIFont systemFontOfSize:14]];
        _timeLab.opaque = YES;
        [_timeLab setTextColor:CreateColor(196, 196, 196)];
        [_timeLab setTextAlignment:2];
        [backView addSubview:_timeLab];
        
        //tip
        _tipLab = [[UILabel alloc] initWithFrame:CGRectZero];
        [_tipLab setTextColor:CreateColor(160, 160, 160)];
        [_tipLab setFont:[UIFont systemFontOfSize:13]];
        [backView addSubview:_tipLab];
        
        //imageViews
        _resumeImageView = [[ResuableImageViews alloc] initWithFrame:CGRectZero];
        _resumeImageView.delegate = self;
        [backView addSubview:_resumeImageView];
        
        //heads
        _resumeHeaderImgs = [[ResuableHeadImages alloc] initWithFrame:CGRectZero];
        _resumeHeaderImgs.delegate = self;
        [backView addSubview:_resumeHeaderImgs];
        
        //content
        _contentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentLab setNumberOfLines:0];
        [_contentLab setTextColor:[UIColor blackColor]];
        [_contentLab setFont:[UIFont systemFontOfSize:16]];
        [backView addSubview:_contentLab];
        
        //attention
        _attentionLab = [[UILabel alloc] initWithFrame:CGRectZero];
        [_attentionLab setTextColor:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0]];
        [_attentionLab setFont:[UIFont systemFontOfSize:16]];
        _attentionLab.numberOfLines = 0;
        [backView addSubview:_attentionLab];
        
        //buttons
        _digistBut = [[ResuableButton alloc] initWithFrame:CGRectMake(winSize.width - (60 + 10) * 2, 0, 60, 24)];
        [_digistBut setCommentNumber:[NSString stringWithFormat:@"%ld",(long)arc4random() % 1000]];
        _digistBut.delegate = self;
        [backView addSubview:_digistBut];
        
        _commentBut = [[ResuableButton alloc] initWithFrame:CGRectMake(winSize.width - 60 - 10, 0, 60, 24)];
        [_commentBut setLeftImage:[UIImage imageNamed:@"s30.png"]];
        _commentBut.delegate = self;
        [_commentBut setCommentNumber:[NSString stringWithFormat:@"%ld",(long)arc4random() % 1000]];
        [backView addSubview:_commentBut];
        
        //reply
        _replyView = [[ResuableReplys alloc] initWithFrame:CGRectZero];
        [backView addSubview:_replyView];
    }
    
    return self;
}

- (void)resetClassGroupData:(id)object
{
    ClassCircleModel *model = (ClassCircleModel *)object;
    
    //头像
    NSString *faceUrl = model.face;
    if (![faceUrl hasPrefix:@"http"]) {
        faceUrl = [G_IMAGE_ADDRESS stringByAppendingString:faceUrl ?: @""];
    }
    [_headerView.headImg setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    
    //时间计算
    [_timeLab setText:[NSString calculateTimeDistance:model.dateline]];
    
    //姓名
    NSString *name = (model.name.length > 0) ? model.name : ((model.author.length > 0) ? model.author : @"");
    NSString *str = [NSString stringWithFormat:@"%@ ",name];
    NSRange range = [str rangeOfString:name];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attStr addAttribute:NSForegroundColorAttributeName value:CreateColor(68, 138, 167) range:range];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    [_headerView.nameLab setAttributedText:attStr];
    
    NSArray *images = [model.picture_thumb componentsSeparatedByString:@"|"];
    //提示
    [_tipLab setFrame:model.tipRect];
    if (model.album_name && [model.album_name length] > 0) {
        [_tipLab setText:[NSString stringWithFormat:@"上传%ld张照片到《%@》",(long)images.count,model.album_name]];
    }else {
        [_tipLab setText:[NSString stringWithFormat:@"上传%ld张照片到班级圈",(long)images.count]];
    }

    //图片
    if (model.imagesRect.size.height > 0) {
        [_resumeImageView setFrame:model.imagesRect];
        [_resumeImageView setType:model.type];
        [_resumeImageView setImages:images];
        [_resumeImageView setHidden:NO];
    }
    else
    {
        [_resumeImageView setHidden:YES];
    }
    
    //内容
    if (model.contentRect.size.height > 0) {
        [_contentLab setFrame:CGRectMake(model.contentRect.origin.x, model.contentRect.origin.y, model.contentRect.size.width, MIN(model.contentRect.size.height, 60))];
        [_contentLab setText:model.message];
        [_contentLab setHidden:NO];
    }
    else
    {
        [_contentLab setHidden:YES];
    }
    
    CGFloat diffHei = (model.contentRect.size.height - 60);
    if (diffHei < 0) {
        diffHei = 0;
    }
    
    //@对象
    if (model.attentionRect.size.height > 0) {
        [_attentionLab setHidden:NO];
        [_attentionLab setFrame:CGRectMake(model.attentionRect.origin.x, model.attentionRect.origin.y - diffHei, model.attentionRect.size.width, model.attentionRect.size.height)];
        NSMutableArray *attentions = [NSMutableArray array];
        for (NSDictionary *dic in model.attention) {
            [attentions addObject:[NSString stringWithFormat:@"@%@",[dic.allValues firstObject]]];
        }
        _attentionLab.text = [attentions componentsJoinedByString:@" "];
    }
    else
    {
        [_attentionLab setHidden:YES];
    }
    
    //点赞
    CGRect digRec = _digistBut.frame;
    CGRect comRec = _commentBut.frame;
    [_digistBut setFrame:CGRectMake(digRec.origin.x, model.butYori - diffHei, digRec.size.width, digRec.size.height)];
    [_digistBut setCommentNumber:[model.digg_count stringValue]];
    BOOL hasDig = ([model.have_digg integerValue] == 1);
    [_digistBut setLeftImage:[UIImage imageNamed:hasDig ? @"s29_1.png" : @"s29.png"]];
    
    //评论
    [_commentBut setFrame:CGRectMake(comRec.origin.x, model.butYori - diffHei, comRec.size.width, comRec.size.height)];
    [_commentBut setCommentNumber:[model.replies stringValue]];
    
    //点赞头像
    if (model.diggRect.size.height > 0) {
        [_resumeHeaderImgs setImages:model.digg];
        [_resumeHeaderImgs setFrame:CGRectMake(model.diggRect.origin.x, model.diggRect.origin.y - diffHei, model.diggRect.size.width, model.diggRect.size.height)];
        [_resumeHeaderImgs setHidden:NO];
    }
    else
    {
        [_resumeHeaderImgs setHidden:YES];
    }
    
    //回复
    if (model.replyBackRect.size.height > 0) {
        [_replyView setImages:model.reply Rects:model.replyRects Count:[model.replies longValue]];
        [_replyView setFrame:CGRectMake(model.replyBackRect.origin.x, model.replyBackRect.origin.y - diffHei, model.replyBackRect.size.width, model.replyBackRect.size.height)];
        [_replyView setHidden:NO];
    }
    else
    {
        [_replyView setHidden:YES];
    }
}

- (void)resetTimerContent:(NSString *)timer
{
    [_timeLab setText:timer];
}

#pragma mark - ClassHeaderViewDelegate
- (void)touchHeadView:(ClassHeaderView *)click{
    if (_delegate && [_delegate respondsToSelector:@selector(selectListByPeople:)]) {
        [_delegate selectListByPeople:self];
    }
}

#pragma mark - ResuableButtonDelegate
- (void)touchResuableBut:(ResuableButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(diggAndCommentCell:At:)]) {
        [_delegate diggAndCommentCell:self At:(button == _digistBut) ? 0 : 1];
    }
}

#pragma mark - ColleagueImageViewDelegate
-(void)clickedImageWithIndex:(NSInteger)index
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchImageCell:At:)]) {
        [_delegate touchImageCell:self At:index];
    }
}

- (void)clickedMorePicture
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchImageCell:At:)]) {
        [_delegate touchImageCell:self At:0];
    }
}

@end
