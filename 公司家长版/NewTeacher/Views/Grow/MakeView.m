//
//  MakeView.m
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "MakeView.h"
#import "HorizontalButton.h"
#import "Toast+UIView.h"

@implementation MakeView
{
    CGSize _minimumSize,_maxSize,_initSize;          //确定图片最小尺寸
    HorizontalButton *_addBut;
    UIImageView *_tipImg;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = CreateColor(220, 220, 221);
        self.clipsToBounds = YES;
        [self addGestureRecognizerToView:self];
        
        _addBut = [HorizontalButton buttonWithType:UIButtonTypeCustom];
        _addBut.enabled = NO;
        [_addBut setFrame:CGRectMake((frame.size.width - 104) / 2, (frame.size.height - 14) / 2, 104, 14)];
        _addBut.imgSize = CGSizeMake(14, 14);
        _addBut.textSize = CGSizeMake(90, 14);
        [_addBut setBackgroundColor:[UIColor clearColor]];
        [_addBut setTitle:@"添加图片或者小视频" forState:UIControlStateNormal];
        [_addBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addBut.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_addBut setImage:CREATE_IMG(@"addMileageN") forState:UIControlStateNormal];
        [self addSubview:_addBut];
        
        _nRotation = 0;
        
        _tipImg = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 25) / 2, (frame.size.height - 25) / 2, 25, 25)];
        [_tipImg setBackgroundColor:[UIColor clearColor]];
        [_tipImg setImage:CREATE_IMG(@"checkStop")];
        [self addSubview:_tipImg];
        _tipImg.hidden = YES;
    }
    
    return self;
}

- (void)beginScale:(CGFloat)scale
{
    _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, _curImg.bounds.size.width * scale, _curImg.bounds.size.height * scale);

    if (_curImg.bounds.size.width < _minimumSize.width) {
        //让图片无法缩得比原图小
        CGFloat rate = _minimumSize.width / _curImg.bounds.size.width;
        _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, _curImg.bounds.size.width * rate, _curImg.bounds.size.height * rate);
    }
    else if (_curImg.bounds.size.width > _maxSize.width)
    {
        CGFloat rate = _maxSize.width / _curImg.bounds.size.width;
        _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, _curImg.bounds.size.width * rate, _curImg.bounds.size.height * rate);
    }
    [self checkTipShow];
}

#pragma mark - 手势
// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [view addGestureRecognizer:tapGestureRecognizer];
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (!_curImg) {
        return;
    }
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan){
        
    }
    else if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _curImg.transform = CGAffineTransformRotate(_curImg.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
    else if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self dealwithAfterGesture];
        double radians = atan2(_curImg.transform.b, _curImg.transform.a);
        _nRotation = radians * (180 / (CGFloat)M_PI);
    }
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!_curImg) {
        return;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
    }else if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, _curImg.bounds.size.width * pinchGestureRecognizer.scale, _curImg.bounds.size.height * pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
        
        [self checkTipShow];
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_curImg.bounds.size.width < _minimumSize.width) {
            //让图片无法缩得比原图小
            CGFloat rate = _minimumSize.width / _curImg.bounds.size.width;
            _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, _curImg.bounds.size.width * rate, _curImg.bounds.size.height * rate);
        }
        else if (_curImg.bounds.size.width > _maxSize.width)
        {
            CGFloat rate = _maxSize.width / _curImg.bounds.size.width;
            _curImg.bounds = CGRectMake(_curImg.bounds.origin.x, _curImg.bounds.origin.y, _curImg.bounds.size.width * rate, _curImg.bounds.size.height * rate);
        }
        [self checkTipShow];
        [self dealwithAfterGesture];
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_curImg) {
        return;
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGestureRecognizer translationInView:self.superview];
        CGPoint point = CGPointMake(_curImg.center.x + translation.x, _curImg.center.y + translation.y);
        [_curImg setCenter:point];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self dealwithAfterGesture];
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchMakeView:)]) {
        [_delegate touchMakeView:self];
    }
}

#pragma mark - 手势处理完毕回调
- (void)dealwithAfterGesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(hasChangeState:)]) {
        [_delegate hasChangeState:self];
    }
}

#pragma mark - 警告提示
- (void)checkTipShow
{
    CGFloat ratio = _curImg.bounds.size.width / _initSize.width;
    [_tipImg setHidden:(ratio <= sqrt(2))];
}

#pragma mark - 视图重设
/**
 *	@brief	视图重设
 *
 *	@param 	image 	图片内容
 */
- (void)resetImageView:(UIImage *)image
{
    if (_curImg) {
        [_curImg removeFromSuperview];
        _curImg = nil;
    }
    
    if (!image) {
        _addBut.hidden = NO;
        _tipImg.hidden = YES;
        return;
    }
    
    _nRotation = 0;
    _addBut.hidden = YES;
    _curImg = [[UIImageView alloc] init];
    _curImg.backgroundColor = [UIColor blackColor];
    [_curImg setUserInteractionEnabled:YES];
    [_curImg setMultipleTouchEnabled:YES];
    _curImg.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_curImg];
    [self sendSubviewToBack:_curImg];
    
    [_curImg setImage:image];
    
    //图片尺寸
    CGSize viewSize = self.bounds.size;
    CGSize imgSize = image.size;
    //当前最大放大比例
    _initSize = CGSizeMake(imgSize.width * _fRate, imgSize.height * _fRate);
    CGFloat singleRatio = sqrt(2);
    _maxSize = CGSizeMake(_initSize.width * singleRatio, _initSize.height * singleRatio);
    
    //计算充满全屏需要多少比例
    CGFloat fullBili = MAX(viewSize.width / imgSize.width, viewSize.height / imgSize.height);
    CGSize fullSize = CGSizeMake(imgSize.width * fullBili, imgSize.height * fullBili);
    [_curImg setFrame:CGRectMake((viewSize.width - fullSize.width) / 2, (viewSize.height - fullSize.height) / 2, fullSize.width, fullSize.height)];
    
    CGFloat minWei = 0,minHei = 0;
    if (self.bounds.size.height / imgSize.height < self.bounds.size.width / imgSize.width) {
        minHei = self.bounds.size.height;
        minWei = minHei * imgSize.width / imgSize.height;
    }
    else{
        minWei = self.bounds.size.width;
        minHei = minWei * imgSize.height / imgSize.width;
    }
    _minimumSize = CGSizeMake(minWei, minHei);
    
    //    CGFloat minWei = MIN(self.bounds.size.width, self.bounds.size.height) / singleRatio;
    //    if (imgSize.width < imgSize.height) {
    //        _minimumSize = CGSizeMake(minWei, minWei * imgSize.height / imgSize.width);
    //    }
    //    else{
    //        _minimumSize = CGSizeMake(minWei * imgSize.width / imgSize.height, minWei);
    //    }
    
    if (_maxSize.width < fullSize.width) {
        //非高清图片,_maxSize小于fullSize
        _maxSize = fullSize;
    }
    
    [self checkTipShow];
}


@end
