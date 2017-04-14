//
//  PersonalInfoViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "CTAssetsPickerController.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "AppDelegate.h"
#import "SelectPickViewCell.h"
#import "SelectItemCell.h"
#import "ImageCropViewController.h"

@interface PersonalInfoViewController ()<UITableViewDataSource,UITableViewDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,SelectPickViewCellDelegate,SelectItemCellDelegate,ImageCropDelegate>

@end

@implementation PersonalInfoViewController
{
    NSString *_imagePath;
    UIImageView *_imageview;
    UITableView *_tableView;
    BOOL _isChange;
    
    NSString *timeString;
    NSString *sexString;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden =NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"用户信息";
    [self createRightBarButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:241 / 255.0 blue:237 / 255.0 alpha:1.0];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 280)];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.tableHeaderView = [self grayView];
    tableView.rowHeight = 40;
    tableView.scrollEnabled = NO;
    [self.view addSubview:tableView];
    // 注销按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(40, 310, [UIScreen mainScreen].bounds.size.width - 80, 43);
    [cancelBtn setBackgroundColor:[UIColor redColor]];
    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [cancelBtn setTitle:@"退    出" forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
}

//注销登录
- (void)cancelClick
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app popToLoginViewController];
}

- (void)createRightBarButton
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"完成" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveUserImage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

//表头。表尾的灰色区域
- (UIView *)grayView
{
    CGRect winRect = [UIScreen mainScreen].bounds;
    UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winRect.size.width, 100)];
    vi.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:241 / 255.0 blue:237 / 255.0 alpha:1.0];
    UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 30, winRect.size.width, 60)];
    viewTop.backgroundColor = [UIColor whiteColor];
    [vi addSubview:viewTop];
  
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 20)];
    lab.text = @"修改头像";
    [viewTop addSubview:lab];

    _imageview = [[UIImageView alloc] initWithFrame:CGRectMake(180, 5, 50, 50)];
    [_imageview setImageWithURL:[NSURL URLWithString:[[DJTGlobalManager shareInstance].userInfo.face stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"s21@2x" ofType:@"png"]]];
    _imageview.clipsToBounds = YES;
    _imageview.layer.cornerRadius = 25;
    [viewTop addSubview:_imageview];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 30, winRect.size.width, 60);
    [btn addTarget:self action:@selector(changeMyPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:btn];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winRect.size.width, .5)];
    line1.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
    [vi addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 99.5, winRect.size.width, .5)];
    line2.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
    [vi addSubview:line2];
    
    return vi;
}

- (void)changeMyPhoto:(UIButton *)sender
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 1;
    
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark - privite
- (void)changeHead:(NSString *)filePath
{
    if (self.httpOperation) {
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    [self.view makeToastActivity];
    _tableView.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    //图片上传队列
    NSDictionary *dicOne = @{@"id": [NSString stringWithFormat:@"%@",[DJTGlobalManager shareInstance].userInfo.userid],@"type": @"1",@"img": @[@"160,160"]};    //1－图片
    NSData *json = [NSJSONSerialization dataWithJSONObject:dicOne options:NSJSONWritingPrettyPrinted error:nil];
    NSString *lstJson = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *gbkStr = [lstJson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlPathImg = [NSString stringWithFormat:@"%@%@",G_UPLOAD_IMAGE,gbkStr];
    self.httpOperation = [DJTHttpClient asynchronousRequestWithProgress:urlPathImg parameters:nil filePath:filePath ssuccessBlcok:^(BOOL success, id data, NSString *msg) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [weakSelf changeHeadFinish:data Suc:success];
    } failedBlock:^(NSString *description) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [weakSelf changeHeadFinish:nil Suc:NO];
    } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
    }];
}

- (void)changeHeadFinish:(id)result Suc:(BOOL)success
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    _tableView.userInteractionEnabled = YES;
    if (success) {
        
        //_isChange = NO;
        _imagePath = nil;
        
        NSString *face = nil;
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result firstObject];
        }
        NSString *original = [result valueForKey:@"original"];
        
        if (original && [original length] > 0) {
            NSString *extension = [original pathExtension];
            NSString *thumbnail = [NSString stringWithFormat:@"%@_160_160.%@",[[original stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"original" withString:@"thumbnail"],extension];
            face = thumbnail;
        }
//        else
//        {
//            [self.view makeToast:@"头像修改失败" duration:1.0 position:@"center"];
//            return;
//        }
        
        [self saveUserInfo:face];
        
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        manager.userInfo.face = [face hasPrefix:@"http"] ? face : [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_USER_HEADER object:nil];
//        
//        
//        NSString *_newImagePath = [face stringByReplacingOccurrencesOfString:G_IMAGE_ADDRESS withString:@""];
//        
//        //图像地址提交到后台
//        NSMutableDictionary *param = [manager requestinitParamsWith:@"edit_face"];
//        [param setObject:manager.userInfo.userid forKey:@"userid"];
//        [param setObject:_newImagePath forKey:@"face_path"];
//        [param setObject:@"0" forKey:@"is_teacher"];  //0-家长,1-老师 2-园长
//        NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
//        [param setObject:text forKey:@"signature"];
//        __weak typeof(self)weakSelf = self;
//        [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"class"] parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
//            [weakSelf uploadResult:data Suc:success];
//        } failedBlock:^(NSString *description) {
//            [weakSelf uploadResult:nil Suc:NO];
//        }];
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


- (void)uploadResult:(id)result Suc:(BOOL)success
{
    if (success) {
        NSString *str = @"头像修改成功";
        if ([result valueForKey:@"message"]) {
            str = [result valueForKey:@"message"];
        }
        [self.view makeToast:str duration:1.0 position:@"center"];
    }
}

#pragma mark - actions
- (void)saveUserImage:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    SelectPickViewCell *cell = (SelectPickViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
        if (![manager.userInfo.birthday isEqualToString:[cell.textField text]]) {
            timeString = [cell.textField text];
        }
        [cell.textField resignFirstResponder];
    }
    if (!_isChange) {
        [self saveUserInfo:nil];
    }else{
        if (self.httpOperation) {
            return;
        }
        
        if (_imagePath) {
            //第一次上传失败，重新上传
            [self changeHead:_imagePath];
        }
        else
        {
            NSString *filePath = [APPTmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[NSString stringByDate:@"yyyyMMddHHmmss" Date:[NSDate date]]]];
            _imagePath = filePath;
            NSData *data = UIImageJPEGRepresentation(_imageview.image, 0.8);
            [data writeToFile:filePath atomically:NO];
            [self changeHead:filePath];
            
        }
    }
}
- (void)saveUserInfo:(NSString *)filePath
{
    if (timeString || sexString || filePath) {
        __weak __typeof(self)weakSelf = self;
        self.view.userInteractionEnabled = NO;
        self.httpOperation = [DJTHttpClient asynchronousRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"class"] parameters:[self configRequestParam:filePath] successBlcok:^(BOOL success, id data, NSString *msg) {
            [weakSelf userInfoFinish:success Data:data];
        } failedBlock:^(NSString *description) {
            [weakSelf userInfoFinish:NO Data:nil];
        }];
        
    }else{
        [self.view makeToast:@"个人信息没有修改！" duration:1.0 position:@"center"];
    }
}
#pragma mark - 参数配置
- (NSDictionary *)configRequestParam:(NSString *)filePath
{
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"editBaby"];
    [param setObject:manager.userInfo.mid forKey:@"mid"];
    [param setObject:manager.userInfo.baby_id forKey:@"baby_id"];
    if (sexString) {
        [param setObject:sexString forKey:@"sex"];
    }
    if (timeString) {
        [param setObject:timeString forKey:@"birthday"];
    }
    if (filePath) {
        [param setObject:filePath forKey:@"face"];
    }
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    return param;
}
- (void)userInfoFinish:(BOOL)success Data:(id)result
{
    self.httpOperation = nil;
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    
    if (!success) {
        NSString *str = [result objectForKey:@"ret_msg"];
        NSString *tip = str ?: REQUEST_FAILE_TIP;
        [self.view makeToast:tip duration:1.0 position:@"center"];
    }
    else
    {
        id ret_data = [result valueForKey:@"ret_data"];
        if (ret_data) {
            DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
            if (_isChange) {
                NSString *face = [ret_data valueForKey:@"face"];
                manager.userInfo.face = [face hasPrefix:@"http"] ? face : [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
                _isChange = NO;
            }
            if (timeString) {
                manager.userInfo.birthday = [ret_data objectForKey:@"birthday"];
                timeString = nil;
            }
            if (sexString) {
                manager.userInfo.sex = [ret_data objectForKey:@"sex"];
                sexString = nil;
            }
        }
        [self.view makeToast:@"修改成功" duration:1.0 position:@"center"];
    }
}
#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        ALAsset *asset = [assets firstObject];
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        //[_imageview setImage:image];
        //_isChange = YES;
        
        ImageCropViewController *controller = [[ImageCropViewController alloc] init];
        controller.originImage = image;
        controller.delegate= self;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}
#pragma mark - ImageCropViewController delegate
-(void)ImageCropVC:(ImageCropViewController*)ivc CroppedImage:(UIImage *)image
{
    if (image) {
        [_imageview setImage:image];
    }
    _isChange = YES;
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        if (indexPath.row == 1) {
            cell = [[SelectItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCellId"];
            SelectItemCell *itemCell = (SelectItemCell *)cell;
            [itemCell.itemView setItems:@[@"男",@"女"]];
            itemCell.tipLabel.text = @"性别";
            itemCell.delegate = self;
        }
        else if (indexPath.row == 2)
        {
            cell = [[SelectPickViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PickerCellId"];
            SelectPickViewCell *pickerCell = (SelectPickViewCell *)cell;
            pickerCell.tipLabel.text = @"学生的生日";
            pickerCell.textField.placeholder = @"请选择出生日期";
            pickerCell.delegate = self;
        }else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGFloat winWei = [UIScreen mainScreen].bounds.size.width;
            UILabel *titlelab = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, winWei / 2 - 40, 20)];
            titlelab.tag = 100;
            [cell.contentView addSubview:titlelab];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, winWei / 2 - 40, 20)];
            lab.tag = 200;
            [cell.contentView addSubview:lab];
        }
    }

    DJTUser *userInfo = [[DJTGlobalManager shareInstance] userInfo];
    if (indexPath.row == 1) {
        if ([cell isKindOfClass:[SelectItemCell class]])
        {
            SelectItemCell *itemCell = (SelectItemCell *)cell;
            itemCell.tipLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:@"宝宝的性别"];
            itemCell.currSex = userInfo.sex;
        }
    }
    else if (indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([cell isKindOfClass:[SelectPickViewCell class]])
        {
            
            SelectPickViewCell *pickCell = (SelectPickViewCell *)cell;
            //pickCell.tipLabel.attributedText = attributedStr;
            pickCell.textField.text = userInfo.birthday;
        }
    }else{
        NSArray *titleArray = [[NSArray alloc] initWithObjects:@"宝宝的名字",@"宝宝的性别",@"宝宝的生日",@"所在地", nil];
        UILabel *titlelab = (UILabel *)[cell.contentView viewWithTag:100];
        titlelab.text = [titleArray objectAtIndex:indexPath.row];
        
        UILabel *lab = (UILabel *)[cell.contentView viewWithTag:200];
        NSString *str;
        if ([userInfo.province isEqualToString:@""])
        {
            str = @"江苏省";
        }
        else
        {
            str = [NSString stringWithFormat:@"%@  %@",userInfo.province,userInfo.city];
        }
        NSArray *infoArray = [[NSArray alloc] initWithObjects:userInfo.realname,userInfo.sex,userInfo.birthday,str, nil];
        lab.text = [infoArray objectAtIndex:indexPath.row];
    }
    return cell;
}
#pragma mark - SelectPickViewCellDelegate
- (void)pickChangeContent:(NSString *)timer
{
    timeString = timer;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    SelectPickViewCell *cell = (SelectPickViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [cell.textField setText:timeString];
    }

    //[_paramStep2 setObject:timer forKey:@"birthday"];
}
#pragma mark - SelectItemCellDelegate
- (void)changeItemIndex:(SelectItemCell *)cell By:(SelectItemView *)itemView
{
    sexString = (itemView.nCurIndex == 0) ? @"男" : @"女";
    //[_paramStep2 setObject:(itemView.nCurIndex == 0) ? @"男" : @"女" forKey:@"sex"];
}
@end
