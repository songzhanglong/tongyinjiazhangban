//
//  NotificationCommentCell.m
//  NewTeacher
//
//  Created by songzhanglong on 15/2/25.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "NotificationCommentCell2.h"
#import "NotificationCommentModel.h"
#import "DJTGlobalManager.h"

@interface NotificationCommentCell2 ()

@end

@implementation NotificationCommentCell2
{
    UILabel *_contentLab;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        self.contentView.backgroundColor = [UIColor whiteColor];
        //content
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, winSize.width - 20, 10)];
        [self.contentView addSubview:_contentLab];
    }
    return self;
}

- (void)resetNotificationDetailData:(id)object
{
    NotificationCommentItem *item = (NotificationCommentItem *)object;
    CGRect conRec = _contentLab.frame;
    [_contentLab setFrame:CGRectMake(conRec.origin.x, conRec.origin.y, conRec.size.width, item.conSize.height)];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:item.lastText];
    [attriString addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, item.lastText.length)];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, item.lastText.length)];
    NSRange range = [item.lastText rangeOfString:item.author_name];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0] range:range];
    if (item.reply_name) {
        range = [item.lastText rangeOfString:[NSString stringWithFormat:@"%@:",item.reply_name]];
        if (range.location != NSNotFound) {
            [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:68.0 / 255 green:138.0 / 255 blue:167.0 / 255 alpha:1.0] range:range];
        }
    }
    _contentLab.numberOfLines=0;
    _contentLab.attributedText = attriString;
    _contentLab.lineBreakMode = NSLineBreakByWordWrapping;
    
}

@end
