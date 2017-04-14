//
//  DJTListView.m
//  TY
//
//  Created by songzhanglong on 14-6-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DJTListView.h"
#import "WeekListModel.h"
#import "DJTGlobalManager.h"

@implementation DJTListView
{
    UILabel *_titleLab;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //[self setBackgroundColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - 20) / 2, frame.size.width-10, 20.0)];
        _titleLab = titleLabel;
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:1];
        [self addSubview:titleLabel];
        
        //按钮
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 25, (frame.size.height - 20) / 2, 30, 20)];
        [_imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"down" ofType:@"png"]]];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_imageView];
        
        _curIndex = 0;
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch view] == self) {
        _isExpand = YES;
        
        UIView *fullView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        //空白按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setFrame:[[UIScreen mainScreen] bounds]];
        [btn addTarget:self action:@selector(clearTableView:) forControlEvents:UIControlEventTouchUpInside];
        [fullView addSubview:btn];
        
        //表格视图
        //CGRect rect = self.frame;
        UIViewController *control = [DJTGlobalManager viewController:self Class:[UIViewController class]];
        CGRect rect = [control.view convertRect:self.frame fromView:self.superview];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, 0) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 30;
        [fullView addSubview:tableView];
        
        [self.window addSubview:fullView];
        
        NSInteger count = [_titleArray count];
        count = (count < 5) ? count : 5;
        float hei = count * self.frame.size.height;
        CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, hei);
        [UIView animateWithDuration:0.2 animations:^{
            [tableView setFrame:newRect];
        }completion:^(BOOL finished) {
            _imageView.transform = CGAffineTransformRotate(_imageView.transform, DEGREES_TO_RADIANS(180));
        }];
    }
    
}

/**
 *	@brief	空白处点击，让tableview消失
 *
 *	@param 	sender 	空白按钮项
 */
- (void)clearTableView:(id)sender
{
    _isExpand = NO;
    _imageView.transform = CGAffineTransformRotate(_imageView.transform, DEGREES_TO_RADIANS(180));
    UIView *view = [sender superview];
    [view removeFromSuperview];
}


/**
 *	@brief	获取当前选择的数据源
 *
 *	@return	数据源
 */
- (id)getCurrentSelected
{
    if (_curIndex < 0) {
        return nil;
    }
    
    return [_titleArray objectAtIndex:_curIndex];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isExpand) {
        return [_titleArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierCell];
        //[cell.contentView setBackgroundColor:[UIColor clearColor]];
        UIColor *color = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        [cell.contentView setBackgroundColor:color];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, cell.contentView.bounds.size.width, 20)];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.tag = 100;
        [titleLabel setTextAlignment:1];
        titleLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:titleLabel];
    }
    UILabel *titleLab = (UILabel *)[cell.contentView viewWithTag:100];
    WeekListModel *model = [_titleArray objectAtIndex:indexPath.row];
    titleLab.text = [NSString stringWithFormat:@"%@%@",model.term_name,model.week_name];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
         cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _isExpand = NO;
    
    BOOL isNeedRefresh = (_curIndex != indexPath.row);
    
    _curIndex = indexPath.row;
    WeekListModel *model = [_titleArray objectAtIndex:indexPath.row];
    _titleLab.text = [NSString stringWithFormat:@"%@%@",model.term_name,model.week_name];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = tableView.frame;
        [tableView setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0)];
    } completion:^(BOOL finished) {
        _imageView.transform = CGAffineTransformRotate(_imageView.transform, DEGREES_TO_RADIANS(180));
        [[tableView superview] removeFromSuperview];
        if (isNeedRefresh) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectData:IndexPath:)]) {
                [self.delegate selectData:_titleArray[indexPath.row] IndexPath:indexPath];
            }
        }
    }];
}

#pragma mark chose title
- (void)setCurIndex:(NSInteger)curIndex
{
    if (_curIndex == curIndex) {
        return;
    }
    
    _curIndex = curIndex;
    if (!_titleArray || [_titleArray count] <= _curIndex) {
        return;
    }
    WeekListModel *model = [_titleArray objectAtIndex:_curIndex];
    _titleLab.text = [NSString stringWithFormat:@"%@%@",model.term_name,model.week_name];
}

- (void)setPSource:(NSArray *)pSource
{
    if (_titleArray == pSource) {
        return;
    }
    
    _titleArray = pSource;
    
    WeekListModel *model = [_titleArray objectAtIndex:_curIndex];
    _titleLab.text = [NSString stringWithFormat:@"%@%@",model.term_name,model.week_name];
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    return;
    CGPoint point = scrollView.contentOffset;
    if (point.y < 0) {
        [scrollView setContentOffset:CGPointMake(point.x, 0)];
    }
}*/

@end
