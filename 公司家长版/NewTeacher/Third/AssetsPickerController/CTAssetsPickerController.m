
/*
 CTAssetsPickerController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import "CTAssetsPickerController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "MWPhotoBrowser.h"
#import "ProgressCircleView.h"
#import "UIImage+Caption.h"
#import "UIImage+FixOrientation.h"
#import "DJTGlobalManager.h"
#import "PlayViewController.h"

#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)


#pragma mark - Interfaces

@interface CTAssetsPickerController ()

@end

@protocol CTAssetsViewCellDelegate <NSObject>

- (void)checkSelectCell:(UICollectionViewCell *)cell;

@end

@interface CTAssetsViewController : UICollectionViewController<MWPhotoBrowserDelegate,CTAssetsViewCellDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetsModels;
@property (nonatomic, strong) NSMutableArray *uploadArr;
@property (nonatomic, strong) NSMutableArray *netSource;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@interface CTAssetsViewController ()

@property (nonatomic, strong) NSMutableArray *assetArr;
@property (nonatomic, assign) NSInteger assetsCount;

@end

@interface CTAssetsViewCell : UICollectionViewCell

@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UIImageView *hdImg;

- (void)bind:(ALAsset *)asset All:(BOOL)selectAll Min:(CGFloat)minWei Hei:(CGFloat)minHei;

@end

@interface CTAssetsViewCell ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) id<CTAssetsViewCellDelegate> delegate;

@end

#pragma mark - CTAssetsPickerController


@implementation CTAssetsPickerController

@dynamic delegate;

- (id)init
{
    CTAssetsViewController *assetViewController = [[CTAssetsViewController alloc] init];
    
    if (self = [super initWithRootViewController:assetViewController])
    {
        _maximumNumberOfSelection   = NSIntegerMax;
        _assetsFilter               = [ALAssetsFilter allAssets];
        _showsCancelButton          = YES;
    }
    
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end


#pragma mark - CTAssetsViewController

#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"

@implementation CTAssetsViewController
{
    NSMutableArray *_selectAssets,*_sourceArr,*_mwphotos;
    NSInteger _selectIdx;
    UIButton *_finishBut;
    BOOL _shouldTip;
    
    ProgressCircleView *_progressView;
    NSIndexPath *_indexPath;
}

- (void)dealloc{
    if (_operationQueue) {
        [_operationQueue cancelAllOperations];
    }
}

- (id)init
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = kThumbnailSize;
    layout.minimumInteritemSpacing      = 2.0;
    layout.minimumLineSpacing           = 2.0;
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 26);
    
    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 2, 0)];
        [self.collectionView registerClass:[CTAssetsViewCell class] forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAssetsSupplementaryViewIdentifier];
        
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectAssets = [NSMutableArray array];
    _sourceArr = [NSMutableArray array];
    _selectIdx = 0;
    [self setupViews];
    [self localize];
    [self setupGroup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = [UIColor whiteColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor whiteColor];
    }
    else
    {
        navBar.tintColor = CreateColor(233.0, 233.0, 233.0);
    }
}

- (void)localize
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 100, 24)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
    [titleLabel setText:@"图片与视频"];
    [titleLabel setTextAlignment:1];
    
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)setupGroup
{
    if (!self.assetsLibrary)
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    
    if (!self.assetsModels)
        self.assetsModels = [[NSMutableArray alloc] init];
    else
        [self.assetsModels removeAllObjects];
    
    __weak typeof(self)weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
        
        ALAssetsGroupEnumerationResultsBlock assetsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset)
            {
                NSDate *curDate = [asset valueForProperty:ALAssetPropertyDate];
                NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyyMMdd" Date:curDate];
                
                if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    NSMutableArray *tmpArr = [tmpDic valueForKey:nsALAssetPropertyDate];
                    if (!tmpArr) {
                        tmpArr = [NSMutableArray array];
                        [tmpDic setObject:tmpArr forKey:nsALAssetPropertyDate];
                        [tmpArr addObject:asset];
                    }
                    else{
                        BOOL hasFound = NO;
                        for (ALAsset *subAsset in tmpArr) {
                            NSDate *subDate = [subAsset valueForProperty:ALAssetPropertyDate];
                            if ([subDate timeIntervalSinceDate:curDate] == 0) {
                                hasFound = YES;
                                break;
                            }
                        }
                        if (!hasFound) {
                            [tmpArr addObject:asset];
                        }
                    }
                }
                else if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                    //ALAssetRepresentation *representation = [asset defaultRepresentation];
                    //BOOL isMP4 = [representation.url.resourceSpecifier hasSuffix:@"mp4"];
                    //if (!isMP4){
                        NSMutableArray *tmpArr = [tmpDic valueForKey:nsALAssetPropertyDate];
                        if (!tmpArr) {
                            tmpArr = [NSMutableArray array];
                            [tmpDic setObject:tmpArr forKey:nsALAssetPropertyDate];
                            [tmpArr addObject:asset];
                        }
                        else{
                            BOOL hasFound = NO;
                            for (ALAsset *subAsset in tmpArr) {
                                NSDate *subDate = [subAsset valueForProperty:ALAssetPropertyDate];
                                if ([subDate timeIntervalSinceDate:curDate] == 0) {
                                    hasFound = YES;
                                    break;
                                }
                            }
                            if (!hasFound) {
                                [tmpArr addObject:asset];
                            }
                        }
                    //}
                    
                }
                
            }
            else
            {
                NSArray *sortArr = [[tmpDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                    return [obj2 compare:obj1];
                }];
                NSMutableArray *lastArr = [NSMutableArray array];
                NSInteger count = 0;
                for (NSInteger i = 0; i < sortArr.count; i++) {
                    NSArray *dicArr = [tmpDic valueForKey:sortArr[i]];
                    [lastArr addObject:dicArr];
                    count += dicArr.count;
                }
                if (count != weakSelf.assetsCount) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.assetArr = lastArr;
                        weakSelf.assetsCount = count;
                        [weakSelf.collectionView reloadData];
                    });
                }
            }
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group)
            {
                [group setAssetsFilter:((CTAssetsPickerController *)weakSelf.navigationController).assetsFilter];
                if (group.numberOfAssets > 0)
                {
                    [group enumerateAssetsUsingBlock:assetsBlock];
                }
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:error.description duration:1.0 position:@"center"];
            });
        };
        [weakSelf.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:resultsBlock failureBlock:failureBlock];
    });
}

#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 60.0, 30.0);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:CREATE_IMG(@"back@2x") forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    [backBtn addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,backBarButtonItem];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [rightView setBackgroundColor:[UIColor clearColor]];
    UILabel *leftLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 24, 24)];
    [leftLab setBackgroundColor:rgba(44, 188, 239, 1)];
    leftLab.layer.masksToBounds = YES;
    leftLab.layer.cornerRadius = 12;
    [leftLab setTextAlignment:NSTextAlignmentCenter];
    [leftLab setFont:[UIFont systemFontOfSize:10]];
    [leftLab setTag:1];
    [leftLab setText:@"0"];
    [leftLab setTextColor:[UIColor whiteColor]];
    [rightView addSubview:leftLab];
    
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(28, 0, 34, 30)];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    [rightBut setTitle:@"完成" forState:UIControlStateNormal];
    [rightBut setTitleColor:rgba(44, 188, 239, 1) forState:UIControlStateNormal];
    [rightBut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightBut addTarget:self action:@selector(finishPickingAssets:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightBut];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightItem];
}

- (void)backButton
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - CTAssetsViewCellDelegate
- (void)checkSelectCell:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    ALAsset *asset = assets[indexPath.item];
    if ([_selectAssets containsObject:asset]) {
        [_selectAssets removeObject:asset];
        [self setTitleWithSelectedIndexPaths:_selectAssets];
        for (CTAssetsViewCell *curCell in self.collectionView.visibleCells) {
            if (curCell != cell) {
                NSIndexPath *visibleIndexPath = [self.collectionView indexPathForCell:curCell];
                NSArray *visibleAssets = [_assetArr objectAtIndex:visibleIndexPath.section];
                ALAsset *visibleAsset = visibleAssets[visibleIndexPath.item];
                NSUInteger index = [_selectAssets indexOfObject:visibleAsset];
                if (index != NSNotFound) {
                    [curCell.button setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
                    [curCell.button setSelected:YES];
                }
            }
            else{
                ((CTAssetsViewCell *)cell).button.selected = NO;
                [((CTAssetsViewCell *)cell).button setTitle:@"" forState:UIControlStateNormal];
            }
        }
        return;
    }
    
    BOOL shouldChecked = [self shouldCheckedItemAt:indexPath];
    if (shouldChecked) {
        [_selectAssets addObject:asset];
        [self setTitleWithSelectedIndexPaths:_selectAssets];
        ((CTAssetsViewCell *)cell).button.selected = YES;
        [((CTAssetsViewCell *)cell).button setTitle:[NSString stringWithFormat:@"%ld",(long)_selectAssets.count] forState:UIControlStateNormal];
    }
}

- (BOOL)foundHDResource
{
    CTAssetsPickerController *pic = (CTAssetsPickerController *)self.navigationController;
    for (ALAsset *asset in _selectAssets) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            continue;
        }
        CGSize size = asset.defaultRepresentation.dimensions;
        if (pic.isSmallPicLimit || (size.width >= pic.minWei && size.height >= pic.minHei))
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldCheckedItemAt:(NSIndexPath *)indexPath
{
    CTAssetsPickerController *pic = (CTAssetsPickerController *)self.navigationController;
    BOOL coverCheck = (pic.selectAll && !pic.hasCover && (pic.maximumNumberOfSelection - _selectAssets.count == 1));
    
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    ALAsset *assetItem = [assets objectAtIndex:indexPath.item];
    BOOL isVideo = [[assetItem valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo];
    if (isVideo) {
        if (coverCheck && ![self foundHDResource]) {
            [pic.view makeToast:@"您需要选择1张高清照片作为封面用于打印" duration:1.0 position:@"center"];
            return NO;
        }
        ALAssetRepresentation *representation = [assetItem defaultRepresentation];
        /*
        BOOL isMP4 = [representation.url.resourceSpecifier hasSuffix:@"mp4"];
        if (isMP4) {
            if (!_shouldTip) {
                [self.navigationController.view makeToast:@"非常抱歉，暂时不支持这种视频文件" duration:1.0 position:@"center"];
            }
            
            return NO;
        }*/
        if ([representation size] > 1024 * 1024 * 100) {
            if (!_shouldTip) {
                [self.navigationController.view makeToast:@"非常抱歉，暂时不支持超过100M的视频文件" duration:1.0 position:@"center"];
            }
            
            return NO;
        }
    }
    else if(coverCheck && ![self foundHDResource])
    {
        CGSize size = assetItem.defaultRepresentation.dimensions;
        if (!pic.isSmallPicLimit && (size.width < pic.minWei || size.height < pic.minHei))
        {
            [pic.view makeToast:@"您需要选择1张高清照片作为封面用于打印" duration:1.0 position:@"center"];
            return NO;
        }
    }
    
    if (!pic.selectAll) {
        BOOL canCombine = pic.combine && (_selectAssets.count > 0);
        if (isVideo) {
            if (canCombine) {
                if (!_shouldTip) {
                    [self.navigationController.view makeToast:@"图片和视频不能同时选择哦" duration:1.0 position:@"center"];
                }
                
                return NO;
            }
            
            BOOL videoSelected = NO;
            for (ALAsset *asset in _selectAssets)
            {
                if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]){
                    videoSelected   = YES;
                    break;
                }
            }
            
            if (videoSelected) {
                if (!_shouldTip) {
                    [self.navigationController.view makeToast:@"您已经选择了一个视频，暂时不支持选择多个视频" duration:1.0 position:@"center"];
                }
                
                return NO;
            }
        }
        else if(canCombine){
            ALAsset *firstAsset = [_selectAssets firstObject];
            if ([[firstAsset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]){
                if (!_shouldTip) {
                    [self.navigationController.view makeToast:@"图片和视频不能同时选择哦" duration:1.0 position:@"center"];
                }
                
                return NO;
            }
        }
    }
    
    CTAssetsPickerController *vc = (CTAssetsPickerController *)self.navigationController;
    BOOL should = (_selectAssets.count < vc.maximumNumberOfSelection);
    if (!should) {
        if (!_shouldTip) {
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"非常抱歉，不能选择超过%ld张",(long)vc.maximumNumberOfSelection] duration:1.0 position:@"center"];
        }
    }
    return should;
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _mwphotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _mwphotos.count)
    {
        ALAsset *asset = _mwphotos[index];
        MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            photo.isVideo = YES;
            photo.videoUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        }
        return photo;
    }
    return nil;
}

- (BOOL)shouldSelectItemAt:(NSInteger)index
{
    ALAsset *asset = _mwphotos[index];
    return [_selectAssets containsObject:asset];
}

- (BOOL)isCanSelectItemAt:(NSInteger)index browser:(MWPhotoBrowser *)browser
{
    NSArray *assets = [_assetArr objectAtIndex:_indexPath.section];
    if ([_selectAssets containsObject:assets[index]]) {
        return YES;
    }
    
    return [self shouldCheckedItemAt:[NSIndexPath indexPathForItem:index inSection:_indexPath.section]];
}

- (void)cancelSelectedItemAt:(NSInteger)index Should:(BOOL)sel
{
    ALAsset *asset = _mwphotos[index];
    if (sel) {
        if (![_selectAssets containsObject:asset]) {
            [_selectAssets addObject:asset];
        }
    }
    else{
        [_selectAssets removeObject:asset];
    }
    
    for (CTAssetsViewCell *curCell in self.collectionView.visibleCells) {
        
        NSIndexPath *visibleIndexPath = [self.collectionView indexPathForCell:curCell];
        NSArray *visibleAssets = [_assetArr objectAtIndex:visibleIndexPath.section];
        ALAsset *visibleAsset = visibleAssets[visibleIndexPath.item];
        NSUInteger index = [_selectAssets indexOfObject:visibleAsset];
        if (index != NSNotFound) {
            [curCell.button setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
            [curCell.button setSelected:YES];
        }
        else{
            [curCell.button setTitle:@"" forState:UIControlStateNormal];
            [curCell.button setSelected:NO];
        }
    }
    
    [self setTitleWithSelectedIndexPaths:_selectAssets];
}

- (void)finishPreView:(NSInteger)index
{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [_assetArr count];
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *assets = [_assetArr objectAtIndex:section];
    return assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    
    CTAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    ALAsset *asset = assets[indexPath.item];
    NSUInteger index = [_selectAssets indexOfObject:asset];
    if (index == NSNotFound) {
        [cell.button setTitle:@"" forState:UIControlStateNormal];
        [cell.button setSelected:NO];
    }
    else{
        [cell.button setTitle:[NSString stringWithFormat:@"%ld",(long)index + 1] forState:UIControlStateNormal];
        [cell.button setSelected:YES];
    }
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    [cell bind:asset All:picker.selectAll Min:picker.minWei Hei:picker.minHei];
    
    return cell;
}

#pragma mark - 头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAssetsSupplementaryViewIdentifier forIndexPath:indexPath];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *timeLab = (UILabel *)[view viewWithTag:1];
    if (!timeLab) {
        timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 16)];
        [timeLab setBackgroundColor:view.backgroundColor];
        [timeLab setTag:1];
        [timeLab setFont:[UIFont systemFontOfSize:12]];
        [timeLab setTextColor:[UIColor darkGrayColor]];
        [view addSubview:timeLab];
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 6, 60, 14)];
        [numLab setFont:[UIFont systemFontOfSize:10]];
        [numLab setTag:2];
        [numLab setTextColor:[UIColor darkGrayColor]];
        [numLab setTextAlignment:NSTextAlignmentRight];
        [view addSubview:numLab];
    }
    NSArray *array = _assetArr[indexPath.section];
    ALAsset *asset = [array firstObject];
    NSDate *curDate = [asset valueForProperty:ALAssetPropertyDate];
    NSString* nsALAssetPropertyDate = [NSString stringByDate:@"yyyy年MM月dd日" Date:curDate];
    [timeLab setText:nsALAssetPropertyDate];
    
    UILabel *numLab = (UILabel *)[view viewWithTag:2];
    [numLab setText:[NSString stringWithFormat:@"%ld张",(long)[array count]]];
    
    return view;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.navigationController.topViewController != self) {
        return;
    }
    
    _indexPath = indexPath;
    
    _mwphotos = [NSMutableArray array];
    
    NSArray *assets = [_assetArr objectAtIndex:indexPath.section];
    [_mwphotos addObjectsFromArray:assets];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    [browser setCurrentPhotoIndex:indexPath.item];
    browser.selectedCount = [_selectAssets count];
    browser.totalCount = ((CTAssetsPickerController *)self.navigationController).maximumNumberOfSelection;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)selectItems
{
    UIView *rightView = [[self.navigationItem.rightBarButtonItems lastObject] customView];
    UILabel *leftLab = [rightView viewWithTag:1];
    [leftLab setText:[NSString stringWithFormat:@"%ld",(long)[selectItems count]]];
}

#pragma mark - 压缩完毕
- (void)videoCompressedFinish:(NSString *)filePath
{
    self.navigationController.view.userInteractionEnabled = YES;
    for (NSInteger i = 0;i < _selectAssets.count;i++) {
        ALAsset *asset = _selectAssets[i];
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            [_selectAssets replaceObjectAtIndex:i withObject:filePath];
            break;
        }
    }
    
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [picker.delegate assetsPickerController:picker didFinishPickingAssets:_selectAssets];
    
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions
- (void)finishPickingAssets:(id)sender
{
    NSInteger count = _selectAssets.count;
    CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
    
    if (count == 0) {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:_selectAssets];
        return;
    }
    
    if (!((CTAssetsPickerController *)self.navigationController).selectAll) {
        for (ALAsset *asset in _selectAssets) {
            if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                PlayViewController *play = [[PlayViewController alloc] init];
                play.fileUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
                __weak typeof(self)weakSelf = self;
                play.playResult = ^(NSString *path){
                    [weakSelf videoCompressedFinish:path];
                };
                [self.navigationController pushViewController:play animated:YES];
                return;
            }
        }
        
        CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:_selectAssets];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if (!_progressView) {
        _progressView = [[ProgressCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) / 2, (SCREEN_HEIGHT - 64 - 120) / 2, 120, 120)];
    }
    [_progressView.progressLab setText:@"图片和视频正在处理..."];
    if (![_progressView isDescendantOfView:self.view]) {
        [self.view addSubview:_progressView];
    }
    picker.view.userInteractionEnabled = NO;
    //先删除文件
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSString *str in _uploadArr) {
        if ([str isKindOfClass:[NSString class]] && [manager fileExistsAtPath:str]) {
            [manager removeItemAtPath:str error:nil];
        }
    }
    _uploadArr = [NSMutableArray array];
    _netSource = [NSMutableArray array];
    _totalCount = count;
    NSString *timeStr = [NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]];
    NSMutableArray *assetIdxs = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        [self.uploadArr addObject:[NSNull null]];
        [self.netSource addObject:[NSNull null]];
        ALAsset *asset = _selectAssets[i];
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            NSString *path = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%ld.mp4",(long)i]];
            path = [APPTmpDirectory stringByAppendingPathComponent:path];
            [UIImage converVideoDimissionWithFilePath:[asset valueForProperty:ALAssetPropertyAssetURL] andOutputPath:path withCompletion:^(NSError *error) {
                weakSelf.totalCount--;
                if (!error) {
                    [weakSelf.uploadArr replaceObjectAtIndex:i withObject:path];
                }
                if (weakSelf.totalCount == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf uploadSources];
                    });
                }
            } To:nil Sel:nil];
        }
        else{
            [assetIdxs addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    if (assetIdxs.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSNumber *number in assetIdxs) {
                NSInteger i = number.integerValue;
                ALAsset *asset = _selectAssets[i];
                @autoreleasepool {
                    NSString *path = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%ld.jpg",(long)i]];
                    path = [APPTmpDirectory stringByAppendingPathComponent:path];
                    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                    image = [image fixOrientation];
                    NSData *data = UIImageJPEGRepresentation(image, 0.8);
                    [data writeToFile:path atomically:NO];
                    weakSelf.totalCount--;
                    [weakSelf.uploadArr replaceObjectAtIndex:i withObject:path];
                }
                if (weakSelf.totalCount == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf uploadSources];
                    });
                }
            }
        });
    }
}

#pragma mark - 资源上传
- (void)uploadSources
{
    self.totalCount = self.uploadArr.count;
    BOOL videoExcep = NO;
    for (id sub in self.uploadArr) {
        if ([sub isKindOfClass:[NSNull class]]) {
            videoExcep = YES;
            break;
        }
    }
    
    self.navigationController.view.userInteractionEnabled = YES;
    
    if (videoExcep) {
        [_progressView removeFromSuperview];
        [self.view makeToast:@"视频处理异常，请您稍后重试" duration:1.0 position:@"center"];
        return;
    }
    else{
        [_progressView.progressLab setText:[NSString stringWithFormat:@"图片与视频上传进度0/%ld",(long)_totalCount]];
        _progressView.loadingIndicator.progress = 0;
    }
    
    self.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSInteger i = 0;i < self.uploadArr.count;i++) {
        NSString *path = self.uploadArr[i];
        if ([path hasSuffix:@"jpg"]) {
            NSDictionary *imageParam = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1"};    //1－图片
            NSData *json = [NSJSONSerialization dataWithJSONObject:imageParam options:NSJSONWritingPrettyPrinted error:nil];
            NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *url = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSError *error;
                [formData appendPartWithFileURL:fileURL name:@"images[]" error:&error];
            } error:nil];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *retJson = [operation.responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //单条成功处理
                id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                if ([retData isKindOfClass:[NSArray class]]) {
                    retData = [retData firstObject];
                }
                BOOL end = NO;
                if (retData && [retData isKindOfClass:[NSDictionary class]]) {
                    NSString *original = [retData valueForKey:@"original"];
                    if (original && [original isKindOfClass:[NSString class]]) {
                        end = YES;
                    }
                }
                
                [weakSelf uploadSingleFinish:end Data:retData At:i];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //单条失败处理
                [weakSelf uploadSingleFinish:NO Data:nil At:i];
            }];
            [mutableOperations addObject:operation];
        }
        else{
            NSString *url = [G_UPLOAD_NEWAUDIO stringByAppendingString:[DJTGlobalManager shareInstance].userInfo.userid];
            AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
            NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" error:nil];
            } error:nil];;
            
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *retJson = [operation.responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //单条成功处理
                id retData = [NSJSONSerialization JSONObjectWithData:[retJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                if ([retData isKindOfClass:[NSArray class]]) {
                    retData = [retData firstObject];
                }
                BOOL end = NO;
                if (retData && [retData isKindOfClass:[NSDictionary class]]) {
                    NSString *original = [retData valueForKey:@"original"];
                    if (original && [original isKindOfClass:[NSString class]]) {
                        end = YES;
                    }
                }
                
                [weakSelf uploadSingleFinish:end Data:retData At:i];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [weakSelf uploadSingleFinish:NO Data:nil At:i];
            }];
            [mutableOperations addObject:requestOperation];
        }
    }
    
    NSArray *connectOperations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
    } completionBlock:^(NSArray *operations) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf uploadFinish];
        });
    }];
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue addOperations:connectOperations waitUntilFinished:NO];
}

- (void)uploadSingleFinish:(BOOL)suc Data:(id)result At:(NSInteger)index
{
    _totalCount--;
    
    if (suc) {
        NSString *original = [result valueForKey:@"original"];
        [_netSource replaceObjectAtIndex:index withObject:original];
    }
    
    NSInteger totalCount = [_uploadArr count];
    [_progressView.loadingIndicator setProgress:(CGFloat)(totalCount - _totalCount) / totalCount];
    [_progressView.progressLab  setText:[NSString stringWithFormat:@"图片与视频上传进度%ld/%ld",(long)totalCount - _totalCount,(long)totalCount]];
}

- (void)uploadFinish
{
    [_progressView removeFromSuperview];
    self.view.userInteractionEnabled = YES;
    BOOL success = YES;
    for (id sub in _netSource) {
        if ([sub isKindOfClass:[NSNull class]]) {
            success = NO;
            break;
        }
    }
    if (success) {
        CTAssetsPickerController *picker = (CTAssetsPickerController *)self.navigationController;
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [picker.delegate assetsPickerController:picker didFinishPickingAssets:@[_selectAssets,_uploadArr,_netSource]];
    }
    else{
        [self.view makeToast:@"可能因手机网络连接异常导致上传失败，请您稍后重试" duration:1.0 position:@"center"];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end



#pragma mark - CTAssetsViewCell

@implementation CTAssetsViewCell
{
    UIImageView *_videoIcon,*_backImg;
}

static UIImage *videoIcon;

+ (void)initialize
{
    videoIcon       = [UIImage imageNamed:@"videoPlay2"];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                     = YES;
        self.isAccessibilityElement     = YES;
        self.accessibilityTraits        = UIAccessibilityTraitImage;
        
        _backImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kThumbnailLength, kThumbnailLength)];
        [self.contentView addSubview:_backImg];
        
        _videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 20, 20)];
        [_videoIcon setImage:[UIImage imageNamed:@"videoPlay2"]];
        [self.contentView addSubview:_videoIcon];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setBackgroundImage:CREATE_IMG(@"circleGrey") forState:UIControlStateNormal];
        [_button setBackgroundImage:CREATE_IMG(@"circleGreen") forState:UIControlStateSelected];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.layer.masksToBounds = YES;
        _button.layer.cornerRadius = 13.5;
        [_button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button setFrame:CGRectMake(kThumbnailLength - 25, 2, 25, 25)];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.contentView addSubview:_button];
        
    }
    
    return self;
}

- (void)pressButton:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^{
        _button.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        _button.transform = CGAffineTransformIdentity;
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(checkSelectCell:)]) {
        [_delegate checkSelectCell:self];
    }
}

- (void)bind:(ALAsset *)asset All:(BOOL)selectAll Min:(CGFloat)minWei Hei:(CGFloat)minHei
{
    self.asset  = asset;
    _backImg.image  = [UIImage imageWithCGImage:asset.thumbnail];
    _videoIcon.hidden = ![[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo];
    if (selectAll) {
        CGSize size = asset.defaultRepresentation.dimensions;
        BOOL isHidden = (size.width >= minWei && size.height >= minHei);
        [self.hdImg setHidden:!isHidden];
    }
}

- (UIImageView *)hdImg{
    if (!_hdImg) {
        _hdImg = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 15, 25)];
        [_hdImg setBackgroundColor:[UIColor clearColor]];
        [_hdImg setImage:CREATE_IMG(@"HDTip")];
        [self.contentView addSubview:_hdImg];
    }
    return _hdImg;
}

@end
