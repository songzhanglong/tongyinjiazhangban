//
//  NotificationCommentCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/2/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationCommentCell.h"
#import "NotificationCommentModel.h"

@interface NotificationCommentCell ()

@end

@implementation NotificationCommentCell
{
    UILabel *_contentLab;
    UIButton *_showButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 35, 18)];
        [_tipLab setFont:[UIFont systemFontOfSize:14]];
        [_tipLab setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:_tipLab];
        
        //content
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(45, 13, winSize.width - 55, 10)];
        [_contentLab setNumberOfLines:0];
        [_contentLab setTextColor:CreateColor(68, 138, 167)];
        [_contentLab setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:_contentLab];
        
        _showButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 100, self.contentView.frame.size.height - 25, 80, 20)];
        [_showButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
        [_showButton setTitle:@"显示全部∨" forState:UIControlStateNormal];
        [_showButton setTitle:@"收起∧" forState:UIControlStateSelected];
        [_showButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_showButton addTarget:self action:@selector(isShowAction:) forControlEvents:UIControlEventTouchUpInside];
        [_showButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_showButton];
    }
    return self;
}

- (void)isShowAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(expandAndDrawback:)]) {
        [_delegate expandAndDrawback:self];
    }
}

- (void)resetNotificationDetailData:(id)object
{
    ObjectModel *item = (ObjectModel *)object;
    CGRect conRec = _contentLab.frame;
    [_contentLab setText:item.content];
    if (item.showAll || item.contentSize.height < 34) {
        _showButton.hidden = YES;
        [_contentLab setFrame:CGRectMake(conRec.origin.x, conRec.origin.y, conRec.size.width, item.contentSize.height)];
    }
    else
    {
        _showButton.hidden = NO;
        _showButton.selected = item.isAllShow;
        [_contentLab setFrame:CGRectMake(conRec.origin.x, conRec.origin.y, conRec.size.width, item.isAllShow ? item.contentSize.height : 34)];
    }
}

@end
