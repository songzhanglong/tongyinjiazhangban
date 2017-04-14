//
//  DJTSeviceViewController.m
//  TY
//
//  Created by user7 on 9/15/14.
//  Copyright (c) 2014 songzhanglong. All rights reserved.
//

#import "DJTSeviceViewController.h"

@interface DJTSeviceViewController ()

@end

@implementation DJTSeviceViewController

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
    
    self.showBack = YES;
    self.titleLable.text = @"使用条款";
    self.view.backgroundColor = [UIColor colorWithRed:221/255.0 green:224/255.0 blue:216/255.0 alpha:1];
    [self createUI];
}

/**
 *	@brief	计算文本大小
 *
 *	@param 	wei 	最大宽
 *	@param 	font 	字体
 *	@param 	content 	字符串内容
 *
 *	@return	文本大小
 */
- (CGSize)caculateSize:(float)wei Font:(UIFont *)font Str:(NSString *)content
{
    CGSize labSize = CGSizeZero;
    if (content && [content length] > 0)
    {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        labSize = [content boundingRectWithSize:CGSizeMake(wei, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    
    return labSize;
}

- (void)createUI
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    float xOri = 5.0,yOri = 10.0;
    
    //scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height - 64)];
    [self.view addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor colorWithRed:239/255.0 green:241/255.0 blue:237/255.0 alpha:1.0];
   // scrollView.contentOffset = CGPointMake(320, 600);
    scrollView.contentSize = CGSizeMake(320, 1100);
    scrollView.scrollEnabled = YES;
    
    UIFont *desFont = [UIFont systemFontOfSize:13.0];
    //标题
    UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 20)];
    titleLab.textColor = [UIColor blackColor];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.font = desFont;
    titleLab.textAlignment = 1;
    titleLab.text = @"《童•印》软件使用条款及法律声明";
    [scrollView addSubview:titleLab];
    
    //使用条款
    UILabel * itemLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 30)];
    itemLab.textColor = [UIColor colorWithRed:199/255.0 green:57/255.0 blue:81/255.0 alpha:1];
    itemLab.backgroundColor = [UIColor whiteColor];
    itemLab.font = [UIFont systemFontOfSize:15.0];
    itemLab.text = @"  使用条款";
    [scrollView addSubview:itemLab];
    
    //使用条款 描述
    NSString *str = @"   在使用《童•印》应用（以下简称“本应用”）服务前，请您务必仔细阅读并透彻理解本声明。您可以选择不使用《童•印》的服务，但若您使用本应用服务，您的使用行为将被视为对本声明全部内容的认可。";
    CGSize desSize = [self caculateSize:winSize.width - xOri * 2 Font:desFont Str:str];
    UILabel *describeLab = [[UILabel alloc] initWithFrame:CGRectMake(xOri, yOri+70, desSize.width, desSize.height)];
    describeLab.numberOfLines = 0 ;
    describeLab.textColor = [UIColor blackColor];
    describeLab.backgroundColor = [UIColor clearColor];
    describeLab.font = desFont;
    describeLab.text = str;
    [scrollView addSubview:describeLab];
    
    //知识产权声明
    UILabel * noticeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 70+desSize.height+20, 320, 30)];
    noticeLab.textColor = [UIColor colorWithRed:199/255.0 green:57/255.0 blue:81/255.0 alpha:1];
    noticeLab.backgroundColor = [UIColor whiteColor];
    noticeLab.font = [UIFont systemFontOfSize:15.0];
    noticeLab.text = @"  一、知识产权声明";
    [scrollView addSubview:noticeLab];
    
    //产权描述
    UILabel *desLab = [[UILabel alloc] initWithFrame:CGRectMake(xOri, 100+desSize.height+10, desSize.width, 550)];
    desLab.numberOfLines = 0 ;
    desLab.textColor = [UIColor blackColor];
    desLab.contentMode = UIViewContentModeScaleToFill;
    desLab.backgroundColor = [UIColor clearColor];
    desLab.font = desFont;
    desLab.text = [NSString stringWithFormat:@"%@",@"    1.本应用所提供的所有产品、技术、程序及所有信息内容（包括但不限于背景图片、文字、签名、商标、标识）的知识产权均归江苏迪杰特教育科技有限公司（以下简称“本公司”）所有。\n\n   2.除法律特别规定或者政府明确要求者外，在未取得本公司书面明确许可前，任何单位或者个人不得对本公司的任何知识产权进行任何目的的使用，包括但不限于全部或局部复制、下载、转载、引用、传播、更改和链接。 \n\n    3.任何用户使用本应用，即表明该用户主动将其在所上传图片中的任何著作权、商标权或其他知识产权等权利无偿许可给本公司使用（包含盈利性使用），且表明该用户放弃对本公司主张所上传图片中任何知识产权、肖像权及隐私权等权利。\n\n    4.本应用仅供个人娱乐。任何用户通过使用本应用所生成之图片中的任何著作权、商标权或其他知识产权等权利均为本公司所有。非经本公司书面明确许可，任何单位或个人均不得对通过使用本应用所生成之图片进行盈利性使用。且本公司有权就任何主体侵犯上述权利之行为单独提起诉讼，并获得全部赔偿。\n\n    5.本公司可按自身判断随时对本声明进行修改及更新。对本声明的所有改动一经发布即产生法律效力，并适用于改动发布后对本应用的一切使用行为。如用户在经修改的声明发布后继续使用本应用，即代表用户接受并同意了这些改动。\n\n    6.	任何违反本应用知识产权声明的行为，本公司保留进一步追究法律责任的权利。"];
    [scrollView addSubview:desLab];
    
    //免责声明
    UILabel * responsLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 650+desSize.height, 320, 30)];
    responsLab.textColor = [UIColor colorWithRed:199/255.0 green:57/255.0 blue:81/255.0 alpha:1];
    responsLab.backgroundColor = [UIColor whiteColor];
    responsLab.font = [UIFont systemFontOfSize:15.0];
    responsLab.text = @"  二、免责声明";
    [scrollView addSubview:responsLab];

    //免责描述
    UILabel *resLab = [[UILabel alloc] initWithFrame:CGRectMake(xOri, 650+desSize.height+40, desSize.width, 330)];
    resLab.numberOfLines = 0 ;
    resLab.textColor = [UIColor blackColor];
    resLab.backgroundColor = [UIColor clearColor];
    resLab.font = desFont;
    resLab.text = [NSString stringWithFormat:@"%@",@"    1.用户上传至本应用的相关图片均为其自行提供，用户依法应对此承担全部责任，并保证该图片不会侵犯任何第三方的知识产权或其他合法权益。\n\n\n    2.如果用户上传的相关图片因侵犯第三人权利而导致本公司被任何第三方投诉、起诉、索赔或者遭到行政处罚，并由此导致本公司需要承担任何责任或损失的，用户保证承担全部责任，并补偿由此给本公司造成的全部损失。\n\n\n    3.基于互联网的特殊性，本公司对服务的及时性、安全性无法作出担保，也不对用户上传图片的保存、修改、删除或储存失败负责，不承担非因本公司过错所导致的任何责任。\n\n\n    4.用户不得将涉黄、涉暴及反政府等违反法律规定的照片上传至本应用，否则自行承担其不利的法律后果"];
    [scrollView addSubview:resLab];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
