//
//  AddActivityViewController.h
//  NewTeacher
//
//  Created by songzhanglong on 15/1/20.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"
#import "MileageModel.h"

@interface AddActivityViewController : DJTTableViewController

@property (nonatomic,strong)NSString *videoPath;    //如存在，则上传视频
@property (nonatomic,assign)NSInteger fromType;     //0-默认，1-宝贝相册，2-班级相册
@property (nonatomic,strong)MileageModel *mileageModel;
@property (nonatomic,strong)NSURL *themeUrl;

@end
