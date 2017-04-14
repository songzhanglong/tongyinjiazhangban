//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"
#import "UMSocial.h"                  //友盟第三方分享
#import "UMSocialControllerService.h" //友盟第三方分享
// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

@class MWPhotoBrowser;
@class ThemeBatchModel;

@protocol MWPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;

- (void)delePicture:(NSInteger)index and:(MWPhotoBrowser *)browser;

- (void)changeToMakeGrowed:(NSInteger)index;
- (NSInteger)shouldEditTouch:(NSInteger)index and:(MWPhotoBrowser *)browser;
- (BOOL)canJoinInTheme:(NSInteger)index and:(MWPhotoBrowser *)browser;
- (void)checkDetailInfo:(NSInteger)index and:(MWPhotoBrowser *)browser;
- (void)changePhotoIdx:(NSInteger)index and:(MWPhotoBrowser *)browser;
- (ThemeBatchModel *)checkNumInfo:(NSInteger)index and:(MWPhotoBrowser *)browser;

- (CGRect)calculateFrameAt:(NSInteger)index Source:(NSInteger)sIdx;
- (CGRect)calculateFrameAt:(NSInteger)index SourceVoice:(NSInteger)sIdx;

//预览
- (BOOL)shouldSelectItemAt:(NSInteger)index;
- (BOOL)isCanSelectItemAt:(NSInteger)index browser:(MWPhotoBrowser *)browser;
- (void)cancelSelectedItemAt:(NSInteger)index Should:(BOOL)sel;
- (void)finishPreView:(NSInteger)index;

@end

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UMSocialUIDelegate>

@property (nonatomic, weak) IBOutlet id<MWPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;

@property (nonatomic) BOOL canDeleteItem;
@property (nonatomic) NSInteger canEditItem;
@property (nonatomic,strong) NSMutableArray *imgSource;

@property (nonatomic) BOOL showDiggNum;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic) NSInteger totalCount;

- (void)playVideo:(NSURL *)filePath;
- (void)playVoice:(NSString *)urlStr;

// Init
- (id)initWithPhotos:(NSArray *)photosArray  __attribute__((deprecated("Use initWithDelegate: instead"))); // Depreciated
- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;
- (void)setInitialPageIndex:(NSUInteger)index  __attribute__((deprecated("Use setCurrentPhotoIndex: instead"))); // Depreciated

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
