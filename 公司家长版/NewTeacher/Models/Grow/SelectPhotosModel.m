//
//  SelectPhotosModel.m
//  NewTeacher
//
//  Created by szl on 16/3/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "SelectPhotosModel.h"

@implementation SelectPhotosModel

- (void)clearFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_imageFileStr]) {
        [fileManager removeItemAtPath:_imageFileStr error:nil];
    }
    if ([fileManager fileExistsAtPath:_videoFileStr]) {
        [fileManager removeItemAtPath:_videoFileStr error:nil];
    }
}

- (SelectPhotosModel *)itemCopy
{
    SelectPhotosModel *model = [[SelectPhotosModel alloc] init];
    model.type = _type;
    model.imgStr = _imgStr;
    model.videoStr = _videoStr;
    model.videoFileStr = _videoFileStr;
    model.imageFileStr = _imageFileStr;
    model.thumb = _thumb;
    model.isCover = _isCover;
    model.state = _state;
    model.thumbImg = _thumbImg;
    model.photoId = _photoId;
    model.width = _width;
    model.height = _height;
    return model;
}

@end
