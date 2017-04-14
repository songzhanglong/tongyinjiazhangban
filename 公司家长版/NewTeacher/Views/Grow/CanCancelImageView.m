//
//  CanCancelImageView.m
//  NewTeacher
//
//  Created by szl on 16/2/23.
//  Copyright (c) 2016年 songzhanglong. All rights reserved.
//

#import "CanCancelImageView.h"

@implementation CanCancelImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20)];
        _contentImg.userInteractionEnabled = YES;
        _contentImg.layer.masksToBounds = YES;
        _contentImg.layer.borderWidth = 2.0;
        _contentImg.layer.borderColor = [UIColor clearColor].CGColor;
        [self addSubview:_contentImg];
        
        _deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"closed1@2x" ofType:@"png"]] forState:UIControlStateNormal];
        [_deleteBut setFrame:CGRectMake(0, 0, 25, 25)];
        [_deleteBut setBackgroundColor:[UIColor clearColor]];
        [_deleteBut setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        [_deleteBut addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBut];
        
        _dragImgView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 25, frame.size.height - 25, 25, 25)];
        [_dragImgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dragImg" ofType:@"png"]]];
        [_dragImgView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [_dragImgView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *singleTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [_dragImgView addGestureRecognizer:singleTap];
        [self addSubview:_dragImgView];
        
        deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                           self.frame.origin.x+self.frame.size.width - self.center.x);
        
        // 移动手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [_contentImg addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [_contentImg addGestureRecognizer:tapGestureRecognizer];
        _nRotation = 0;
        
    }
    return self;
}

- (void)deleteSelf:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(CancelImageView:)]) {
        [_delegate CancelImageView:self];
    }
}

/**
 *	@brief	控制显示与隐藏
 */
- (void)controlHiddenOrShow
{
    _isHidden = !_isHidden;
    [_deleteBut setHidden:_isHidden];
    [_dragImgView setHidden:_isHidden];
    
    UIColor *color = _isHidden ? [UIColor clearColor] : CreateColor(244, 174, 97);
    _contentImg.layer.borderColor = color.CGColor;
}

- (void)hiddenButton
{
    _isHidden = YES;
    [_deleteBut setHidden:_isHidden];
    [_dragImgView setHidden:_isHidden];
    _contentImg.layer.borderColor = [UIColor clearColor].CGColor;
}

#pragma mark - 右下角手势
- (void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGSize imgSize = _contentImg.image.size;
        if (self.bounds.size.width < MIN_WEIGHT || self.bounds.size.width < MIN_HEIGHT)
        {
            CGFloat wei = MIN_WEIGHT;
            CGFloat hei = wei * imgSize.height / imgSize.width;
            if (hei < MIN_HEIGHT) {
                hei = MIN_HEIGHT;
                wei = hei * imgSize.width / imgSize.height;
            }
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     wei + 20,
                                     hei + 20);
            _contentImg.bounds = CGRectMake(_contentImg.bounds.origin.x, _contentImg.bounds.origin.y, wei, hei);
            _contentImg.center = CGPointMake(10 + wei / 2, 10 + hei / 2);
            prevPoint = [recognizer locationInView:self];
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            CGFloat wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            CGFloat wei,hei;
            if (ABS(wChange) > ABS(hChange)) {
                wei = self.bounds.size.width + wChange;
                hei = (wei - 20) * imgSize.height / imgSize.width + 20;
            }
            else{
                hei = self.bounds.size.height + hChange;
                wei = (hei - 20) * imgSize.width / imgSize.height + 20;
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, wei, hei);
            _contentImg.bounds = CGRectMake(_contentImg.bounds.origin.x, _contentImg.bounds.origin.y, wei - 20, hei - 20);
            _contentImg.center = CGPointMake(10 + _contentImg.bounds.size.width / 2, 10 + _contentImg.bounds.size.height / 2);
            prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        CGFloat ang = atan2([recognizer locationInView:self.superview].y - self.center.y,[recognizer locationInView:self.superview].x - self.center.x);
        CGFloat angleDiff = deltaAngle - ang;
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        double radians = atan2(self.transform.b, self.transform.a);
        _nRotation = radians * (180 / (CGFloat)M_PI);
    }
}

#pragma mark - self 手势
// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self.superview];
        CGPoint point = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [self setCenter:point];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(moveImageView:)]) {
            [_delegate moveImageView:self];
        }
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self controlHiddenOrShow];
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self hiddenButton];
    }else if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        self.transform = CGAffineTransformScale(self.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        CGFloat newScale = 1 / pinchGestureRecognizer.scale;
        _deleteBut.transform = CGAffineTransformScale(_deleteBut.transform, newScale, newScale);
        CGRect delRec = _deleteBut.frame;
        [_deleteBut setFrame:CGRectMake(0, 0, delRec.size.width, delRec.size.height)];
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(moveImageView:)]) {
            [_delegate moveImageView:self];
        }
    }
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self hiddenButton];
    }
    else if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformRotate(self.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
    else if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(moveImageView:)]) {
            [_delegate moveImageView:self];
        }
    }
}

@end
