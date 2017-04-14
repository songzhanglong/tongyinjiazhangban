//
//  StudentAlbums2ViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/11.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "StudentAlbums2ViewController.h"
#import "ThemeBatchModel.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"

@interface StudentAlbums2ViewController ()

@end

@implementation StudentAlbums2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLable.text = @"宝宝相册";
}

- (void)createRightBarButton{
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _browserPhotos = [NSMutableArray array];
    for (int i = 0; i < [self.dataSource count]; i++) {
        ThemeBatchItem *item = self.dataSource[i];
        NSString *path = item.path;
        if (![path hasPrefix:@"http"]) {
            path = [G_IMAGE_ADDRESS stringByAppendingString:path ?: @""];
        }
        MWPhoto *photo = nil;
        NSString *name = [path lastPathComponent];
        if ([[[name pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
            photo = [MWPhoto photoWithImage:[UIImage thumbnailPlaceHolderImageForVideo:[NSURL URLWithString:path]]];
            photo.videoUrl = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            photo.isVideo = YES;
        }
        else
        {
            CGFloat scale_screen = [UIScreen mainScreen].scale;
            NSString *width = [NSString stringWithFormat:@"%.0f",SCREEN_WIDTH * scale_screen];
            path = [NSString getPictureAddress:@"2" width:width height:@"0" original:path];
            NSURL *url = [NSURL URLWithString:path];
            photo = [MWPhoto photoWithURL:url];
        }
        [_browserPhotos addObject:photo];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:indexPath.item];
    browser.displayNavArrows = YES;
    browser.displayActionButton = NO;
    
    [self.navigationController pushViewController:browser animated:YES];
}

@end
