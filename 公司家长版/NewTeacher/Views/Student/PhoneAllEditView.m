//
//  PhoneAllEditView.m
//  NewTeacher
//
//  Created by 张雪松 on 15/10/21.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "PhoneAllEditView.h"
#import "DJTGlobalManager.h"

@implementation PhoneAllEditView
{
    UITableView *_tableView;
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        NSArray *dataArray = manager.userInfo.teacher_datas;
        int count = ([dataArray count] > 3) ? 3 : (int)[dataArray count];
        UIView *mview = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 55*(count+1))];
        [mview setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:mview];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 55*count)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [mview addSubview:_tableView];
        
        [self creatFooterView:mview];
    }
    
    return self;
}
- (void )creatFooterView:(UIView *)mview
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, mview.bounds.size.height - 55, [[UIScreen mainScreen] bounds].size.width, 55)];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"取 消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [mview addSubview:button];
}
- (void)cancelAction:(id)sender
{
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)phoneTelAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    TeacherData *data = [manager.userInfo.teacher_datas objectAtIndex:indexPath.row];
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectEditIndex:)]) {
            [_delegate selectEditIndex:data.teacher_tel];
        }
        [self removeFromSuperview];
    }];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];

    return [manager.userInfo.teacher_datas count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *phoneCell = @"PhoneListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneCell];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *bgLabel = [[UILabel alloc] initWithFrame:cell.bounds];
        bgLabel.backgroundColor = CreateColor(246, 246, 249);
        cell.backgroundView = bgLabel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 80, 45)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:18];
        [nameLabel setTag:1];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 140, 45)];
        phoneLabel.backgroundColor = [UIColor clearColor];
        phoneLabel.textColor = CreateColor(48, 203, 90);
        phoneLabel.font = [UIFont systemFontOfSize:18];
        [phoneLabel setTag:2];
        [cell.contentView addSubview:phoneLabel];
        
        UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneButton.frame = CGRectMake(cell.contentView.bounds.size.width-80, 15, 60, 25);
        [phoneButton setImage:[UIImage imageNamed:@"bh.png"] forState:UIControlStateNormal];
        [phoneButton addTarget:self action:@selector(phoneTelAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:phoneButton];
    }
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    TeacherData *model = [manager.userInfo.teacher_datas objectAtIndex:indexPath.row];
    UILabel *_nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    if (_nameLabel) {
        _nameLabel.text = model.teacher_name;
    }
    UILabel *_phoneLabel = (UILabel *)[cell.contentView viewWithTag:2];
    if (_phoneLabel) {
        _phoneLabel.text = model.teacher_tel;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *butFather = [[self subviews] objectAtIndex:0];
    CGRect butRec = butFather.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [butFather setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
