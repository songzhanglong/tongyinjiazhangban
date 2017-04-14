//
//  DJTMakeGrowController.m
//  TYWorld
//
//  Created by songzhanglong on 14-10-14.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "MakeGrowController.h"
#import "DJTGlobalDefineKit.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "DJTGlobalManager.h"
#import "NSObject+Reflect.h"
#import "DJTHttpClient.h"
#import "SelectPhotosViewController.h"
#import "DecorateModel.h"
#import "EditGrowBar.h"
#import "UIImage+Caption.h"
#import "GrowAlbumListItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIColor+Hex.h"
#import "MakeView.h"
#import "MyCustomTextView.h"
#import "EditTextView.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "DJTOrderViewController.h"
#import "YLZHoledView.h"
#import "AddTextViewController.h"
#import "DecoTextView.h"

#define LABEL_TIP   @"请输入文字"
#define BookBindingSwi  @"bookSwitch"
#define BookBindingTip  @"bookSwitchTip"

@interface UINavigationBar (YYAdditions)
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event ;
@end

@implementation UINavigationBar (YYAdditions)


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self pointInside:point withEvent:event]) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
    
    return [super hitTest:point withEvent:event];
}

@end

#pragma mark - 控制器
@interface MakeGrowController ()<CanCancelImageViewDelegate,MakeViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,EditGrowBarDelegate,SelectPhotosViewControllerDelegate,EditTextViewDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,MWPhotoBrowserDelegate,AddTextViewControllerDelegate>

@property (nonatomic, strong) YLZHoledView *holedView;
@property (nonatomic,strong)MPMoviePlayerController *movieController;
@property (nonatomic,strong)AddTextViewController *addTextController;

@end

@implementation MakeGrowController
{
    UIView *_toolbar,*_decorateView,*_lineView;
    CGFloat _fRate,_newRate;  //缩放比例
    UIImageView *_targetImageView,*_leftBinding,*_rightBinding;
    
    NSMutableArray *_allImages,*_allMakeViews,*_allFields,*_voiceUrlArray,*_allTxtImages;
    
    MakeView *_touchView;
    UICollectionView *_collectionView;
    UILabel *_responderLabel;
    
    NSInteger _nSelectIdx;
    
    EditGrowBar *_editGrowBar;
    EditTextView *_editView;
    CGFloat _indexOffset;
    NSMutableArray *_loactionPathArray,*_browserPhotos;
    UIButton *_swiBut;
    
    MyCustomTextView *_cusEditView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.showBack = YES;
    self.titleLable.text = [DJTGlobalManager shareInstance].userInfo.uname;
    self.titleLable.textColor = [UIColor whiteColor];
    
    //backImg
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg4" ofType:@"jpg"]]];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:imgView];
    
    //btn
    UIButton *lefBut = (UIButton *)((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView;
    [lefBut setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backL@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [lefBut setFrame:CGRectMake(0, 0, 40, 22)];
    
    _allImages = [NSMutableArray array];
    _allFields = [NSMutableArray array];
    _voiceUrlArray = [NSMutableArray array];
    _loactionPathArray = [NSMutableArray array];
    _browserPhotos = [NSMutableArray array];
    _allTxtImages = [NSMutableArray array];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 50.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(uploadSaved:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightButtonItem];
    
    //target
    [self targetViewCreate];

    //tool bar
    [self toolBarCreate];
    
    if (![DJTGlobalManager shareInstance].userInfo.decorationArr) {
        //获取素材列表
        [self getDecorationList];
    }
    
    [self createBookBinding];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault boolForKey:BookBindingTip]) {
        [userDefault setBool:YES forKey:BookBindingTip];
        [self createHoldView];
    }
}

#pragma mark - 出现与消失时的状态栏与导航栏的配置
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBarTintColor:[UIColor blackColor]];
    [navBar setBarStyle:UIBarStyleBlack];
    [navBar setTranslucent:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_holedView) {
        CGRect leftRect = CGRectMake(_targetImageView.frameX, _targetImageView.frameY, _leftBinding.frameWidth, _toolbar.frameY - _targetImageView.frameY);
        CGRect rightRect = CGRectMake(_targetImageView.frameRight - leftRect.size.width,leftRect.origin.y,leftRect.size.width,leftRect.size.height);
        [_holedView addHoleRoundedRectOnRect:leftRect withCornerRadius:0];
        [_holedView addHoleRoundedRectOnRect:rightRect withCornerRadius:0];
        [_holedView addHoleRoundedRectOnRect:_swiBut.frame withCornerRadius:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBarTintColor:[UIColor whiteColor]];
    
    [navBar setBarStyle:UIBarStyleDefault];
    [navBar setTranslucent:NO];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_editView && _editView.audioPlayer != nil && [_editView.audioPlayer isPlaying]) {
        [_editView.audioPlayer stop];
        _editView.audioPlayer = nil;
    }
}

#pragma mark - 聚光灯
- (void)createHoldView
{
    _holedView = [[YLZHoledView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIView *custom = [self customView1];
    CGRect cusRect = CGRectMake((SCREEN_WIDTH - custom.frameWidth) / 2, (_targetImageView.frameHeight - custom.frameRight) / 2 + _targetImageView.frameY, custom.frameWidth, custom.frameHeight);
    [_holedView addHCustomView:custom onRect:cusRect];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:_holedView];
    //window.userInteractionEnabled = NO;
    //    CGFloat alpha = _holedView.alpha;
    //    [_holedView setAlpha:0];
    //    [UIView animateWithDuration:0.1 animations:^{
    //        [_holedView setAlpha:alpha];
    //    } completion:^(BOOL finished) {
    //
    //        //window.userInteractionEnabled = YES;
    //    }];
}

- (UIView *)customView1
{
    NSString *str = @"建议您在制作成长档案时,尽量不要将照片的重要部分放置于两侧装订线覆盖的区域内。";
    UIFont *font = [UIFont fontWithName:@"DFPShaoNvW5" size:14];
    CGFloat wei = _targetImageView.frameWidth - _leftBinding.frameWidth * 2 - 40;
    CGSize size = [NSString calculeteSizeBy:str Font:font MaxWei:wei];
    
    UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(20, 0, wei + 10, 5 + size.height + 5 + 18 + 5)];
    [middle setBackgroundColor:[UIColor clearColor]];
    [middle.layer setCornerRadius:2];
    [middle.layer setMasksToBounds:YES];
    [middle.layer setBorderColor:[UIColor whiteColor].CGColor];
    [middle.layer setBorderWidth:1];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, wei, size.height)];
    [lab setText:str];
    [lab setFont:font];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setNumberOfLines:0];
    [lab setTextColor:[UIColor whiteColor]];
    [middle addSubview:lab];
    
    UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, middle.frameBottom + 5, 28, 45.5)];
    [leftImg setImage:CREATE_IMG(@"navLeftDown")];
    
    UIImageView *rightImg = [[UIImageView alloc] initWithFrame:CGRectMake(middle.frameRight - 28, leftImg.frameY + 8, 48, 40)];
    [rightImg setImage:CREATE_IMG(@"navRightDown")];
    
    NSString *subTip = @"我知道了";
    size = [NSString calculeteSizeBy:subTip Font:font MaxWei:SCREEN_WIDTH];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:subTip forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTag:1];
    [button addTarget:self action:@selector(ihaveKnown:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(lab.frameRight - size.width, lab.frameBottom + 5, size.width, 18)];
    [middle addSubview:button];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, middle.frameWidth + 40, leftImg.frameBottom)];
    [backView addSubview:middle];
    [backView addSubview:leftImg];
    [backView addSubview:rightImg];
    
    return backView;
}

- (UIView *)customView2
{
    NSString *str = @"您可以点击这里关闭装订线提示功能";
    UIFont *font = [UIFont fontWithName:@"DFPShaoNvW5" size:14];
    //CGFloat wei = _targetImageView.frameRight - _swiBut.frameWidth / 2 - _swiBut.frameX - 20 - _leftBinding.frameWidth;
    CGSize size = [NSString calculeteSizeBy:str Font:font MaxWei:SCREEN_WIDTH];
    /*
    UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 39.5, 67)];
    leftImg.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [leftImg setImage:CREATE_IMG(@"navRightUp")];
    
    UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(_swiBut.frameWidth / 2, leftImg.frameBottom + 5, wei, 5 + size.height + 5 + 18 + 5)];
    [middle setBackgroundColor:[UIColor clearColor]];
    [middle.layer setCornerRadius:2];
    [middle.layer setMasksToBounds:YES];
    [middle.layer setBorderColor:[UIColor whiteColor].CGColor];
    [middle.layer setBorderWidth:1];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, wei - 10, size.height)];
    [lab setText:str];
    [lab setFont:font];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setNumberOfLines:0];
    [lab setTextColor:[UIColor whiteColor]];
    [middle addSubview:lab];
    
    NSString *subTip = @"我知道了";
    size = [NSString calculeteSizeBy:subTip Font:font MaxWei:SCREEN_WIDTH];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:subTip forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTag:2];
    [button addTarget:self action:@selector(ihaveKnown:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(lab.frameRight - size.width, lab.frameBottom + 5, size.width, 18)];
    [middle addSubview:button];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, middle.frameWidth, middle.frameBottom)];
    [backView addSubview:middle];
    [backView addSubview:leftImg];
     */
    UIImageView *leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(size.width + 5, 0, 39.5, 67)];
    //leftImg.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [leftImg setImage:CREATE_IMG(@"navRightUp")];
    
    UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, leftImg.frameBottom + 5, size.width + 10, 5 + size.height + 5 + 18 + 5)];
    [middle setBackgroundColor:[UIColor clearColor]];
    [middle.layer setCornerRadius:2];
    [middle.layer setMasksToBounds:YES];
    [middle.layer setBorderColor:[UIColor whiteColor].CGColor];
    [middle.layer setBorderWidth:1];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
    [lab setText:str];
    [lab setFont:font];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setNumberOfLines:0];
    [lab setTextColor:[UIColor whiteColor]];
    [middle addSubview:lab];
    
    NSString *subTip = @"我知道了";
    size = [NSString calculeteSizeBy:subTip Font:font MaxWei:SCREEN_WIDTH];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:subTip forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTag:2];
    [button addTarget:self action:@selector(ihaveKnown:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(lab.frameRight - size.width, lab.frameBottom + 5, size.width, 18)];
    [middle addSubview:button];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftImg.frameRight, middle.frameBottom)];
    [backView addSubview:middle];
    [backView addSubview:leftImg];
    
    return backView;
}

- (void)ihaveKnown:(id)sender
{
    NSInteger index = [sender tag] - 1;
    
    if (index == 0) {
        [[[sender superview] superview] setHidden:YES];
        UIView *custom = [self customView2];
        CGRect cusRect = CGRectMake(_swiBut.frameX + _swiBut.frameWidth / 2 -  custom.frameWidth, _swiBut.frameBottom + 5, custom.frameWidth, custom.frameHeight);
        [_holedView addHCustomView:custom onRect:cusRect];
    }
    else{
        [_holedView removeHoles];
        [_holedView removeFromSuperview];
        _holedView = nil;
    }
    
}

#pragma mark - 状态栏隐藏与样式
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - UI
- (void)targetViewCreate
{
    CGSize imgSize = _targerImg.size;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxHei = winSize.height - 20 - 44;
    _fRate = MIN((winSize.width - 20) / imgSize.width, maxHei / imgSize.height);
    CGFloat newMaxHei = winSize.height - 20 - 94 - 64 - 44;
    _newRate = MIN(winSize.width / imgSize.width, newMaxHei / imgSize.height);
    CGFloat imgWei = imgSize.width * _fRate;
    CGFloat imgHei = imgSize.height * _fRate;
    
    _targetImageView = [[UIImageView alloc] initWithFrame:CGRectMake((winSize.width - imgWei) / 2, (maxHei - imgHei) / 2 + 64, imgWei, imgHei)];
    _targetImageView.clipsToBounds = YES;
    [_targetImageView setUserInteractionEnabled:YES];
    [_targetImageView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_targetImageView];
    
    UIImageView *conImg = [[UIImageView alloc] initWithFrame:_targetImageView.bounds];
    [conImg setImage:_targerImg];
    [_targetImageView addSubview:conImg];
    
    //数据解析
    if (_growAlbum.template_detail) {
        id image_coor = [_growAlbum.template_detail valueForKey:@"image_coor"];
        if (image_coor && [image_coor count] > 0) {
            
            _allMakeViews = [[NSMutableArray alloc] init];
            
            for (NSInteger i = 0; i < [image_coor count]; i++) {
                NSDictionary *dic = [image_coor objectAtIndex:i];
                NSString *xValue = [dic valueForKey:@"x"];
                NSString *yValue = [dic valueForKey:@"y"];
                if ((!xValue || [xValue isKindOfClass:[NSNull class]] || [xValue isEqualToString:@""]) || (!yValue || [yValue isKindOfClass:[NSNull class]] || [yValue isEqualToString:@""])) {
                    continue;
                }
                NSArray *x = [xValue componentsSeparatedByString:@","];
                NSArray *y = [yValue componentsSeparatedByString:@","];
                
                CGRect rect = CGRectMake([x[0] floatValue] * _fRate, [x[1] floatValue] * _fRate, ([y[0] floatValue] - [x[0] floatValue]) * _fRate, ([y[1] floatValue] - [x[1] floatValue]) * _fRate);
                MakeView *makeView = [[MakeView alloc] initWithFrame:rect];
                makeView.fRate = _fRate * _targerImg.size.width / _tpl_width.floatValue;
                makeView.delegate = self;
                makeView.tag = 10 + i;
                
                if ([_growAlbum.src_gallery_list count] > i) {
                    NSMutableArray *tempArr = [NSMutableArray array];
                    for (NSDictionary *dic in _growAlbum.src_gallery_list[i]) {
                        SelectPhotosModel *photo = [[SelectPhotosModel alloc] init];
                        photo.type = [[dic valueForKey:@"file_type"] integerValue];
                        NSString *thumbStr = [dic valueForKey:@"image_thumb"];
                        if ([thumbStr isKindOfClass:[NSNull class]]) {
                            thumbStr = nil;
                        }
                        if (photo.type == 1) {
                            photo.videoStr = [dic valueForKey:@"file_path"];
                            photo.imgStr = thumbStr;
                        }else{
                            photo.imgStr = [dic valueForKey:@"file_path"];
                            CGFloat wei = 1000,hei = 1000;  //默认让它可以使用，如果未获取到的话
                            NSString *width = [dic valueForKey:@"width"],*height = [dic valueForKey:@"height"];
                            if ([width rangeOfString:@"null"].location == NSNotFound) {
                                wei = [width floatValue];
                                hei = [height floatValue];
                            }
                            photo.width = [NSNumber numberWithFloat:wei];
                            photo.height = [NSNumber numberWithFloat:hei];
                        }
                        
                        photo.thumb = thumbStr;
                        photo.isCover = [[dic valueForKey:@"is_cover"] integerValue];
                        if (photo.isCover) {
                            makeView.photoModel = photo;
                        }
                        [tempArr addObject:photo];
                    }
                    makeView.photosArray = tempArr;
                }
                else if ([_growAlbum.src_image_list count] > i) {
                    NSString *imgPath = [_growAlbum.src_image_list objectAtIndex:i];
                    NSString *videoPath = ([_growAlbum.src_video_list count] > i) ? [_growAlbum.src_video_list objectAtIndex:i] : nil;
                    NSString *h5Path = ([_growAlbum.src_h5_list count] > i) ? [_growAlbum.src_h5_list objectAtIndex:i] : nil;
                    SelectPhotosModel *photoModel = [[SelectPhotosModel alloc] init];
                    if ([h5Path length] > 0) {
                        photoModel.type = 2;
                        photoModel.videoStr = h5Path;
                        photoModel.imgStr = imgPath;
                    }
                    else if ([videoPath length] > 0) {
                        photoModel.type = 1;
                        photoModel.videoStr = videoPath;
                        photoModel.imgStr = imgPath;
                    }
                    else{
                        photoModel.imgStr = imgPath;
                    }
                    makeView.photoModel = photoModel;
                    makeView.photosArray = @[photoModel];
                }
                
                [_targetImageView addSubview:makeView];
                [_targetImageView sendSubviewToBack:makeView];
                [_allMakeViews addObject:makeView];
                
                
                UIView *preView = [[UIView alloc] initWithFrame:rect];
                preView.backgroundColor = [UIColor clearColor];
                preView.userInteractionEnabled = NO;
                preView.layer.masksToBounds = YES;
                preView.layer.borderWidth = 2;
                preView.layer.borderColor = CreateColor(244, 174, 97).CGColor;
                preView.tag = 100 + i;
                preView.hidden = YES;
                [_targetImageView addSubview:preView];
                
                //下载历史图片
                [self downHistoryImgs:i];
            }
        }
        
        //内嵌文字
        id word_coor = [_growAlbum.template_detail valueForKey:@"word_coor"];
        if (word_coor && [word_coor count] > 0) {
            for (NSInteger i = 0;i < [word_coor count];i++) {
                NSDictionary *dic = word_coor[i];
                NSString *xValue = [dic valueForKey:@"x"];
                NSString *yValue = [dic valueForKey:@"y"];
                if ((!xValue || [xValue isKindOfClass:[NSNull class]] || [xValue isEqualToString:@""]) || (!yValue || [yValue isKindOfClass:[NSNull class]] || [yValue isEqualToString:@""])) {
                    continue;
                }
                NSArray *x = [xValue componentsSeparatedByString:@","];
                NSArray *y = [yValue componentsSeparatedByString:@","];
                CGRect rect = CGRectMake([x[0] floatValue] * _fRate, [x[1] floatValue] * _fRate, ([y[0] floatValue] - [x[0] floatValue]) * _fRate, ([y[1] floatValue] - [x[1] floatValue]) * _fRate);
    
                UILabel *label = [[UILabel alloc] initWithFrame:rect];
                [label setBackgroundColor:[UIColor clearColor]];
                
                id size = [dic valueForKey:@"size"];
                NSString *default_txt = [dic valueForKey:@"default_txt"];
                label.text = (default_txt && [default_txt isKindOfClass:[NSString class]] && ([default_txt length] > 0)) ? default_txt : LABEL_TIP;
                NSString *color = [dic valueForKey:@"color"];
                CGFloat fontSize = 32;
                if (size && ![size isKindOfClass:[NSNull class]]) {
                    fontSize = [size integerValue];
                    if (fontSize == 0) {
                        fontSize = 12 / _fRate;
                    }
                }
                NSInteger lastSize = fontSize * _fRate;
                [label setFont:[UIFont systemFontOfSize:lastSize]];
                [label setTextColor:[UIColor colorWithHexString:color]];
                [label setUserInteractionEnabled:YES];
                [label setTag:i + 1];
                [label setNumberOfLines:0];
                label.layer.masksToBounds = YES;
                label.layer.borderWidth = 1.0;
                label.layer.borderColor = [UIColor clearColor].CGColor;
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabelView:)];
                [label addGestureRecognizer:tapGestureRecognizer];
                [_allFields addObject:label];
                [_targetImageView addSubview:label];
                
                //NSString *voice_flag = [dic valueForKey:@"voice_flag"];
                [_voiceUrlArray addObject:@""];
                [_loactionPathArray addObject:@""];
                if (_growAlbum.src_txt_list.count == [word_coor count]) {
                    NSString *txt = _growAlbum.src_txt_list[i];
                    if (![txt isKindOfClass:[NSNull class]]) {
                        if ([txt hasPrefix:@"["]) {
                            NSRange range = [txt rangeOfString:@"]"];
                            NSString * url = [txt substringWithRange:NSMakeRange(1,range.location - 1)];
                            if (![url hasPrefix:@"http"]) {
                                url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                            }
                            txt = [txt substringFromIndex:range.location + 1];
                            [_voiceUrlArray replaceObjectAtIndex:i withObject:url];
                            
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            [btn setFrame:CGRectMake(label.frame.origin.x - 50, label.frame.origin.y, 44, 17.5)];
                            [btn setTag:i + 1];
                            [btn setImage:CREATE_IMG(@"voice42") forState:UIControlStateNormal];
                            [btn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
                            [_targetImageView addSubview:btn];
                        }
                        [label setText:txt];
                    }
                }
            }
        }
        
        //素材
        NSInteger decoCount = _growAlbum.src_deco_list.count;
        if (_growAlbum.deco_detail_list.count == decoCount) {
            for (NSInteger i = 0; i < decoCount; i++) {
                NSString *decoDetail = _growAlbum.deco_detail_list[i];
                NSArray *decoArr = [decoDetail componentsSeparatedByString:@"_"];
                if ([decoArr count] == 5) {
                    NSString *url = _growAlbum.src_deco_list[i];
                    if (![url hasPrefix:@"http"]) {
                        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                    }
                    
                    CGRect rect = CGRectMake([decoArr[0] floatValue] * _fRate - 10, [decoArr[1] floatValue] * _fRate - 10, [decoArr[2] floatValue] * _fRate + 20, [decoArr[3] floatValue] * _fRate + 20);
                    CanCancelImageView *imageView = [[CanCancelImageView alloc] initWithFrame:rect];
                    imageView.delegate = self;
                    [imageView.contentImg setImageWithURL:[NSURL URLWithString:url]];
                    [imageView setBackgroundColor:[UIColor clearColor]];
                    imageView.imgPath = _growAlbum.src_deco_list[i];
                    [_targetImageView addSubview:imageView];
                    [_allImages addObject:imageView];
                    imageView.transform = CGAffineTransformRotate(imageView.transform, [decoArr[4] floatValue] * M_PI / 180);
                    imageView.nRotation = [decoArr[4] floatValue];
                    [imageView hiddenButton];
                }
            }
        }
        
        //自由文字
        NSInteger decoTxtCount = [_growAlbum.src_deco_txt_list count];
        if (decoTxtCount > 0) {
            for (NSInteger i = 0; i < decoTxtCount; i++) {
                NSDictionary *decoTxtDic = _growAlbum.src_deco_txt_list[i];
                NSString *detail = [decoTxtDic valueForKey:@"detail"];
                NSArray *decoArr = [detail componentsSeparatedByString:@"_"];
                if ([decoArr count] == 5) {
                    //alpha
                    NSString *alpha = [decoTxtDic valueForKey:@"alpha"];
                    CGFloat alphaColor = (alpha == nil) ? 1 : [alpha floatValue];
                    
                    //font
                    NSString *fontStr = [decoTxtDic valueForKey:@"font"];
                    NSString *font_key = ((fontStr.length > 0) && ![fontStr isEqualToString:@"default"]) ? fontStr : @"";
                    
                    //
                    UIFont *font = [NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[font_key stringByAppendingString:@".ttf"]] size:20];
                    NSString *txt = [decoTxtDic valueForKey:@"txt"] ?: @"";
                    NSString *color = [decoTxtDic valueForKey:@"color"];
                    UIImage *tmpImg = [self imageFromText:[txt componentsSeparatedByString:Seperate_RowStr] withFont:font Color:color Alpha:alphaColor];
                    CGFloat wei = [decoArr[2] floatValue] * _fRate,hei = tmpImg.size.height * wei / tmpImg.size.width;
                    CGFloat tmpScale = 10 * wei / tmpImg.size.width;
                    CGRect rect = CGRectMake([decoArr[0] floatValue] * _fRate - 10 - tmpScale, [decoArr[1] floatValue] * _fRate - 10 - tmpScale, wei + 20, hei + 20);
                    MyCustomTextView *imageView = [[MyCustomTextView alloc] initWithFrame:rect];
                    imageView.delegate = self;
                    imageView.colorStr = color;
                    imageView.alphaColor = alphaColor;
                    imageView.textStr = txt;
                    imageView.font_key = font_key;
                    [imageView.contentImg setImage:tmpImg];
                    [_targetImageView addSubview:imageView];
                    
                    [_allTxtImages addObject:imageView];
                    imageView.transform = CGAffineTransformRotate(imageView.transform, [decoArr[4] floatValue] * M_PI / 180);
                    imageView.nRotation = [decoArr[4] floatValue];
                    [imageView hiddenButton];
                }
            }
        }
    }
}

- (void)playVoice:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (!_editView) {
        _editView = [[EditTextView alloc] init];
        [_editView setLoactionPath:[_loactionPathArray objectAtIndex:[btn tag] - 1]];
        [_editView setVoiceUrl:[_voiceUrlArray objectAtIndex:[btn tag] - 1]];
    }
    [_editView playVoice:sender];
}

- (void)toolBarCreate
{
    // Toolbar
    _toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44.0, self.view.bounds.size.width, 44.0)];
    [_toolbar setBackgroundColor:[UIColor blackColor]];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(tapSelfView:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:_toolbar.bounds];
    [_toolbar addSubview:button];
    
    //贴纸
    CGFloat margin = 20;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setBackgroundColor:[UIColor clearColor]];
    CGFloat xOri = (winSize.width - margin - 50);
    [but setFrame:CGRectMake(xOri, 7, 50, 30)];
    [but setTag:1];
    [but setTitle:@"贴纸" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [but setTitleColor:CreateColor(244, 174, 97) forState:UIControlStateSelected];
    [but.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [but addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [but setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_toolbar addSubview:but];
    
    //文字
    UIButton *txtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [txtBtn setTitle:@"文字" forState:UIControlStateNormal];
    [txtBtn setBackgroundColor:[UIColor clearColor]];
    [txtBtn setFrame:CGRectMake(margin, 7, 50, 30)];
    [txtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [txtBtn setTitleColor:CreateColor(244, 174, 97) forState:UIControlStateHighlighted];
    [txtBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [txtBtn addTarget:self action:@selector(addTextByCustom:) forControlEvents:UIControlEventTouchUpInside];
    [txtBtn setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_toolbar addSubview:txtBtn];
    
    //line
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(winSize.width - margin - 50, 37, 50, 1)];
    [_lineView setBackgroundColor:CreateColor(244, 174, 97)];
    [_lineView setHidden:YES];
    [_toolbar addSubview:_lineView];
    
    [self.view addSubview:_toolbar];
    
    //edit
//    _editGrowBar = [[EditGrowBar alloc] initWithFrame:_toolbar.frame];
//    _editGrowBar.delegate = self;
}

/**
 *	@brief	装饰图片
 */
- (void)decorateViewCreate
{
    _decorateView = [[UIView alloc] initWithFrame:CGRectMake(0, _toolbar.frame.origin.y - 94.0, self.view.bounds.size.width, 94.0)];
    [_decorateView setBackgroundColor:[UIColor blackColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(tapSelfView:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:_decorateView.bounds];
    [_decorateView addSubview:button];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _toolbar.frame.size.width, 28)];
    [scrollView setTag:1];
    scrollView.showsHorizontalScrollIndicator = NO;
    [_decorateView addSubview:scrollView];
    
    
    CGFloat butWei = 50.0,butHei = 25.0;
    CGFloat minMargin = butWei;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    NSArray *array = [DJTGlobalManager shareInstance].userInfo.decorationArr;
    CGFloat margin = (winSize.width - array.count * butWei) / (array.count + 1);
    margin = MAX(minMargin, margin);
    for (NSInteger i = 0; i < array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(margin + (margin + butWei) * i, 2, butWei, butHei)];
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"an8" ofType:@"png"]] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitle:[[array[i] allKeys] firstObject] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:CreateColor(244, 174, 97) forState:UIControlStateSelected];
        button.selected = (i == _nSelectIdx);
        [button setTag:10 + i];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        //[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [button addTarget:self action:@selector(selectDecorateType:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
    }
    
    [scrollView setContentSize:CGSizeMake(MAX(winSize.width, margin + (margin + butWei) * array.count), scrollView.frame.size.height)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(56, 56);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 38, self.view.bounds.size.width, 56.0) collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"markGrowItemCell"];
    [_decorateView addSubview:_collectionView];
    [self.view addSubview:_decorateView];
}

- (void)createBookBinding{
    //装订线
    NSString *tipStr = @"装订线提示:";
    UIFont *tmpFont = [UIFont systemFontOfSize:14];
    CGSize tipSize = [NSString calculeteSizeBy:tipStr Font:tmpFont MaxWei:SCREEN_WIDTH];
    
    //UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(_targetImageView.frameX, (_targetImageView.frameY - 44 - 18) / 2 + 44, tipSize.width, 18)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(_targetImageView.frameRight - 35 - tipSize.width, (_targetImageView.frameY - 44 - 18) / 2 + 44, tipSize.width, 18)];
    [lab setFont:tmpFont];
    [lab setTextColor:[UIColor whiteColor]];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setText:tipStr];
    [lab setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:lab];
    
    UIButton *swi = [UIButton buttonWithType:UIButtonTypeCustom];
    [swi setFrame:CGRectMake(lab.frameRight, lab.frameY - 3.5, 35, 25)];
    [swi setImage:CREATE_IMG(@"swiOn") forState:UIControlStateSelected];
    [swi setImage:CREATE_IMG(@"swiOff") forState:UIControlStateNormal];
    [swi setImageEdgeInsets:UIEdgeInsetsMake(7, 0, 7, 0)];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL tip = [userDefault boolForKey:BookBindingSwi];
    swi.selected = !tip;
    _swiBut = swi;
    [swi addTarget:self action:@selector(changeLineShow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swi];
    
    UIImage *bindImg = CREATE_IMG(@"bookBinding");
    CGFloat wei = _targetImageView.frameWidth / 15/*,hei = 3470 * wei / 167*/;
    //CGFloat yOri = (_targetImageView.frameHeight - hei) / 2;
    _leftBinding = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wei, _targetImageView.frameHeight)];
    [_leftBinding setImage:bindImg];
    [_leftBinding setContentMode:UIViewContentModeScaleAspectFill];
    _leftBinding.clipsToBounds = YES;
    _leftBinding.hidden = tip;
    [_targetImageView addSubview:_leftBinding];
    
    _rightBinding = [[UIImageView alloc] initWithFrame:CGRectMake(_targetImageView.frameWidth - wei, 0, wei, _targetImageView.frameHeight)];
    [_rightBinding setImage:bindImg];
    _rightBinding.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [_leftBinding setContentMode:UIViewContentModeScaleAspectFill];
    _rightBinding.clipsToBounds = YES;
    _rightBinding.hidden = tip;
    [_targetImageView addSubview:_rightBinding];
}

#pragma mark - actions
- (void)changeLineShow:(UIButton *)swi
{
    //swi.on = !swi.on;
    swi.selected = !swi.selected;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:!swi.selected forKey:BookBindingSwi];
    _leftBinding.hidden = !swi.selected;
    _rightBinding.hidden = !swi.selected;
}

- (void)buttonPressed:(UIButton *)button
{
    NSArray *list = [DJTGlobalManager shareInstance].userInfo.decorationArr;
    if (!list || list.count == 0) {
        [self.view makeToast:@"对不起，未找到相应素材" duration:1.0 position:@"center"];
        return;
    }
    
    _touchView = nil;
    _targetImageView.userInteractionEnabled = NO;
    
    button.selected = !button.selected;
    if (button.selected) {
        if (!_decorateView) {
            [self decorateViewCreate];
        }
        else
        {
            [self.view addSubview:_decorateView];
        }
        
        _decorateView.alpha = 0;
        CGRect lineRec = _lineView.frame;
        [_lineView setFrame:CGRectMake(button.frame.origin.x, lineRec.origin.y, lineRec.size.width, lineRec.size.height)];
        _lineView.hidden = NO;
        _lineView.alpha = 0;
        
        CGFloat scale = _newRate / _fRate;
        [UIView animateWithDuration:0.35 animations:^(void) {
            [_decorateView setAlpha:1];
            _targetImageView.transform = CGAffineTransformMakeScale(scale,scale);
            _lineView.alpha = 1;
        } completion:^(BOOL finished) {
            [_targetImageView setUserInteractionEnabled:YES];
        }];
    }
    else{
        [UIView animateWithDuration:0.35 animations:^(void) {
            [_decorateView setAlpha:0];
            [_lineView setAlpha:0];
            _targetImageView.transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished) {
            [_decorateView removeFromSuperview];
            _lineView.hidden = YES;
            [_targetImageView setUserInteractionEnabled:YES];
        }];
    }
}

- (void)addTextByCustom:(id)sender
{
    if (!_lineView.hidden) {
        UIButton *rightBtn = (UIButton *)[_toolbar viewWithTag:1];
        rightBtn.selected = NO;
        [UIView animateWithDuration:0.35 animations:^(void) {
            [_decorateView setAlpha:0];
            [_lineView setAlpha:0];
            _targetImageView.transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished) {
            [_decorateView removeFromSuperview];
            _lineView.hidden = YES;
            [_targetImageView setUserInteractionEnabled:YES];
        }];
    }
    
    self.addTextController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:_addTextController.view];
    [self addChildViewController:_addTextController];
}

- (void)hideAllCancelButs
{
    //隐藏所有删除按钮项
    for (UIView *subView in _allImages) {
        if ([subView isKindOfClass:[CanCancelImageView class]]) {
            [(CanCancelImageView *)subView hiddenButton];
        }
    }
    
    for (UIView *subView in _allTxtImages) {
        if ([subView isKindOfClass:[CanCancelImageView class]]) {
            [(CanCancelImageView *)subView hiddenButton];
        }
    }
}

- (void)uploadSaved:(id)sender
{
    if (_editView && _editView.audioPlayer != nil && [_editView.audioPlayer isPlaying]) {
        [_editView.audioPlayer stop];
        _editView.audioPlayer = nil;
    }
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self disappearDecorateView:YES End:NULL];
}

- (void)selectDecorateType:(id)sender
{
    NSInteger index = [sender tag] - 10;
    if (index == _nSelectIdx) {
        return;
    }
    
    UIScrollView *scro = (UIScrollView *)[_decorateView viewWithTag:1];
    UIButton *preBut = (UIButton *)[scro viewWithTag:10 + _nSelectIdx];
    preBut.selected = NO;
    
    [(UIButton *)sender setSelected:YES];
    
    _nSelectIdx = index;
    [_collectionView reloadData];
}

- (void)tapSelfView:(id)sender
{
     //屏蔽self.view的触摸事件
}

- (void)tapLabelView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UILabel *label = (UILabel *)[tapGestureRecognizer  view];
    if (_responderLabel == label) {
        return;
    }
    //消除选择菜单的糅合
    [self disappearDecorateView:NO End:NULL];
    
    _targetImageView.userInteractionEnabled = NO;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = NO;
    
    if (_responderLabel) {
        _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
        if (_responderLabel.text.length == 0) {
            [_responderLabel setText:LABEL_TIP];
        }
    }
    _responderLabel = label;
    if (label.text && [label.text isEqualToString:LABEL_TIP]) {
        [label setText:@""];
    }
    _responderLabel.layer.borderColor = CreateColor(244, 174, 97).CGColor;
    
    NSArray *word_coor = [_growAlbum.template_detail valueForKey:@"word_coor"];
    NSDictionary *dic = word_coor[_responderLabel.tag - 1];
    NSString *max_num = [dic valueForKey:@"max_num"];
    if (!max_num || max_num.length == 0) {
        max_num = @"12";
    }
    NSString *voice_flag = [dic valueForKey:@"voice_flag"];
    int flag = (int)[voice_flag integerValue];
    
    _indexOffset = _targetImageView.frame.origin.y + label.frame.origin.y + label.frame.size.height;
    EditTextView *editView = [[EditTextView alloc] initWithFrame:[UIScreen mainScreen].bounds Voice_flag:flag Placeholder:[label text]];
    [editView setTag:[label tag]];
    _editView = editView;
    [editView setLoactionPath:[_loactionPathArray objectAtIndex:[label tag] - 1]];
    [editView setVoiceUrl:[_voiceUrlArray objectAtIndex:[label tag] - 1]];
    [editView setDelegate:self];
    [editView showInView:[self.view window]];
    [editView setLimitCount:[max_num integerValue]];
    NSString *voiceUrl = [_voiceUrlArray objectAtIndex:[label tag] - 1];
    if ([voiceUrl length] > 0) {
        [editView setInitData];
    }
    if (_indexOffset > SCREEN_HEIGHT - ((flag == 1) ? 160 : 90)) {
        //上移
        CGRect butRec = self.view.frame;
        [UIView animateWithDuration:0.35 animations:^{
            [self.view setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - (_indexOffset - (SCREEN_HEIGHT - ((flag == 1) ? 160 : 90))), butRec.size.width, butRec.size.height)];
        }];
    }
}

- (void)disappearDecorateView:(BOOL)shouldCommit End:(void (^)(void))completion
{
    if (_decorateView && [_decorateView isDescendantOfView:self.view]) {
        UIButton *midBut = (UIButton *)[_toolbar viewWithTag:2];
        [UIView animateWithDuration:0.35 animations:^(void) {
            self.navigationController.view.userInteractionEnabled = NO;
            [_decorateView setAlpha:0];
            [_lineView setAlpha:0];
            _targetImageView.transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished) {
            self.navigationController.view.userInteractionEnabled = YES;
            [_decorateView removeFromSuperview];
            _lineView.hidden = YES;
            midBut.selected = NO;
            if (shouldCommit) {
                [self startSave];
            }
            else if (completion){
                completion();
            }
        }];
    }
    else
    {
        if (shouldCommit) {
            [self startSave];
        }
        else if (completion){
            completion();
        }
    }
}

#pragma mark - 文本绘制
- (UIImage *)imageFromText:(NSArray *)arrContent withFont:(UIFont *)font Color:(NSString *)colorStr Alpha:(CGFloat)alpha
{
    NSMutableArray *arrHeight = [[NSMutableArray alloc] initWithCapacity:arrContent.count];
    
    CGFloat fHeight = 0.0f,newWei = 0;
    CGFloat maxWei = SCREEN_WIDTH * 2;
    NSDictionary *attribute = @{NSFontAttributeName:font};
    for (NSString *sContent in arrContent) {
        CGSize stringSize = [sContent boundingRectWithSize:CGSizeMake(maxWei, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        [arrHeight addObject:[NSNumber numberWithFloat:stringSize.height]];
        
        fHeight += stringSize.height;
        newWei = MAX(newWei, stringSize.width);
    }
    
    CGSize newSize = CGSizeMake(newWei + 20, fHeight + 20);
    NSString *textStr = [arrContent componentsJoinedByString:@"\n"];
    DecoTextView *decoView = [[DecoTextView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height) Text:textStr TextColor:[UIColor colorWithHexString:colorStr] Alpha:alpha Font:font];
    return [DecoTextView convertSelfToImage:decoView];
}

#pragma mark - AddTextViewControllerDelegate
- (void)addTextFinish:(AddTextViewController *)add Arr:(NSArray *)rows
{
    if (_addTextController.textStr.length > 0) {
        NSString *font_key = _addTextController.font_key ?: @"";
        UIFont *font = [NSString customFontWithPath:[APPDocumentsDirectory stringByAppendingPathComponent:[font_key stringByAppendingString:@".ttf"]] size:12];
        UIImage *tmpImg = [self imageFromText:rows withFont:font Color:_addTextController.color Alpha:_addTextController.alpha];
        CGFloat wei = tmpImg.size.width + 25,hei = tmpImg.size.height + 25;
        CGRect rect = CGRectMake((_targetImageView.bounds.size.width - wei) / 2, 40, wei, hei);
        MyCustomTextView *imageView = [[MyCustomTextView alloc] initWithFrame:rect];
        imageView.delegate = self;
        imageView.colorStr = _addTextController.color;
        imageView.alphaColor = _addTextController.alpha;
        imageView.font_key = font_key;
        NSString *textStr = [rows componentsJoinedByString:Seperate_RowStr];;
        imageView.textStr = textStr;
        
        [imageView.contentImg setImage:tmpImg];
        [_targetImageView addSubview:imageView];
        [_targetImageView bringSubviewToFront:_leftBinding];
        [_targetImageView bringSubviewToFront:_rightBinding];
        [_allTxtImages addObject:imageView];
        
    }
    if (_cusEditView) {
        [_cusEditView removeFromSuperview];
        [_allTxtImages removeObject:_cusEditView];
        _cusEditView = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
    [_addTextController.view removeFromSuperview];
    [_addTextController removeFromParentViewController];
    _addTextController = nil;
}

#pragma mark - EditTextViewDelegate
- (void)hiddenEditTextView:(EditTextView *)editTextView
{
    if (_responderLabel) {
        _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
        if (_responderLabel.text.length == 0) {
            _responderLabel.text = LABEL_TIP;
        }
        _responderLabel = nil;
        _targetImageView.userInteractionEnabled = YES;
        ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    }
    
    [_loactionPathArray replaceObjectAtIndex:[editTextView tag] - 1 withObject:editTextView.loactionPath];
    [_voiceUrlArray replaceObjectAtIndex:[editTextView tag] - 1 withObject:editTextView.voiceUrl];
    
    CGRect butRec = self.view.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [self.view setFrame:CGRectMake(butRec.origin.x, 0, butRec.size.width, butRec.size.height)];
    }];
}

- (void)showKeyboardEditTextView:(CGFloat)keyboard Height:(CGFloat)height
{
    if (_indexOffset > SCREEN_HEIGHT - height - keyboard) {
        //上移
        UIView *father = [self.view superview];
        CGRect newRect = CGRectMake(self.view.frame.origin.x, father.frame.size.height - (_indexOffset - (SCREEN_HEIGHT - height - keyboard)) - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        [UIView animateWithDuration:0.35 animations:^{
            [self.view setFrame:newRect];
        }];
    }
}

- (void)hideKeyboardEditTextView:(CGFloat)height
{
    //下移
    CGFloat _offSet = 0.0;
    if (_indexOffset > (SCREEN_HEIGHT - height)) {
        _offSet = _indexOffset - (SCREEN_HEIGHT - height);
    }
    UIView *father = [self.view superview];
    CGRect newRect = CGRectMake(self.view.frame.origin.x, father.frame.size.height - _offSet - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.35 animations:^{
        [self.view setFrame:newRect];
    }];
}

- (void)showEditTextContent:(NSString *)content
{
    if (![_responderLabel.text isEqualToString:content]) {
        [_responderLabel setText:content];
    }
}

#pragma mark - EditGrowBarDelegate
- (void)commitEditInfo:(NSString *)text
{
    [_editGrowBar.textField resignFirstResponder];
    if (![_responderLabel.text isEqualToString:_editGrowBar.textField.text]) {
        [_responderLabel setText:_editGrowBar.textField.text];
    }
    
    _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
    if (_responderLabel.text.length == 0) {
        _responderLabel.text = LABEL_TIP;
    }
    _responderLabel = nil;
    _targetImageView.userInteractionEnabled = YES;
    ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
}

#pragma mark - CanCancelImageViewDelegate
-(void)CancelImageView:(CanCancelImageView *)imageView
{
    [imageView removeFromSuperview];
    if ([imageView isKindOfClass:[MyCustomTextView class]]) {
        [_allTxtImages removeObject:imageView];
    }
    else{
        [_allImages removeObject:imageView];
    }
}

- (void)moveImageView:(CanCancelImageView *)imageView
{

}

- (void)editDecoTxtContent:(CanCancelImageView *)imageView
{
    _cusEditView = (MyCustomTextView *)imageView;
    self.navigationController.navigationBarHidden = YES;
    self.addTextController.delegate = self;
    _addTextController.textStr = [_cusEditView.textStr stringByReplacingOccurrencesOfString:Seperate_RowStr withString:@""];
    _addTextController.alpha = _cusEditView.alphaColor;
    _addTextController.color = _cusEditView.colorStr;
    _addTextController.font_key = _cusEditView.font_key;
    [self.view addSubview:_addTextController.view];
    [self addChildViewController:_addTextController];
}

#pragma mark - 原始图片上传
- (void)startSave
{
    [self hideAllCancelButs];
    
    if (_responderLabel) {
        [_editGrowBar.textField resignFirstResponder];
        _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
        _responderLabel = nil;
    }
    
    for (UILabel *label in _allFields) {
        if ([label.text isEqualToString:LABEL_TIP]) {
            [label setText:@""];
        }
    }
    
    for (NSInteger i = 0; i < _allMakeViews.count; i++) {
        UIView *preView = [_targetImageView viewWithTag:100 + i];
        preView.hidden = YES;
    }
    
    [self commitLastInfo];
}

#pragma mark - 下载历史图片
- (void)downHistoryImgs:(NSInteger)index
{
    if (!_growAlbum.src_image_list || ![_growAlbum.src_image_list isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if ([_growAlbum.src_image_list count] <= index) {
        return;
    }
    
    NSString *imgPath = [_growAlbum.src_image_list objectAtIndex:index];
    
    if (![imgPath hasPrefix:@"http"]) {
        imgPath = [G_IMAGE_ADDRESS stringByAppendingString:imgPath ?: @""];
    }
    
    if ([imgPath hasSuffix:@"mp4"]) {
        return;
    }
    
    NSURL *downUrl = [NSURL URLWithString:imgPath];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //下载
    @try {
        __weak typeof(self)weakSelf = self;
        [manager downloadWithURL:downUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [weakSelf downHistoryFinish:YES Img:image At:index];
                }
                else
                {
                    NSLog(@"%@",error.description);
                }
            });
            
        }];
    } @catch (NSException *e) {
        NSLog(@"%@",e.description);
    }
}

- (void)downHistoryFinish:(BOOL)suc Img:(UIImage *)img At:(NSInteger)index
{
    MakeView *makeView = _allMakeViews[index];
    if (!makeView.curImg) {
        [makeView resetImageView:img];
        if (_growAlbum.image_detail_list.count == _allMakeViews.count) {
            NSString *imgDetail = _growAlbum.image_detail_list[index];
            NSArray *frames = [imgDetail componentsSeparatedByString:@"_"];
            if (frames.count == 5) {
                CGFloat wei = [frames[2] floatValue] * _fRate;
                CGSize imgSize = img.size;
                CGFloat hei = wei * imgSize.height / imgSize.width;
                [makeView.curImg setFrame:CGRectMake([frames[0] floatValue] * _fRate - makeView.frameX, [frames[1] floatValue] * _fRate - makeView.frameY, wei, hei)];
                makeView.curImg.transform = CGAffineTransformRotate(makeView.curImg.transform, [frames[4] floatValue] * M_PI / 180);
                makeView.nRotation = [frames[4] floatValue];
            }
        }
    }
}

#pragma mark - 获取素材列表
- (void)getDecorationList
{
    NSDictionary *dic = @{@"page":@"1",@"page_num":@"100",@"mid":[DJTGlobalManager shareInstance].userInfo.mid};
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:decoration_list"];
    [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf requestDecorateFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf requestDecorateFinish:NO Data:nil];
    }];
}

- (void)requestDecorateFinish:(BOOL)suc Data:(id)result
{
    if (suc){
        id data = [result valueForKey:@"data"];
        if (data) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSMutableArray *set = [NSMutableArray array];
            NSArray *list = [data valueForKey:@"list"];
            list = (!list || [list isKindOfClass:[NSNull class]]) ? [NSArray array] : list;
            for (id subDic in list) {
                DecorateModel *deco = [[DecorateModel alloc] init];
                [deco reflectDataFromOtherObject:subDic];
    
                NSArray *keys = @[@"普通"];
                if ((deco.label && ![deco.label isKindOfClass:[NSNull class]]) && [deco.label length] != 0) {
                    keys = [deco.label componentsSeparatedByString:@","];
                }
                for (NSString *subKey in keys) {
                    if (![set containsObject:subKey]) {
                        [set addObject:subKey];
                    }
                    NSMutableArray *array = [dic objectForKey:subKey];
                    if (!array) {
                        array = [NSMutableArray array];
                        [dic setObject:array forKey:subKey];
                    }
                    [array addObject:deco];
                }
            }
            NSMutableArray *lastArr = [NSMutableArray array];
            for (NSString *key in set) {
                [lastArr addObject:@{key:[dic objectForKey:key]}];
            }
            [[DJTGlobalManager shareInstance].userInfo setDecorationArr:lastArr];
        }
    }
}

#pragma mark - 文件上传
- (void)commitLastInfo
{
    [self.view makeToastActivityToMsg:@"正在保存成长档案"];
    [self.navigationController.view setUserInteractionEnabled:NO];
    NSMutableArray *imgList = [NSMutableArray array];
    NSMutableArray *gallaryList = [NSMutableArray array];
    NSMutableArray *tmpMakeArr = [NSMutableArray array];
    for (NSInteger i = 0;i < _allMakeViews.count;i++) {
        MakeView *makeView = _allMakeViews[i];
        
        //图集
        NSMutableArray *photosList = [NSMutableArray array];
        for (SelectPhotosModel *item in makeView.photosArray) {
            if (item.type != 0) {
                [photosList addObject:item.videoStr ?: @""];
            }
            else{
                [photosList addObject:item.imgStr ?: @""];
            }
        }
        NSString *src_photos_list = [photosList componentsJoinedByString:@"|"];
        [gallaryList addObject:src_photos_list];
        
        //图片
        if (makeView.photoModel) {
            [imgList addObject:makeView.photoModel.imgStr];
        }
        else{
            [imgList addObject:@""];
        }
        
        //坐标
        if (makeView.curImg) {
            NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(makeView.center.x - makeView.bounds.size.width / 2 + makeView.curImg.center.x - makeView.curImg.bounds.size.width / 2) / _fRate, (makeView.center.y - makeView.bounds.size.height / 2 + makeView.curImg.center.y - makeView.curImg.bounds.size.height / 2) / _fRate, (makeView.curImg.bounds.size.width) / _fRate, (makeView.curImg.bounds.size.height) / _fRate, makeView.nRotation];
            [tmpMakeArr addObject:str];
        }
        else
        {
            [tmpMakeArr addObject:@""];
        }
    }
    
    DJTUser *user = [DJTGlobalManager shareInstance].userInfo;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"grow_id":_growId,@"templist_id":_templist_id,@"mid":user.mid,@"student_id":user.userid,@"school_id":user.school_id,@"class_id":user.class_id,@"template_id":_growAlbum.template_id}];
    NSString *src_image_list = [imgList componentsJoinedByString:@"|"];
    [dic setObject:src_image_list forKey:@"src_image_list"];
    NSString *src_gallary_list = [gallaryList componentsJoinedByString:@"#"];
    [dic setObject:src_gallary_list forKey:@"src_gallery_list"];
    [dic setObject:[tmpMakeArr componentsJoinedByString:@"|"] forKey:@"image_detail_list"];
    
    //文字与语音
    if (_allFields.count > 0) {
        NSMutableArray *tmpFieldArr = [NSMutableArray array];
        for (UILabel *label in _allFields) {
            NSArray *word_coor = [_growAlbum.template_detail valueForKey:@"word_coor"];
            NSDictionary *dic = word_coor[label.tag - 1];
            NSString *voice_flag = [dic valueForKey:@"voice_flag"];
            NSString *voiceUrl = @"";
            if ([voice_flag integerValue] == 1) {
                voiceUrl = [_voiceUrlArray objectAtIndex:[label tag] - 1];
                if ([voiceUrl length] > 0) {
                    voiceUrl = [NSString stringWithFormat:@"[%@]",voiceUrl];
                }
            }
            NSString *tip = (([label.text length] > 0) && ![label.text isEqualToString:LABEL_TIP]) ? [voiceUrl stringByAppendingString:label.text] : voiceUrl;
            [tmpFieldArr addObject:tip];
        }
    
        [dic setObject:[tmpFieldArr componentsJoinedByString:@"|"] forKey:@"src_txt_list"];
    }

    //素材
    if (_allImages.count > 0) {
        NSMutableArray *tmpCancelArr = [NSMutableArray array];
        NSMutableArray *decoList = [NSMutableArray array];
        for (CanCancelImageView *canImg in _allImages) {
            NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(canImg.center.x - canImg.bounds.size.width / 2 + canImg.contentImg.center.x - canImg.contentImg.bounds.size.width / 2) / _fRate, (canImg.center.y - canImg.bounds.size.height / 2 + canImg.contentImg.center.y - canImg.contentImg.bounds.size.height / 2) / _fRate, (canImg.contentImg.bounds.size.width) / _fRate, (canImg.contentImg.bounds.size.height) / _fRate, canImg.nRotation];
            [tmpCancelArr addObject:str];
            [decoList addObject:canImg.imgPath];
        }
        [dic setObject:[tmpCancelArr componentsJoinedByString:@"|"] forKey:@"deco_detail_list"];
        [dic setObject:[decoList componentsJoinedByString:@"|"] forKey:@"src_deco_list"];
    }
    
    //自由文字
    if (_allTxtImages.count > 0) {
        NSMutableArray *decoTxtArr = [NSMutableArray array];
        for (MyCustomTextView *cancel in _allTxtImages) {
            CGFloat tmpScale = 10 * cancel.contentImg.bounds.size.width / cancel.contentImg.image.size.width;
            NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(cancel.center.x - cancel.bounds.size.width / 2 + cancel.contentImg.center.x - cancel.contentImg.bounds.size.width / 2 + tmpScale) / _fRate, (cancel.center.y - cancel.bounds.size.height / 2 + cancel.contentImg.center.y - cancel.contentImg.bounds.size.height / 2 + tmpScale) / _fRate, (cancel.contentImg.bounds.size.width - 2 * tmpScale) / _fRate, (cancel.contentImg.bounds.size.height - 2 * tmpScale) / _fRate, cancel.nRotation];
            NSDictionary *tmpDic = @{@"txt":cancel.textStr ?: @"",@"detail":str,@"color":cancel.colorStr,@"font":(cancel.font_key.length > 0) ? cancel.font_key : @"default",@"alpha":[[NSNumber numberWithFloat:cancel.alphaColor] stringValue]};
//            NSString *jsonString = [NSString dictToJsonStr:tmpDic];
//            [decoTxtArr addObject:jsonString];
            [decoTxtArr addObject:tmpDic];
        }
//        NSString *src_deco_txt_list = [NSString stringWithFormat:@"[%@]",[decoTxtArr componentsJoinedByString:@","]];
//        [dic setObject:src_deco_txt_list forKey:@"src_deco_txt_list"];
        [dic setObject:decoTxtArr forKey:@"src_deco_txt_list"];
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"grow:hb_save_v3"];
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf commitInfoFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf commitInfoFinish:NO Data:nil];
    }];
}

- (void)commitInfoFinish:(BOOL)suc Data:(id)data
{
    [self.view hideToastActivity];
    self.httpOperation = nil;
    [self.navigationController.view setUserInteractionEnabled:YES];

    if (suc) {
        //图片，图片坐标与图集
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        NSMutableArray *src_image_list = [NSMutableArray array];
        NSMutableArray *src_gallary_list = [NSMutableArray array];
        NSMutableArray *tmpMakeArr = [NSMutableArray array];
        for (NSInteger i = 0;i < _allMakeViews.count;i++) {
            MakeView *makeView = _allMakeViews[i];
            
            //图集数组
            NSMutableArray *tempArr = [NSMutableArray array];
            for (SelectPhotosModel *item in makeView.photosArray) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if (item.type != 0) {
                    [dic setObject:item.videoStr ?: @"" forKey:@"file_path"];
                    [dic setObject:@"1" forKey:@"file_type"];
                }
                else{
                    [dic setObject:item.imgStr ?: @"" forKey:@"file_path"];
                    [dic setObject:@"0" forKey:@"file_type"];
                }
                [dic setObject:item.isCover ? @"1" : @"0" forKey:@"is_cover"];
                if (item.thumb.length > 0) {
                    [dic setObject:item.thumb forKey:@"image_thumb"];
                }
                if (item.width && item.height) {
                    [dic setObject:item.width.stringValue forKey:@"width"];
                    [dic setObject:item.height.stringValue forKey:@"height"];
                }
                [tempArr addObject:dic];
            }
            [src_gallary_list addObject:tempArr];
            
            //图片数组
            if (makeView.photoModel) {
                [src_image_list addObject:makeView.photoModel.imgStr];
            }
            else{
                [src_image_list addObject:@""];
            }
            
            //坐标数组
            if (makeView.curImg) {
                NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(makeView.center.x - makeView.bounds.size.width / 2 + makeView.curImg.center.x - makeView.curImg.bounds.size.width / 2) / _fRate, (makeView.center.y - makeView.bounds.size.height / 2 + makeView.curImg.center.y - makeView.curImg.bounds.size.height / 2) / _fRate, (makeView.curImg.bounds.size.width) / _fRate, (makeView.curImg.bounds.size.height) / _fRate, makeView.nRotation];
                [tmpMakeArr addObject:str];
            }
            else
            {
                [tmpMakeArr addObject:@""];
            }
        }
        
        [param setObject:src_image_list forKey:@"src_image_list"];
        [param setObject:src_gallary_list forKey:@"src_gallery_list"];
        [param setObject:tmpMakeArr forKey:@"image_detail_list"];
        
        //文字与语音
        if (_allFields.count > 0) {
            NSMutableArray *tmpFieldArr = [NSMutableArray array];
            for (UILabel *label in _allFields) {
                NSArray *word_coor = [_growAlbum.template_detail valueForKey:@"word_coor"];
                NSDictionary *dic = word_coor[label.tag - 1];
                NSString *voice_flag = [dic valueForKey:@"voice_flag"];
                NSString *voiceUrl = @"";
                if ([voice_flag integerValue] == 1) {
                    voiceUrl = [_voiceUrlArray objectAtIndex:[label tag] - 1];
                    if ([voiceUrl length] > 0) {
                        voiceUrl = [NSString stringWithFormat:@"[%@]",voiceUrl];
                    }
                }
                NSString *tip = (([label.text length] > 0) && ![label.text isEqualToString:LABEL_TIP]) ? [voiceUrl stringByAppendingString:label.text] : voiceUrl;
                [tmpFieldArr addObject:tip];
            }
            [param setObject:tmpFieldArr forKey:@"src_txt_list"];
        }
        
        //素材
        if (_allImages.count > 0) {
            NSMutableArray *tmpCancelArr = [NSMutableArray array];
            NSMutableArray *decoList = [NSMutableArray array];
            for (CanCancelImageView *canImg in _allImages) {
                NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(canImg.center.x - canImg.bounds.size.width / 2 + canImg.contentImg.center.x - canImg.contentImg.bounds.size.width / 2) / _fRate, (canImg.center.y - canImg.bounds.size.height / 2 + canImg.contentImg.center.y - canImg.contentImg.bounds.size.height / 2) / _fRate, (canImg.contentImg.bounds.size.width) / _fRate, (canImg.contentImg.bounds.size.height) / _fRate, canImg.nRotation];
                [tmpCancelArr addObject:str];
                [decoList addObject:canImg.imgPath];
            }
            [param setObject:tmpCancelArr forKey:@"deco_detail_list"];
            [param setObject:decoList forKey:@"src_deco_list"];
        }
        
        //自由文字
        if (_allTxtImages.count > 0) {
            NSMutableArray *decoTxtArr = [NSMutableArray array];
            for (MyCustomTextView *cancel in _allTxtImages) {
                CGFloat tmpScale = 10 * cancel.contentImg.bounds.size.width / cancel.contentImg.image.size.width;
                NSString *str = [NSString stringWithFormat:@"%.4f_%.4f_%.4f_%.4f_%.4f",(cancel.center.x - cancel.bounds.size.width / 2 + cancel.contentImg.center.x - cancel.contentImg.bounds.size.width / 2 + tmpScale) / _fRate, (cancel.center.y - cancel.bounds.size.height / 2 + cancel.contentImg.center.y - cancel.contentImg.bounds.size.height / 2 + tmpScale) / _fRate, (cancel.contentImg.bounds.size.width - 2 * tmpScale) / _fRate, (cancel.contentImg.bounds.size.height - 2 * tmpScale) / _fRate, cancel.nRotation];
                NSDictionary *tmpDic = @{@"txt":cancel.textStr ?: @"",@"detail":str,@"color":cancel.colorStr,@"font":(cancel.font_key.length > 0) ? cancel.font_key : @"default",@"alpha":[[NSNumber numberWithFloat:cancel.alphaColor] stringValue]};
                [decoTxtArr addObject:tmpDic];
            }
            [param setObject:decoTxtArr forKey:@"src_deco_txt_list"];
        }
        
        //返回数据
        id result = [data valueForKey:@"data"];
        NSString *image_url = [result valueForKey:@"image_url"];
        NSString *image_thumb_url = [result valueForKey:@"image_thumb_url"];
        
        if (_delegate && [_delegate respondsToSelector:@selector(makeFinishImg:Data:url:)]) {
            [_delegate makeFinishImg:image_thumb_url Data:param url:image_url];
        }
        else{
            [self.view.window makeToast:@"保存成功" duration:1.0 position:@"center"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        NSString *msg = [data valueForKey:@"message"];
        NSString *tip = msg ?: @"图片信息提交失败";
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
}

#pragma mark - 状态栏与导航栏的隐藏与显示动作
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_responderLabel) {
        //[_editGrowBar.textField resignFirstResponder];
        _responderLabel.layer.borderColor = [UIColor clearColor].CGColor;
        if (_responderLabel.text.length == 0) {
            _responderLabel.text = LABEL_TIP;
        }
        _responderLabel = nil;
        _targetImageView.userInteractionEnabled = YES;
        ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).enabled = YES;
    }
    else
    {
        [self hideAllCancelButs];
        BOOL navHidden = (self.navigationController.navigationBar.alpha == 0);
        [self setControlsHidden:!navHidden animated:YES];
    }
}

#pragma mark - pravite
- (void)resetImageSource:(SelectPhotosModel *)photoModel To:(MakeView *)makeView
{
    makeView.photoModel = photoModel;
    [makeView resetImageView:[UIImage imageWithContentsOfFile:photoModel.imageFileStr]];
}

#pragma mark - 状态栏与导航栏的隐藏与消失
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated
{
    // Animations & positions
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    [UIView animateWithDuration:animationDuration animations:^(void) {
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {}];
    
    self.view.userInteractionEnabled = NO;
    BOOL decShow = (_decorateView && [_decorateView isDescendantOfView:self.view]);
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        CGFloat alpha = hidden ? 0 : 1;
        
        // Nav bar slides up on it's own on iOS 7
        [self.navigationController.navigationBar setAlpha:alpha];
        
        [_toolbar setAlpha:alpha];
        
        if (decShow) {
            [_decorateView setAlpha:alpha];
            CGFloat scale = (alpha == 1) ? (_newRate / _fRate) : 1;
            _targetImageView.transform = CGAffineTransformMakeScale(scale,scale);
        }
        
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
    
}

#pragma mark - SelectPhotosViewControllerDelegate
- (void)selectPhotosImages:(NSArray *)images
{
    [self.navigationController popToViewController:self animated:YES];
    
    if (_touchView) {
        for (SelectPhotosModel *item in images) {
            if (item.isCover) {
                if (![item.imgStr isEqualToString:_touchView.photoModel.imgStr]) {
                    [self resetImageSource:item To:_touchView];
                }
                else{
                    _touchView.photoModel = item;
                }
                break;
            }
        }
        _touchView.photosArray = images;
        return;
    }
    
    NSInteger count = [images count];
    for (int i = 0; i < [_allMakeViews count]; i++) {
        MakeView *makeView = _allMakeViews[i];
        if (i > count - 1) {
            makeView.photoModel = nil;
            makeView.photosArray = nil;
        }
        else
        {
            [self resetImageSource:images[i] To:makeView];
            makeView.photosArray = images;
        }
    }
}

#pragma mark - MakeViewDelegate
- (void)touchMakeView:(MakeView *)makeView
{
    _touchView = makeView;
    for (MakeView *subView in _allMakeViews) {
        UIView *preView = [_targetImageView viewWithTag:subView.tag + 90];
        preView.hidden = (subView != makeView);
    }
    
    if (!makeView.curImg.image) {
        SelectPhotosViewController *selectPic = [[SelectPhotosViewController alloc] init];
        selectPic.nMaxCount = 9;
        CGFloat largeScale = _fRate * _targerImg.size.width / _tpl_width.floatValue;
        selectPic.minWei = (_touchView.bounds.size.width / largeScale) / sqrt(2);
        selectPic.minHei = (_touchView.bounds.size.height / largeScale) / sqrt(2);
        selectPic.delegate = self;
        selectPic.album_id = _album_id;
        selectPic.buttonTitle = _album_title;
        selectPic.selectArray = _touchView.photosArray;
        selectPic.isSmallPicLimit = _isSmallPicLimit;
        [self.navigationController pushViewController:selectPic animated:YES];
    }
    else{
        __weak typeof(self)weakSelf = self;
        [self disappearDecorateView:NO End:^{
            [weakSelf addMenuView];
        }];
    }
}

- (void)addMenuView
{
    UIView *fullView = [[UIView alloc] initWithFrame:self.view.bounds];
    [fullView setBackgroundColor:[UIColor clearColor]];
    [fullView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFullView:)]];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapFullView:)];
    [fullView addGestureRecognizer:panGestureRecognizer];
    [self.view.window addSubview:fullView];
    self.view.window.userInteractionEnabled = NO;
    
    NSArray *nImgs = @[@"growAlbumN",@"growRotationN",@"growScaleDivN",@"growScaleAddN",@"mulVideoPlayN"];
    NSArray *hImgs = @[@"growAlbumH",@"growRotationH",@"growScaleDivH",@"growScaleAddH",@"mulVideoPlayH"];
    NSInteger count = 5;
    if ([_touchView.photosArray count] == 0) {
        count = 4;
    }
    else if ([_touchView.photosArray count] == 1) {
        SelectPhotosModel *photoModel = [_touchView.photosArray lastObject];
        if (photoModel.type == 0) {
            count = 4;
        }
    }
    CGFloat itemWei = 34, itemHei = itemWei, wei = count *itemWei,hei = itemHei;
    CGFloat tipX = _targetImageView.frameX + _touchView.center.x - wei / 2,tipY = _targetImageView.frameY + _touchView.frameBottom - hei / 2;
    tipX = MIN(MAX(0, tipX), _targetImageView.frame.size.width - wei);
    tipY = MIN(MAX(0, tipY),_targetImageView.frame.size.height - hei);
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(tipX, tipY, wei, hei)];
    tipView.backgroundColor = [UIColor blackColor];
    tipView.layer.masksToBounds = YES;
    tipView.layer.cornerRadius = 2;
    [tipView setAlpha:0];
    [fullView addSubview:tipView];
    for (NSInteger i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(itemWei * i, 0, itemWei, itemHei)];
        [button setBackgroundColor:tipView.backgroundColor];
        [button setImage:CREATE_IMG(nImgs[i]) forState:UIControlStateNormal];
        [button setImage:CREATE_IMG(hImgs[i]) forState:UIControlStateHighlighted];
        [button setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        [button setTag:i + 1];
        [button addTarget:self action:@selector(pressedMakeMenu:) forControlEvents:UIControlEventTouchUpInside];
        [tipView addSubview:button];
    }
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(tipView)weakTip = tipView;
    [UIView animateWithDuration:0.35 animations:^{
        [weakTip setAlpha:1];
    } completion:^(BOOL finished) {
        weakSelf.view.window.userInteractionEnabled = YES;
    }];
}

- (void)tapFullView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIView *fullView = [tapGestureRecognizer view];
    [self removeFullView:fullView Animation:YES];
}

- (void)removeFullView:(UIView *)view Animation:(BOOL)animation
{
    if (animation) {
        self.view.window.userInteractionEnabled = NO;
        __weak typeof(self)weakSelf = self;
        __weak typeof(view)weakFull = view;
        [UIView animateWithDuration:0.35 animations:^{
            weakFull.alpha = 0;
        } completion:^(BOOL finished) {
            [weakFull removeFromSuperview];
            weakSelf.view.window.userInteractionEnabled = YES;
        }];
    }
    else
    {
        [view removeFromSuperview];
    }
}

- (void)pressedMakeMenu:(id)sender
{
    switch ([sender tag] - 1) {
        case 0:
        {
            [self removeFullView:[[sender superview] superview] Animation:NO];
            SelectPhotosViewController *selectPic = [[SelectPhotosViewController alloc] init];
            selectPic.nMaxCount = 9;
            CGFloat largeScale = _fRate * _targerImg.size.width / _tpl_width.floatValue;
            selectPic.minWei = (_touchView.bounds.size.width / largeScale) / sqrt(2);
            selectPic.minHei = (_touchView.bounds.size.height / largeScale) / sqrt(2);
            selectPic.delegate = self;
            selectPic.album_id = _album_id;
            selectPic.buttonTitle = _album_title;
            selectPic.selectArray = _touchView.photosArray;
            selectPic.isSmallPicLimit = _isSmallPicLimit;
            [self.navigationController pushViewController:selectPic animated:YES];
        }
            break;
        case 1:
        {
            if (_touchView.curImg) {
                _touchView.curImg.transform = CGAffineTransformRotate(_touchView.curImg.transform, M_PI * 90.0 / 180);
                double radians = atan2(_touchView.curImg.transform.b, _touchView.curImg.transform.a);
                _touchView.nRotation = radians * (180 / (CGFloat)M_PI);
                [self hasChangeState:_touchView];
            }
        }
            break;
        case 2:
        {
            if (_touchView.curImg) {
                [_touchView beginScale:2.0 / 3];
                [self hasChangeState:_touchView];
            }
        }
            break;
        case 3:
        {
            if (_touchView.curImg) {
                [_touchView beginScale:4.0 / 3];
                [self hasChangeState:_touchView];
            }
        }
            break;
        case 4:
        {
            [self removeFullView:[[sender superview] superview] Animation:NO];
            if ([_browserPhotos count] > 0) {
                [_browserPhotos removeAllObjects];
            }
            for (SelectPhotosModel *item in _touchView.photosArray) {
                MWPhoto *photo;
                NSURL *videoURL = nil;
                if (item.videoFileStr.length > 0) {
                    videoURL = [NSURL fileURLWithPath:item.videoFileStr];
                }
                else{
                    NSString *path = item.videoStr;
                    if (![path hasPrefix:@"http"]) {
                        path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
                    }
                    videoURL = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                if (item.type == 1) {
                    if (item.imageFileStr.length > 0) {
                        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:item.imageFileStr]];
                    }
                    else if (item.imgStr.length > 0) {
                        NSString *url = item.imgStr;
                        if (![url hasPrefix:@"http"]) {
                            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                        }
                        CGFloat scale_screen = [UIScreen mainScreen].scale;
                        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                        url = [NSString getPictureAddress:@"2" width:width height:@"0" original:url];
                        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else if (item.thumbImg){
                        photo = [MWPhoto photoWithImage:item.thumbImg];
                    }
                    else if (item.thumb.length > 0){
                        NSString *url = item.thumb;
                        if (![url hasPrefix:@"http"]) {
                            url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
                        }
                        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                    else{
                        photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:videoURL]];
                    }
                    
                    photo.videoUrl = videoURL;
                    photo.isVideo = YES;
                }
                else{
                    if (item.imageFileStr) {
                        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:item.imageFileStr]];
                    }
                    else{
                        NSString *path = item.imgStr;
                        if (![path hasPrefix:@"http"]) {
                            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
                        }
                        CGFloat scale_screen = [UIScreen mainScreen].scale;
                        NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
                        path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
                        photo = [MWPhoto photoWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                        
                    }
                }
                [_browserPhotos addObject:photo];
            }
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayNavArrows = YES;
            browser.displayActionButton = NO;
            [self.navigationController pushViewController:browser animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)movieFinishedCallback:(NSNotification*)notify {
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    [theMovie.view removeFromSuperview];
    
    self.movieController = nil;
}

- (void)hasChangeState:(MakeView *)makeView
{

}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _browserPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _browserPhotos.count)
        return [_browserPhotos objectAtIndex:index];
    return nil;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = [DJTGlobalManager shareInstance].userInfo.decorationArr;
    NSDictionary *dic = array[_nSelectIdx];
    
    return [[[dic allValues] firstObject] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"markGrowItemCell" forIndexPath:indexPath];

    UIImageView *curImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (!curImg) {
        //back
        UIImageView *preImg = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [preImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [preImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"an7" ofType:@"png"]]];
        [cell.contentView addSubview:preImg];
        
        //face
        curImg = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 54, 54)];
        [curImg setContentMode:UIViewContentModeScaleAspectFit];
        //curImg.clipsToBounds = YES;
        [curImg setTag:1];
        [cell.contentView addSubview:curImg];
    }
    
    NSArray *array = [DJTGlobalManager shareInstance].userInfo.decorationArr;
    NSDictionary *dic = array[_nSelectIdx];
    NSArray *lstArr = [[dic allValues] firstObject];
    DecorateModel *deco = lstArr[indexPath.item];
    NSString *url = deco.image_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_GROW_ADDRESS stringByAppendingString:url ?: @""];
    }
    [curImg setImageWithURL:[NSURL URLWithString:url]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *curImg = (UIImageView *)[cell.contentView viewWithTag:1];
    if (curImg.image) {
        [self hideAllCancelButs];
        CGSize size = curImg.image.size;
        CGFloat wei = MAX(size.width * _newRate, MIN_WEIGHT);
        CGFloat hei = wei * size.height / size.width;
        if (hei < MIN_HEIGHT) {
            hei = MIN_HEIGHT;
            wei = hei * size.width / size.height;
        }
        
        NSArray *array = [DJTGlobalManager shareInstance].userInfo.decorationArr;
        NSDictionary *dic = array[_nSelectIdx];
        NSArray *lstArr = [[dic allValues] firstObject];
        DecorateModel *deco = lstArr[indexPath.item];
        NSString *url = deco.image_url;

        CanCancelImageView *imageView = [[CanCancelImageView alloc] initWithFrame:CGRectMake(0, 0, wei + 20, hei + 20)];
        imageView.delegate = self;
        [imageView setCenter:CGPointMake(_targetImageView.bounds.size.width / 2, _targetImageView.bounds.size.height / 2)];
        [imageView.contentImg setImage:curImg.image];
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.imgPath = url;
        [_targetImageView addSubview:imageView];
        [_targetImageView bringSubviewToFront:_leftBinding];
        [_targetImageView bringSubviewToFront:_rightBinding];
        [_allImages addObject:imageView];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1;
}

#pragma mark - lazy load
- (AddTextViewController *)addTextController
{
    if (!_addTextController) {
        _addTextController = [[AddTextViewController alloc] init];
        _addTextController.maxWei = _targetImageView.bounds.size.width * 0.9;
    }
    return _addTextController;
}

@end
