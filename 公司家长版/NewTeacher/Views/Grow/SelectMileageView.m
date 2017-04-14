//
//  SelectMileageView.m
//  NewTeacher
//
//  Created by szl on 16/1/27.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectMileageView.h"
#import "GrowAlbumItem.h"
#import "UIImage+Caption.h"
#import "YLZHoledView.h"

@interface SelectMileageView()

@property (nonatomic, strong) YLZHoledView *holedView;

@end

@implementation SelectMileageView
{
    UITableView *_tableView;
    UIView *_bottomView;
}

- (id)initWithFrame:(CGRect)frame Hei:(CGFloat)hei
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, hei - 38) style:UITableViewStylePlain];
        [_tableView setBackgroundColor:[UIColor blackColor]];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_tableView setSeparatorColor:[UIColor darkGrayColor]];
        [_tableView setTableFooterView:[UIView new]];
        [self addSubview:_tableView];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frameBottom, frame.size.width, 38)];
        _bottomView = bottomView;
        [bottomView setBackgroundColor:rgba(51, 51, 51, 1)];
        [self addSubview:bottomView];
        
        CGFloat butWei = (frame.size.width - 2) / 3,butHei = 24;
        NSArray *tips = @[@"本地相册",@"拍照",@"视频"];
        for (NSInteger i = 0; i < 3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake((butWei + 1) * i, 7, butWei, butHei)];
            [button setTitle:tips[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:i + 1];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button setBackgroundColor:bottomView.backgroundColor];
            [bottomView addSubview:button];
            
            if (i != 2) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.frameRight, button.frameY, 1, butHei)];
                [lineView setBackgroundColor:[UIColor whiteColor]];
                [bottomView addSubview:lineView];
            }
        }
    }
    
    return self;
}

- (void)pressedButton:(id)sender
{
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:butRec.size.height + butRec.origin.y + _bottomView.frameHeight];
        [_bottomView setFrameY:_tableView.frameBottom];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectButtonAt:)]) {
            [_delegate selectButtonAt:[sender tag] - 1];
        }
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

- (void)ihaveKnown:(id)sender
{
    [_holedView removeHoles];
    [_holedView removeFromSuperview];
    _holedView = nil;
}

- (UIView *)customView{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 170)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 34)];
    [lab setText:@"拍摄照片，小视频或选择本地照片，请点击这里。"];
    [lab setFont:[UIFont fontWithName:@"DFPShaoNvW5" size:14]];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setNumberOfLines:2];
    [lab setTextColor:[UIColor whiteColor]];
    [backView addSubview:lab];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"我知道了" forState:UIControlStateNormal];
    [button.titleLabel setFont:lab.font];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ihaveKnown:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(100, 40, 72, 20)];
    [backView addSubview:button];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((200 - 27) / 2, 60, 27, 52)];
    [imgView setImage:CREATE_IMG(@"cusArrow")];
    [backView addSubview:imgView];
    
    return backView;
}

- (void)showInView:(UIView *)view
{
    BOOL tip = [[NSUserDefaults standardUserDefaults] boolForKey:PICTURE_TIP];
    if (!tip) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PICTURE_TIP];
        _holedView = [[YLZHoledView alloc]initWithFrame:self.bounds];
        [_holedView setHidden:YES];
        [self addSubview:_holedView];
        [_holedView addHCustomView:[self customView] onRect:CGRectMake((SCREEN_WIDTH - 200) / 2, SCREEN_HEIGHT - 38 - 115, 200, 115)];
    }
    
    [view addSubview:self];
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:butRec.origin.y - butRec.size.height - _bottomView.frameHeight];
        [_bottomView setFrameY:_tableView.frameBottom];
    } completion:^(BOOL finished) {
        [self superview].userInteractionEnabled = YES;
        if (!tip) {
            [_holedView setHidden:NO];
            [_holedView addHoleRoundedRectOnRect:_bottomView.frame withCornerRadius:0];
        }
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_holedView) {
        return;
    }
    
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:butRec.size.height + butRec.origin.y];
        [_bottomView setFrameY:_tableView.frameBottom];
    } completion:^(BOOL finished) {
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *phoneCell = @"growAlbumListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCell];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 44, 44)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setTag:1];
        [imageView setBackgroundColor:BACKGROUND_COLOR];
        [cell.contentView addSubview:imageView];
        
        //video
        UIImageView *video = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
        [video setImage:CREATE_IMG(@"mileageVideo")];
        [video setTag:10];
        [imageView addSubview:video];
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameRight + 10, imageView.frameY + 2, SCREEN_WIDTH - imageView.frameRight - 58, 18)];
        [nameLab setBackgroundColor:[UIColor blackColor]];
        [nameLab setFont:[UIFont systemFontOfSize:14]];
        [nameLab setTextColor:[UIColor whiteColor]];
        [nameLab setTag:2];
        [cell.contentView addSubview:nameLab];
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameRight + 10, imageView.frameBottom - 18, nameLab.frameWidth, 16)];
        [numLab setBackgroundColor:[UIColor blackColor]];
        [numLab setFont:[UIFont systemFontOfSize:12]];
        [numLab setTextColor:[UIColor darkGrayColor]];
        [numLab setTag:3];
        [cell.contentView addSubview:numLab];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *numLab = (UILabel *)[cell.contentView viewWithTag:3];
    UIImageView *video = (UIImageView *)[imageView viewWithTag:10];
    
    GrowAlbumItem *item = [_dataSource objectAtIndex:indexPath.row];
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
                    [imageView setImage:image];
                });
            });
        }
        else
        {
            [imageView setImageWithURL:[NSURL URLWithString:str]];
        }
    }
    else
    {
        video.hidden = YES;
        [imageView setImageWithURL:[NSURL URLWithString:str]];
    }
    
    [nameLab setText:item.name];
    [numLab setText:[NSString stringWithFormat:@"照片:%@ 视频:%@",item.pic_num.stringValue,item.video_num.stringValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:butRec.size.height + butRec.origin.y + _bottomView.frameHeight];
        [_bottomView setFrameY:_tableView.frameBottom];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectMileageAt:)]) {
            [_delegate selectMileageAt:indexPath.row];
        }
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

@end
