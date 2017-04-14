//
//  SelectMileageTableViewCell.m
//  NewTeacher
//
//  Created by zhangxs on 16/3/30.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectMileageTableViewCell.h"
#import "GrowAlbumItem.h"
#import "UIImage+Caption.h"

@implementation SelectMileageTableViewCell
{
    UIImageView *_imgView;
    UILabel *_titleLabel;
    UILabel *_numLabel;
    UILabel *_contLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *_bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 65)];
        [_bgView setBackgroundColor:[UIColor whiteColor]];
        [_bgView.layer setMasksToBounds:YES];
        [_bgView.layer setCornerRadius:3];
        [self.contentView addSubview:_bgView];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        [_imgView setContentMode:UIViewContentModeScaleAspectFill];
        [_imgView setClipsToBounds:YES];
        [_imgView setBackgroundColor:BACKGROUND_COLOR];
        [_bgView addSubview:_imgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 10, 10, _bgView.frameWidth - _imgView.frameRight - 20, 16)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_bgView addSubview:_titleLabel];
        
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 10, _titleLabel.frameBottom + 2, _bgView.frameWidth - _imgView.frameRight - 20, 15)];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setFont:[UIFont systemFontOfSize:10]];
        [_numLabel setTextColor:CreateColor(47, 188, 94)];
        [_bgView addSubview:_numLabel];
        
        _contLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.frameRight + 10, _numLabel.frameBottom, _bgView.frameWidth - _imgView.frameRight - 20, 15)];
        [_contLabel setBackgroundColor:[UIColor clearColor]];
        [_contLabel setFont:[UIFont systemFontOfSize:10]];
        [_contLabel setTextColor:[UIColor lightGrayColor]];
        [_bgView addSubview:_contLabel];
    }
    return self;
}

- (void)resetDataSource:(id)object
{
    GrowAlbumItem *item = (GrowAlbumItem *)object;
    NSString *str = item.thumb ?: item.path;
    if (![str hasPrefix:@"http"]) {
        str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (item.type.integerValue != 0){
        BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
        if (mp4) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_imgView setImage:image];
                });
            });
        }
        else
        {
            [_imgView setImageWithURL:[NSURL URLWithString:str]];
        }
    }
    else
    {
        [_imgView setImageWithURL:[NSURL URLWithString:str]];
    }
    
    [_titleLabel setText:item.name];
    [_numLabel setText:[NSString stringWithFormat:@"照片%@ / 视频%@",item.pic_num.stringValue,item.video_num.stringValue]];
    [_contLabel setText:item.digst ?: @""];
}

@end
