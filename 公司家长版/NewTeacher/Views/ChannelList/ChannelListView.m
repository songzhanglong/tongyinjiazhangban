//
//  ChannelListView.m
//  NewTeacher
//
//  Created by szl on 16/4/21.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "ChannelListView.h"

@implementation ChannelListView
{
    UITableView *_tableView;
    UIView *_lineView;
}

- (id)initWithFrame:(CGRect)frame TabHei:(CGFloat)hei
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -hei - 1, frame.size.width, hei) style:UITableViewStylePlain];
        [_tableView setBackgroundColor:[UIColor whiteColor]];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, -1, frame.size.width, 1)];
        [line setBackgroundColor:rgba(47, 125, 224, 1)];
        _lineView = line;
        [self addSubview:line];
    }
    
    return self;
}

- (void)showInView
{
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:0];
        [_lineView setFrameY:butRec.size.height];
    } completion:^(BOOL finished) {
        [self superview].userInteractionEnabled = YES;
    }];
}

- (void)hiddenInView
{
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:-butRec.size.height - 1];
        [_lineView setFrameY:-1];
    } completion:^(BOOL finished) {
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenInView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *phoneCell = @"channelListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCell];
        cell.textLabel.textColor = rgba(47, 125, 224, 1);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL sameIdx = (indexPath.row == _curIdx);
    CGRect butRec = _tableView.frame;
    [self superview].userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [_tableView setFrameY:-butRec.size.height - 1];
        [_lineView setFrameY:-1];
    } completion:^(BOOL finished) {
        if (!sameIdx) {
            if (_delegate && [_delegate respondsToSelector:@selector(channelViewSelectAt:)]) {
                [_delegate channelViewSelectAt:indexPath.row];
            }
        }
        [self superview].userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
}

@end
