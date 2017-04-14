//
//  SelectPhotosModel.h
//  NewTeacher
//
//  Created by szl on 16/3/25.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectPhotosModel : NSObject

//@property (nonatomic,assign)BOOL isVideo;
@property (nonatomic,assign)NSInteger type;         //0-image,1-video,2-h5
@property (nonatomic,strong)NSString *imgStr;       //image网络路径
@property (nonatomic,strong)NSString *videoStr;     //video网络路径
@property (nonatomic,strong)NSString *videoFileStr; //video本地路径,如为网络选取视频，该字段为空
@property (nonatomic,strong)NSString *imageFileStr; //image本地路径

@property (nonatomic,strong)NSString *thumb;        //缩略图
@property (nonatomic,strong)UIImage *thumbImg;      //相册缩略图片

@property (nonatomic,assign)BOOL isCover;
@property (nonatomic,assign)NSInteger state;        //1 下载、2上传
@property (nonatomic,strong)NSString *photoId;
@property (nonatomic,strong)NSNumber *width;
@property (nonatomic,strong)NSNumber *height;

- (SelectPhotosModel *)itemCopy;

- (void)clearFiles;

@end
