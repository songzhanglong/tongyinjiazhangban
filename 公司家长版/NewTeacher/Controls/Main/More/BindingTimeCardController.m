
//
//  BindingTimeCardControllerViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/7/23.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "BindingTimeCardController.h"
#import "Toast+UIView.h"
#import "DJTGlobalDefineKit.h"
#import "CTAssetsPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FixOrientation.h"
#import "NSString+Common.h"
#import "DJTTimeCardViewController.h"
#import "DJTIdentifierValidator.h"
#import "TimeCardModel.h"
#import "UIButton+WebCache.h"
#import "ImageCropViewController.h"

@interface BindingTimeCardController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,ImageCropDelegate>

@end

@implementation BindingTimeCardController
{
    UITableView *_tableView;
    UIButton *_photoBut;
    NSString *_filePath;
    NSMutableDictionary *_dictionry;
}

- (void)dealloc
{
    [self clearFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"绑定考勤卡";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    _dictionry = [NSMutableDictionary dictionary];
    if (_cardModel) {
        [_dictionry setObject:_cardModel.holder_rel ?: @"" forKey:@"holder_rel"];
        [_dictionry setObject:_cardModel.card_no ?: @"" forKey:@"card_no"];
        [_dictionry setObject:_cardModel.holder_mobile ?: @"" forKey:@"holder_mobile"];
        [_dictionry setObject:_cardModel.holder_name ?: @"" forKey:@"holder_name"];
    }
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height - 64 - 50) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:CreateColor(241, 242, 246)];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 47 + 125 + 10 + 12)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((winSize.width - 200) / 2, 27, 200, 15)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:1];
    [label setFont:[UIFont systemFontOfSize:15]];
    [label setText:@"请上传持卡人照片"];
    [label setTextColor:[UIColor blackColor]];
    [footView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake((winSize.width - 125) / 2, 47, 125, 125)];
    if ([_cardModel.holder_face length] > 0) {
        NSString *str = _cardModel.holder_face;
        if (![str hasPrefix:@"http"]) {
            str = [G_IMAGE_ADDRESS stringByAppendingString:str ?: @""];
        }
        [button setImageWithURL:[NSURL URLWithString:str] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
        [button setTitle:nil forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:@"点击上传" forState:UIControlStateNormal];
    }
    [button.imageView setClipsToBounds:YES];
    [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [button setBackgroundColor:CreateColor(219, 223, 224)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 62.5;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    _photoBut = button;
    [button addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 2;
    [footView addSubview:button];
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, 47 + 125 + 10, label.frame.size.width, 12)];
    [tipLab setBackgroundColor:[UIColor clearColor]];
    [tipLab setFont:[UIFont systemFontOfSize:11]];
    [tipLab setTextAlignment:1];
    [tipLab setTextColor:[UIColor redColor]];
    [tipLab setText:@"提示：推荐上传上半身照片"];
    [footView addSubview:tipLab];
    
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
    
    UIButton *binging = [UIButton buttonWithType:UIButtonTypeCustom];
    [binging setFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    [binging setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [binging setBackgroundColor:CreateColor(81, 90, 116)];
    [binging setTitle:@"绑 定" forState:UIControlStateNormal];
    [binging.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [binging setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [binging addTarget:self action:@selector(startBinding:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:binging];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)selectPhoto:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [sheet showInView:self.view];
}

- (void)startBinding:(id)sender
{
    NSString *cardNo = [_dictionry valueForKey:@"card_no"];
    if ([cardNo length] == 0) {
        [self.view makeToast:@"请输入考勤卡卡号" duration:1.0 position:@"center"];
        return;
    }
    else if ([cardNo length] != 10)
    {
        [self.view makeToast:@"考勤卡号必须是10位" duration:1.0 position:@"center"];
        return;
    }
    
    NSString *holder_rel = [_dictionry valueForKey:@"holder_rel"];
    if ([holder_rel length] == 0) {
        [self.view makeToast:@"请输入关系，如：爸爸，妈妈" duration:1.0 position:@"center"];
        return;
    }
    
    NSString *holder_mobile = [_dictionry valueForKey:@"holder_mobile"];
    if (([holder_mobile length] > 0) && ![DJTIdentifierValidator isValidPhone:holder_mobile]) {
        [self.view makeToast:@"手机号格式不正确" duration:1.0 position:@"center"];
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    if (_filePath) {
        [self uploadImg:_filePath];
    }
    else
    {
        [self bindingInfo];
    }
}

- (void)resignAllKeyboards
{
    for (UITableViewCell *cell in [_tableView visibleCells]) {
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1001];
        if (textField.isFirstResponder) {
            [textField resignFirstResponder];
            break;
        }
    }
}

- (void)clearFile
{
    if (_filePath && [[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    }
    _filePath = nil;
}

- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField.tag != 1001) {
        return;
    }
    
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            [self emojiStrSplit:toBeString Field:textField];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString Field:textField];
    }
}

- (void)emojiStrSplit:(NSString *)str Field:(UITextField *)textField
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % 10000;
        int location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        [textField setText:lastStr];
    }
    
    UITableViewCell *cell = [DJTGlobalManager viewController:textField Class:[UITableViewCell class]];
    NSIndexPath *tmpPath = [_tableView indexPathForCell:cell];
    NSArray *keys = @[@"card_no",@"holder_rel",@"holder_name",@"holder_mobile"];
    [_dictionry setValue:(textField.text.length > 0) ? textField.text : @"" forKey:keys[tmpPath.row]];
}

#pragma mark - 图片上传
- (void)uploadImg:(NSString *)filePath
{
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    __weak typeof(self)weakSelf = self;
    //图片上传队列
    NSDictionary *dicOne = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1",@"img": @[@"160,160"]};    //1－图片
    NSData *json = [NSJSONSerialization dataWithJSONObject:dicOne options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPathImg = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:urlPathImg parameters:nil filePath:filePath ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf uploadHeadFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        [weakSelf uploadHeadFinish:nil Suc:NO];
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
    }];
}

- (void)uploadHeadFinish:(id)result Suc:(BOOL)success
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    if (success) {
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result firstObject];
        }
        NSString *original = [result valueForKey:@"original"];
        
        if (original && [original length] > 0) {
            NSString *extension = [original pathExtension];
            NSString *thumbnail = [NSString stringWithFormat:@"%@_160_160.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
            [_dictionry setObject:thumbnail forKey:@"holder_face"];
            [self bindingInfo];
        }
        else
        {
            [self.view makeToast:@"头像修改失败" duration:1.0 position:@"center"];
        }
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        if ([result valueForKey:@"message"]) {
            str = [result valueForKey:@"message"];
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 修改考勤卡信息
- (void)changeCardInfo
{
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"updateAttenceCard"];
    [dic setObject:_cardModel.card_id ?: @"" forKey:@"card_id"];
    [dic setValuesForKeysWithDictionary:_dictionry];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf changeCardInfoFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf changeCardInfoFinish:NO Data:nil];
    }];
}

- (void)changeCardInfoFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (success) {
        [_cardModel mergeFromDictionary:_dictionry useKeyMapping:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(reloadTimeCardCell)]) {
            [_delegate reloadTimeCardCell];
        }
        [self.navigationController.view makeToast:@"修改成功" duration:1.0 position:@"center"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - 绑定考勤卡
- (void)bindingInfo
{
    if (_cardModel) {
        [self changeCardInfo];
        return;
    }
    
    DJTUser *userInfo = [DJTGlobalManager shareInstance].userInfo;
    NSMutableDictionary *dic = [[DJTGlobalManager shareInstance] requestinitParamsWith:@"bingCard"];
    [dic setObject:userInfo.mid ?: @"" forKey:@"mid"];
    [dic setObject:userInfo.school_id ?: @"" forKey:@"school_id"];
    [dic setValuesForKeysWithDictionary:_dictionry];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:dic];
    [dic setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    __weak typeof(self)weakSelf = self;
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"attence"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf bindingFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf bindingFinish:NO Data:nil];
    }];
}

- (void)bindingFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (success) {
        [DJTGlobalManager shareInstance].userInfo.payType = (ePayBind | ePayMoney);
        
        NSArray *controls = self.navigationController.viewControllers;
        UIViewController *preCon = controls[controls.count - 2];
        if ([preCon isKindOfClass:[DJTTimeCardViewController class]]) {
            [(DJTTimeCardViewController *)preCon setShouldRefresh:YES];
        }
        else
        {
            if (_delegate && [_delegate respondsToSelector:@selector(bindTimeCardCount)]) {
                [_delegate bindTimeCardCount];
            }
        }
        [self.navigationController.view makeToast:@"绑定成功" duration:1.0 position:@"center"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *str = REQUEST_FAILE_TIP;
        NSString *ret_msg = nil;
        if ((ret_msg = [result valueForKey:@"ret_msg"])) {
            str = ret_msg;
        }
        [self.view.window makeToast:str duration:1.0 position:@"center"];
    }
}
#pragma mark - ImageCropViewController delegate
-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image
{
    if (image) {
        [_photoBut setImage:image forState:UIControlStateNormal];
        [_photoBut setTitle:nil forState:UIControlStateNormal];
        [self clearFile];
        _filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]]]];
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        [data writeToFile:_filePath atomically:NO];
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = sourceType;//设置类型
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc]init];
            picker.maximumNumberOfSelection = 1;
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        ALAsset *asset = [assets lastObject];
        UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        ImageCropViewController *controller = [[ImageCropViewController alloc] init];
        controller.originImage = img;
        controller.delegate= self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    image = [image fixOrientation];//把图片已正确的位置保存
    
    ImageCropViewController *controller = [[ImageCropViewController alloc] init];
    controller.originImage = image;
    controller.delegate= self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierBase = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBase];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBase];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UILabel *leftLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 13.5, 100, 17)];
        [leftLab setBackgroundColor:[UIColor clearColor]];
        [leftLab setTextAlignment:2];
        [leftLab setFont:[UIFont systemFontOfSize:15]];
        [leftLab setTag:1000];
        [cell.contentView addSubview:leftLab];
        
        //
        CGFloat xOri = leftLab.frame.origin.x + leftLab.frame.size.width + 10;
        UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(xOri, 7, winSize.width - 10 - xOri, 30)];
        //垂直居中
        textFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textFiled setTag:1001];
        textFiled.font = [UIFont systemFontOfSize:13];
        [textFiled setBackgroundColor:[UIColor clearColor]];
        textFiled.layer.masksToBounds = YES;
        textFiled.layer.cornerRadius = 15;
        textFiled.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textFiled.layer.borderWidth = 1.0;
        textFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
        textFiled.leftViewMode = UITextFieldViewModeAlways;
        textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textFiled.delegate = self;
        textFiled.textColor = [UIColor blackColor];
        textFiled.returnKeyType = UIReturnKeyDone;
        [cell.contentView addSubview:textFiled];
        
        UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(textFiled.frame.origin.x + 10, textFiled.frame.origin.y + textFiled.frame.size.height + 5, textFiled.frame.size.width - 20, 11)];
        //[tipLab setTextAlignment:1];
        [tipLab setFont:[UIFont systemFontOfSize:11]];
        [tipLab setBackgroundColor:[UIColor clearColor]];
        [tipLab setTextColor:[UIColor redColor]];
        [tipLab setText:@"提示：卡号在考勤卡正面底部"];
        [tipLab setTag:1002];
        [cell.contentView addSubview:tipLab];
    }
    
    NSArray *lefts = @[@"考勤卡卡号*",@"持卡人关系*",@"持卡人名称  ",@"手机号码  "];
    UILabel *leftLab = (UILabel *)[cell.contentView viewWithTag:1000];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:lefts[indexPath.row]];
    NSRange range = [lefts[indexPath.row] rangeOfString:@"*"];
    if (range.location != NSNotFound) {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    }
    [leftLab setAttributedText:str];
    
    NSArray *fields = @[@"请输入考勤卡卡号",@"请输入关系,如:爸爸,妈妈",@"请输入持卡人姓名",@"请输入持卡人手机号码"];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1001];
    
    [textField setPlaceholder:fields[indexPath.row]];
    NSString *textStr = fields[indexPath.row];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    if (textStr.length > 0) {
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, textStr.length)];
    }
    textField.attributedPlaceholder = attributedStr;
    textField.keyboardType = (indexPath.row == 0 || indexPath.row == 3) ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    
    NSArray *keys = @[@"card_no",@"holder_rel",@"holder_name",@"holder_mobile"];
    [textField setText:[_dictionry valueForKey:keys[indexPath.row]]];
    if (_cardModel && (indexPath.row == 0)) {
        textField.textColor = [UIColor grayColor];
        textField.userInteractionEnabled = NO;
    }else{
        textField.textColor = [UIColor blackColor];
    }
    
    UILabel *tipLab = (UILabel *)[cell.contentView viewWithTag:1002];
    tipLab.hidden = (indexPath.row != 0);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44 + 16;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:_tableView.backgroundColor];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllKeyboards];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
