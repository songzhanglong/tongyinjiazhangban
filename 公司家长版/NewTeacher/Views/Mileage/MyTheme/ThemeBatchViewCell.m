//
//  ThemeBatchViewCell.m
//  NewTeacher
//
//  Created by szl on 15/12/4.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ThemeBatchViewCell.h"
#import "ThemeBatchModel.h"
#import "UIImage+Caption.h"
#import "DJTGlobalManager.h"

@implementation ThemeBatchViewCell
{
    UILabel *_tipLab,*_numLab;
    UIButton *_digBut,*_comBut;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, winSize.width - 50, 16)];
        [_tipLab setTextColor:[UIColor blackColor]];
        [_tipLab setFont:[UIFont systemFontOfSize:12]];
        [_tipLab setBackgroundColor:[UIColor clearColor]];
        _tipLab.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_tipLab];
        
        CGFloat imgWei = (winSize.width - 50 - 10) / 3;
        for (int i = 0; i < 9; i++) {
            NSInteger col = i % 3;
            UIImageView *tmpImg = [[UIImageView alloc] initWithFrame:CGRectMake(25 + col * (imgWei + 5), 0, imgWei, imgWei)];
            [tmpImg setTag:i + 1];
            [tmpImg setUserInteractionEnabled:YES];
            [tmpImg setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:YES];
            [tmpImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)]];
            [tmpImg setBackgroundColor:BACKGROUND_COLOR];
            [self.contentView addSubview:tmpImg];
            
            //video
            UIImageView *video = [[UIImageView alloc] initWithFrame:CGRectMake((imgWei - 30) / 2, (imgWei - 30) / 2, 30, 30)];
            [video setImage:CREATE_IMG(@"mileageVideo")];
            [video setTag:10];
            [tmpImg addSubview:video];
        }
        
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(25, self.contentView.frameHeight - 10 - 16, winSize.width - 50, 16)];
        [_numLab setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_numLab setBackgroundColor:[UIColor clearColor]];
        [_numLab setTextColor:CreateColor(83, 144, 172)];
        [_numLab setHighlightedTextColor:[UIColor whiteColor]];
        [_numLab setFont:_tipLab.font];
        [self.contentView addSubview:_numLab];
        
        _digBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_digBut setBackgroundColor:[UIColor clearColor]];
        [_digBut setImage:CREATE_IMG(@"diggMileageN_1") forState:UIControlStateNormal];
        [_digBut setImage:CREATE_IMG(@"diggMileageH_1") forState:UIControlStateHighlighted];
        [_digBut setImage:CREATE_IMG(@"diggMileageH_1") forState:UIControlStateSelected];
        [_digBut setFrame:CGRectMake(_numLab.frameRight - 50 - 10, _numLab.frameY, 25, 25)];
        [_digBut setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_digBut addTarget:self action:@selector(diggAndComm:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_digBut];
        
        _comBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_comBut setBackgroundColor:[UIColor clearColor]];
        [_comBut setImage:CREATE_IMG(@"commMileageN_1") forState:UIControlStateNormal];
        [_comBut setImage:CREATE_IMG(@"commMileageH_1") forState:UIControlStateHighlighted];
        [_comBut setFrame:CGRectMake(_numLab.frameRight - 25, _numLab.frameY, 25, 25)];
        [_comBut setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_comBut addTarget:self action:@selector(diggAndComm:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_comBut];
    }
    return self;
}

- (void)diggAndComm:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(selectThemeBatchCell:Dig:)]) {
        [_delegate selectThemeBatchCell:self Dig:(_digBut == sender) ? 0 : 1];
    }
}

- (void)touchImageView:(UITapGestureRecognizer *)tap{
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectThemeBatchCell:At:)]) {
        NSInteger index = [[tap view] tag] - 1;
        [_delegate selectThemeBatchCell:self At:index];
    }
    
}

- (void)resetDataSource:(id)object
{
    ThemeBatchModel *batch = (ThemeBatchModel *)object;
    [_tipLab setText:batch.digst];
    [_numLab setText:[NSString stringWithFormat:@"点赞数：%@ 评论数：%@",batch.digg.stringValue,batch.replies.stringValue]];
    
    _digBut.selected = (batch.have_digg.integerValue != 0);
    
    NSInteger photoCount = [batch.photos count];
    CGFloat yOri = ([batch.digst length] > 0) ? (_tipLab.frameBottom + 5) : _tipLab.frameY;
    for (int i = 0; i < 9; i++) {
        UIImageView *tmpImg = (UIImageView *)[self.contentView viewWithTag:i + 1];
        if (i < photoCount) {
            [tmpImg setHidden:NO];
            NSInteger row = i / 3;
            [tmpImg setFrameY:yOri + row * (tmpImg.frameHeight + 5)];
            UIImageView *video = (UIImageView *)[tmpImg viewWithTag:10];
            
            ThemeBatchItem *item = batch.photos[i];
            NSString *str = item.thumb ?: item.path;
            
            if (![str hasPrefix:@"http"]) {
                str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            if (item.type.integerValue != 0){
                video.hidden = NO;
                BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
                if (mp4) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [tmpImg setImage:image];
                        });
                    });
                }
                else
                {
                    [tmpImg setImageWithURL:[NSURL URLWithString:str]];
                }
            }
            else
            {
                video.hidden = YES;
                [tmpImg setImageWithURL:[NSURL URLWithString:str]];
            }
        }
        else{
            [tmpImg setHidden:YES];
        }
    }
}

@end
