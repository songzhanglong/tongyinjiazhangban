//
//  GrowTermModel.h
//  NewTeacher
//
//  Created by songzhanglong on 15/6/18.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "JSONModel.h"

@protocol GrowAlbumModel
@end
@interface GrowAlbumModel : JSONModel

@property (nonatomic,strong)NSString *template_id;          // 模板id
@property (nonatomic,strong)NSString *template_title;
@property (nonatomic,strong)NSString *template_path;        // 模板地址url
@property (nonatomic,strong)NSString *template_path_edit;   // 模板地址url
@property (nonatomic,strong)NSString *template_path_thumb;  //模板缩略图地址（相对地址）
@property (nonatomic,strong)NSString *template_index;       // 模板所处的位置
@property (nonatomic,strong)NSString *template_desc;        //
@property (nonatomic,strong)NSString *image_thumb;          //制作完成的缩略图url
@property (nonatomic,strong)NSString *image_path;           //制作完成的图片url
@property (nonatomic,strong)NSDictionary *template_detail;
@property (nonatomic,strong)NSArray *src_image_list;        //源图片地址
@property (nonatomic,strong)NSArray *src_h5_list;        //源图片地址
@property (nonatomic,strong)NSArray *src_video_list;        //视频地址
@property (nonatomic,strong)NSArray *src_txt_list;          //文字提示
@property (nonatomic,strong)NSArray *src_deco_list;         //素材地址
@property (nonatomic,strong)NSArray *src_deco_txt_list;     //自由文字
@property (nonatomic,strong)NSArray *image_detail_list;     //图片坐标
@property (nonatomic,strong)NSArray *deco_detail_list;      //素材坐标
@property (nonatomic,strong)NSArray *src_gallery_list;
@property (nonatomic,strong)NSString *allow_parent;         //是否允许协作
@property (nonatomic,strong)NSString *play_url;
@property (nonatomic,strong)NSNumber *allow_nonhd;          // 0-不允许非高清，1-允许非高清

@end

@protocol GrowExtendModel
@end
@interface GrowExtendModel : JSONModel

@property (nonatomic,strong)NSString *album_title;
@property (nonatomic,strong)NSString *album_desc;
@property (nonatomic,strong)NSString *album_id;
@property (nonatomic,strong)NSNumber *album_type;
@property (nonatomic,strong)NSMutableArray<GrowAlbumModel> *list;

@end

@interface GrowTermModel : JSONModel

@property (nonatomic,strong)NSString *grow_id;
@property (nonatomic,strong)NSString *templist_id;
@property (nonatomic,strong)NSString *term;
@property (nonatomic,strong)NSString *cover_url;
@property (nonatomic,strong)NSString *total_num;
@property (nonatomic,strong)NSString *finish_num;
@property (nonatomic,strong)NSString *update_time;
@property (nonatomic,strong)NSString *templist_name;
@property (nonatomic,strong)NSString *edit_flag;
@property (nonatomic,strong)NSNumber *print_flag;   // 1-允许打印， 0-不允许打印
@property (nonatomic,strong)NSString *print_tip;
@property (nonatomic,strong)NSNumber *tpl_height;
@property (nonatomic,strong)NSNumber *tpl_width;
@property (nonatomic,strong)NSMutableArray<GrowExtendModel> *album_list;  //GrowAlbumModel

@end
