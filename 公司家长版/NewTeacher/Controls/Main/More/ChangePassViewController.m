//
//  ChangePassViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 15/1/12.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "ChangePassViewController.h"
#import "Toast+UIView.h"

@interface ChangePassViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ChangePassViewController
{
    UITextField *_oldField,*_newField,*_newAgainField;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"修改密码";
    [self createRightBarButton];
    self.view.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:241 / 255.0 blue:237 / 255.0 alpha:1.0];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 40;
    tableView.scrollEnabled = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView setTableFooterView:[[UIView alloc] init]];
    [self.view addSubview:tableView];
}

- (void)createRightBarButton
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    saveBtn.backgroundColor = [UIColor clearColor];
    [saveBtn setTitle:@"完成" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor colorWithRed:199 / 255.0 green:57 / 255.0 blue:81 / 255.0 alpha:1] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveUserImage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,backBarButtonItem];
}

- (void)saveUserImage:(id)sender
{
    if (self.httpOperation) {
        return;
    }
    
    if (_oldField.text && [_oldField.text length] > 0) {
        NSString *oldStr = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_PASSWORD];
        if (([oldStr length] > 0) && ![_oldField.text isEqualToString:oldStr]) {
            [self.view makeToast:@"旧密码输入错误" duration:1.0 position:@"center"];
            return;
        }
    }
    else
    {
        [self.view makeToast:@"请输入旧密码" duration:1.0 position:@"center"];
        return;
    }
    
    if (!_newField || _newField.text.length <= 0) {
        [self.view makeToast:@"请输入新密码" duration:1.0 position:@"center"];
        return;
    }
    
    if (!_newAgainField || _newAgainField.text.length <= 0) {
        [self.view makeToast:@"请再次输入新密码" duration:1.0 position:@"center"];
        return;
    }
    
    if (![_newField.text isEqualToString:_newAgainField.text]) {
        [self.view makeToast:@"两次新密码输入不一致" duration:1.0 position:@"center"];
        return;
    }
    
    if (_newField.text.length < 6) {
        [self.view makeToast:@"密码长度必须大于或等于6位" duration:1.0 position:@"center"];
        return;
    }
    
    if (_oldField.isFirstResponder) {
        [_oldField resignFirstResponder];
    }
    else if (_newField.isFirstResponder)
    {
        [_newField resignFirstResponder];
    }
    else if (_newAgainField.isFirstResponder)
    {
        [_newAgainField resignFirstResponder];
    }
    
    [self requestChangePass];
}

#pragma mark - 修改密码
- (void)requestChangePass
{
    //start
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [URLFACE stringByAppendingString:@"center:edit_password"];
    NSDictionary *dic = @{@"userid":[DJTGlobalManager shareInstance].userInfo.userid,@"old_password":_oldField.text,@"new_password":_newField.text,@"confirm_password":_newAgainField.text};
    self.httpOperation = [DJTHttpClient asynchronousNormalRequest:url parameters:dic successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf changePassFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf changePassFinish:NO Data:nil];
    }];
}

- (void)changePassFinish:(BOOL)success Data:(id)result
{
    [self.view hideToastActivity];
    self.view.userInteractionEnabled = YES;
    NSString *tip = nil;
    if (success) {
        tip = @"密码修改成功";
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *oldStr = [userDef objectForKey:LOGIN_PASSWORD];
        if ([oldStr length] > 0) {
            [userDef setObject:_newField.text forKey:LOGIN_PASSWORD];
            [userDef synchronize];
        }

    }
    else
    {
        tip = @"密码修改失败";
    }
    [self.view makeToast:tip duration:1.0 position:@"center"];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //textfield
        CGFloat winWei = [UIScreen mainScreen].bounds.size.width;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, winWei - 140, 20)];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textField setBackgroundColor:[UIColor colorWithRed:239/255.0 green:241/255.0 blue:237/255.0 alpha:1.0]];
        textField.textAlignment = 1;
        [textField setTag:200];
        textField.textColor = [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1];
        textField.contentVerticalAlignment = 0 ;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.secureTextEntry = YES;
        textField.placeholder = @"必填";
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.returnKeyType = UIReturnKeyDone;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
    }
    
    UITextField *tf = (UITextField *)[cell.contentView viewWithTag:200];
    if (indexPath.section == 0) {
        _oldField = tf;
        cell.textLabel.text = @"原密码";
    }
    else
    {
        if (indexPath.row == 0) {
            _newField = tf;
            cell.textLabel.text = @"新密码";
        }
        else
        {
            _newAgainField = tf;
            cell.textLabel.text = @"确认新密码";
        }
    }
    
    return cell;
}

@end
