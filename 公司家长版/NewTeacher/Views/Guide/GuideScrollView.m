//
//  GuideScrollView.m
//  NewTeacher
//
//  Created by songzhanglong on 15/3/30.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "GuideScrollView.h"

@implementation GuideScrollView
{
    UIPageControl *_pageControl;
    BOOL isLaunchApp;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [scrollView setContentSize:CGSizeMake(frame.size.width * 4, frame.size.height)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        [self addSubview:scrollView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 30, frame.size.width, 20)];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.numberOfPages = 4;
        [self addSubview:_pageControl];
        
        CGSize oldSize = CGSizeMake(720.0, 1280.0);
        CGSize newSize = CGSizeMake(frame.size.width, frame.size.height);
        
        CGFloat fRate = MAX(newSize.width / oldSize.width, newSize.height / oldSize.height);
        CGFloat xMargin = (newSize.width - oldSize.width * fRate) / 2,yMargin = (newSize.height - oldSize.height * fRate) / 2;
        NSArray *array = @[@"newGui1.jpg",@"newGui2.jpg",@"newGui3.jpg",@"newGui4.jpg"];
        for (NSInteger i = 0; i < array.count; i++) {
            UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:array[i] ofType:nil]];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width * i + xMargin, yMargin, oldSize.width * fRate, oldSize.height * fRate)];
            [imageView setImage:img];
            [scrollView addSubview:imageView];
        }
        isLaunchApp = YES;
    }
    return self;
}

- (void)launchApp:(id)sender
{
    [_delegate startLaunchApp:self];
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)setNewCurentPage:(UIScrollView *)scrollView
{
    NSInteger lastIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    _pageControl.currentPage = lastIndex;
}

#pragma mark -  滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setNewCurentPage:scrollView];
}

#pragma mark -  触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self setNewCurentPage:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self setNewCurentPage:scrollView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > ((_pageControl.numberOfPages - 1) * scrollView.frame.size.width + 5) && isLaunchApp) {
        [_delegate startLaunchApp:self];
        isLaunchApp = NO;
    }
}
@end
