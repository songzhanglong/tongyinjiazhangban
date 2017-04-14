//
//  MileageListViewCell.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageListViewCell.h"
#import "MileageModel.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import "DJTGlobalManager.h"

@implementation MileageListViewCell
{
    UIView *_topLeft,*_leftView,*_rightView,*_rightView2;
    UILabel *_fromLabel,*_nameLab;
    UIImageView *_trangleImg,*_otherImgView;
    UIButton *_editBtn;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3;
        
        //left
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, wei, self.contentView.frameHeight)];
        [_leftView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchLeftView:)]];
        [_leftView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_leftView];
        
        _topLeft = [[UIView alloc] initWithFrame:CGRectMake(15, 5, 2, 14)];
        [self.contentView addSubview:_topLeft];
        
        _fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 5, 50, 14)];
        [_fromLabel setFont:[UIFont systemFontOfSize:12]];
        [_fromLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_fromLabel];
        
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn = editBtn;
        [editBtn setFrame:CGRectMake(_leftView.frameRight - 5 - 20, 5, 20, 20)];
        [editBtn setBackgroundColor:[UIColor clearColor]];
        [editBtn setImage:CREATE_IMG(@"mileageEdit") forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editThemeName:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editBtn];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(15, self.contentView.frameHeight - 20, _leftView.frameWidth - 10, 18)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setTextColor:[UIColor whiteColor]];
        [_nameLab setNumberOfLines:2];
        [self.contentView addSubview:_nameLab];
        
        //trangle
        _trangleImg = [[UIImageView alloc] initWithFrame:CGRectMake(_leftView.frameRight, 0, 4, 7.5)];
        [_trangleImg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_trangleImg];
        
        //right
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(_leftView.frameRight + 10, 0, wei * 2, self.contentView.frameHeight)];
        [_rightView setBackgroundColor:[UIColor whiteColor]];
        [_rightView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchRightView:)]];
        [_rightView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_rightView];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:_rightView.bounds];
        [lineImgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        lineImgView.image = CREATE_IMG(@"mileage_lne");
        [_rightView addSubview:lineImgView];
        
        _rightView2 = [[UIView alloc] initWithFrame:_rightView.frame];
        [_rightView2 setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_rightView2 setBackgroundColor:[UIColor whiteColor]];
        [_rightView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchRightView:)]];
        [self.contentView addSubview:_rightView2];
        
        NSArray *tips1 = @[@"暂无里程内容",@"您可以添加照片、小视频，记录宝贝成长每一步"],*tips2 = @[@"有更新啦！",@"快去找一找关于宝宝的照片或小视频"];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size1 = [NSString calculeteSizeBy:tips1[1] Font:font MaxWei:_rightView.frameWidth - 20];
        CGSize size2 = [NSString calculeteSizeBy:tips2[1] Font:font MaxWei:_rightView2.frameWidth - 10 - 60];
        for (NSInteger i = 0; i < 2; i++) {
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, (70 - 16 - size1.height) / 2 + 16 * i, size1.width, (i == 0) ? 16 : size1.height)];
            [label1 setTextColor:[UIColor darkGrayColor]];
            [label1 setFont:font];
            [label1 setTextAlignment:1];
            [label1 setNumberOfLines:0];
            [label1 setText:tips1[i]];
            [_rightView addSubview:label1];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, (70 - 16 - size2.height) / 2 + 16 * i, size2.width, (i == 0) ? 16 : size2.height)];
            [label2 setTextColor:[UIColor darkGrayColor]];
            [label2 setNumberOfLines:0];
            [label2 setFont:font];
            [label2 setText:tips2[i]];
            [_rightView2 addSubview:label2];
        }
        
        UIView *rightOfRight = [[UIView alloc] initWithFrame:CGRectMake(_rightView2.frameWidth - 60, 0, 60, 70)];
        [rightOfRight setBackgroundColor:rgba(231, 234, 237, 1)];
        [_rightView2 addSubview:rightOfRight];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(rightOfRight.frameX, 5, rightOfRight.frameWidth, 15)];
        [tipLab setTextAlignment:1];
        [tipLab setTextColor:[UIColor lightGrayColor]];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [tipLab setFont:font];
        [tipLab setText:@"班级最新:"];
        [_rightView2 addSubview:tipLab];
        
        _otherImgView = [[UIImageView alloc] initWithFrame:CGRectMake(rightOfRight.frameX + 10, tipLab.frameBottom + 5, rightOfRight.frameWidth - 20, rightOfRight.frameWidth - 20)];
        [_otherImgView setContentMode:UIViewContentModeScaleAspectFill];
        [_otherImgView setClipsToBounds:YES];
        [_otherImgView setBackgroundColor:BACKGROUND_COLOR];
        [_rightView2 addSubview:_otherImgView];
        //video
        UIImageView *otherVideo = [[UIImageView alloc] initWithFrame:CGRectMake((_otherImgView.frameWidth - 20) / 2, (_otherImgView.frameHeight - 20) / 2, 20, 20)];
        [otherVideo setImage:CREATE_IMG(@"mileageVideo")];
        [otherVideo setTag:10];
        [_otherImgView addSubview:otherVideo];
        
        //images
        for (int i = 0; i < 2; i++) {
            UIImageView *tmpImg = [[UIImageView alloc] initWithFrame:CGRectMake(_rightView.frameX + wei * i, 0, wei, self.contentView.frameHeight)];
            [tmpImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [tmpImg setTag:i + 1];
            [tmpImg setUserInteractionEnabled:YES];
            [tmpImg setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:YES];
            [tmpImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)]];
            [tmpImg setBackgroundColor:BACKGROUND_COLOR];
            [self.contentView addSubview:tmpImg];
            
            //video
            UIImageView *video = [[UIImageView alloc] initWithFrame:CGRectMake((wei - 30) / 2, (wei - 30) / 2, 30, 30)];
            [video setImage:CREATE_IMG(@"mileageVideo")];
            [video setTag:10];
            [tmpImg addSubview:video];
        }
    }
    
    return self;
}

- (void)touchLeftView:(UITapGestureRecognizer *)tap{
    if (_delegate && [_delegate respondsToSelector:@selector(touchColorLump:)]) {
        [_delegate touchColorLump:self];
    }
}

- (void)touchRightView:(UITapGestureRecognizer *)tap{
    if (_delegate && [_delegate respondsToSelector:@selector(touchRightBlock:)]) {
        [_delegate touchRightBlock:self];
    }
}

- (void)touchImageView:(UITapGestureRecognizer *)tap{
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectMileageImage:At:)]) {
        NSInteger index = [[tap view] tag] - 1;
        [_delegate selectMileageImage:self At:index];
    }
        
}

- (void)editThemeName:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(beginEditMileageName:)]) {
        [_delegate beginEditMileageName:self];
    }
}

- (void)resetDataSource:(id)object
{
    MileageModel *mileage = (MileageModel *)object;
    NSInteger type = mileage.mileage_type.integerValue; //1（我的）  2（教师） 3（推荐）
    _editBtn.hidden = (type != 1);
    BOOL isMe = (type == 1),isTeacher = (type == 2);
    UIColor *topColor = isMe ? CreateColor(33, 131, 131) : (isTeacher ? CreateColor(23, 72, 142) : CreateColor(91, 147, 45));
    [_topLeft setBackgroundColor:topColor];
    [_fromLabel setTextColor:topColor];
    NSString *from = isMe ? @"我" : (isTeacher ? @"班级" : @"推荐");
    [_fromLabel setText:from];
    
    UIColor *leftColor = isMe ? CreateColor(120, 205, 205) : (isTeacher ? CreateColor(81, 123, 184) : CreateColor(139, 203, 87));
    [_leftView setBackgroundColor:leftColor];
    
    NSInteger photoCount = [mileage.photo count];
    
    /*
     1.无图片，_rightView不隐藏，_rightView2隐藏
     2.有图片，我的相册，_rightView隐藏，_rightView2隐藏,图片正常显示
     3.有图片，非我的相册，_rightView隐藏，如第一张是我发的，则_rightView2隐藏，否则_rightView2不隐藏，图片显示1张或2张
     4.有图片，非我的相册，_rightView隐藏,第一张不是我的，则_rightView2不隐藏，图片不显示
     */
    [_rightView setHidden:(photoCount > 0)];
    
    BOOL firstMe = NO,secondMe = NO;
    NSInteger lastPhotoCount = photoCount;
    if (isMe) {
        [_rightView2 setHidden:YES];
    }
    else
    {
        if (photoCount > 0) {
            NSString *userId = [DJTGlobalManager shareInstance].userInfo.userid;
            MileagePhotoItem *firstPhoto = mileage.photo[0];
            firstMe = (firstPhoto.is_teacher.integerValue == 0) && ([firstPhoto.userid isEqualToString:userId]);
            if (photoCount > 1) {
                MileagePhotoItem *secondPhoto = mileage.photo[1];
                secondMe = (secondPhoto.is_teacher.integerValue == 0) && ([secondPhoto.userid isEqualToString:userId]);
            }
        }
        lastPhotoCount = firstMe ? (secondMe ? 2 : 1) : 0;
        [_rightView2 setHidden:!((photoCount > 0) && !firstMe)];
        
        if (!_rightView2.hidden && (photoCount > 0)) {
            UIImageView *video = (UIImageView *)[_otherImgView viewWithTag:10];
            MileagePhotoItem *firstPhoto = mileage.photo[0];
            NSString *str = firstPhoto.thumb ?: firstPhoto.path;
            
            if (![str hasPrefix:@"http"]) {
                str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            if (firstPhoto.type.integerValue != 0){
                video.hidden = NO;
                BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
                if (mp4) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_otherImgView setImage:image];
                        });
                    });
                }
                else
                {
                    [_otherImgView setImageWithURL:[NSURL URLWithString:str]];
                }
            }
            else
            {
                video.hidden = YES;
                [_otherImgView setImageWithURL:[NSURL URLWithString:str]];
            }
        }
    }
    
    NSString *imgName = isMe ? @"mileageTrangleMe" : (isTeacher ? @"mileageTrangleTea" : @"mileageTrangleRec");
    [_trangleImg setImage:CREATE_IMG(imgName)];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat wei = (winSize.width - 30) / 3;
    CGFloat hei = (_rightView.hidden && _rightView2.hidden) ? wei : 70;
    [_trangleImg setFrameY:(hei - _trangleImg.frameHeight) / 2];
    [_nameLab setText:mileage.name];
    [_nameLab setFrame:CGRectMake(_nameLab.frameX, hei - 5 - mileage.nameHei, _nameLab.frameWidth, mileage.nameHei)];
    
    for (int i = 0; i < 2; i++) {
        UIImageView *tmpImg = (UIImageView *)[self.contentView viewWithTag:i + 1];
        if (i < lastPhotoCount) {
            [tmpImg setHidden:NO];
            UIImageView *video = (UIImageView *)[tmpImg viewWithTag:10];
            
            MileagePhotoItem *item = mileage.photo[i];
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
