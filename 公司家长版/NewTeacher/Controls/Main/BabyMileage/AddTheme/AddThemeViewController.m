//
//  AddThemeViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/2.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "AddThemeViewController.h"
#import "NSString+Common.h"
#import "Toast+UIView.h"
#import "NSString+Common.h"
#import "TemplateModel.h"
#import "BabyMileageViewController.h"

@interface AddThemeViewController ()<UITextFieldDelegate>

@end

@implementation AddThemeViewController
{
    UITextField *_nameField,*_explainField;
    NSMutableArray *_tipsArr;
    NSInteger _maxLength;
    UIView *middleView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    if (_themeType == MileageThemeAdd) {
        self.titleLable.text = @"新增宝宝里程主题";
    }else if (_themeType == MileageThemeEdit){
        self.titleLable.text = @"修改宝宝里程主题";
    }else if (_themeType == MileageThemeSee){
        self.titleLable.text = @"查看宝宝里程主题";
    }
    
    self.view.backgroundColor = CreateColor(238, 239, 243);
    //_tipsArr = @[@"互戏",@"有趣的户外动游动游活动1",@"互戏1",@"互戏",@"愉快的动游暑假1",@"互动动游游戏2",@"有趣外活动2",@"愉快的暑假2",@"互动3",@"外活动3",@"愉快的暑假3"];
    _tipsArr = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    //bg
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 110)];
    headView.backgroundColor = [UIColor whiteColor];
    headView.userInteractionEnabled = YES;
    [self.view addSubview:headView];
    //fields
    for (int i = 0; i < 2; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, (i == 0) ? 20 : 60, 80, 30)];
        label.font = [UIFont systemFontOfSize:16];
        label.text = (i == 0) ? @"主题名称" : @"主题说明";
        [headView addSubview:label];
        CGSize size = [self calculeteConSize:30 Font:label.font Content:label.text];
        label.frame = CGRectMake(10, (i == 0) ? 20 : 60, size.width, 30);
        
        UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width + 5, label.frame.origin.y - 5, winSize.width - (label.frame.origin.x + label.frame.size.width + 15), label.frame.size.height)];
        textFiled.autocorrectionType = UITextAutocorrectionTypeNo;
        textFiled.contentVerticalAlignment = 0 ;
        textFiled.returnKeyType = UIReturnKeyDone;
        textFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textFiled.font = [UIFont systemFontOfSize:12];
        textFiled.textAlignment = NSTextAlignmentRight;
        [textFiled setClearButtonMode:UITextFieldViewModeWhileEditing];
        textFiled.delegate = self;
        [headView addSubview:textFiled];
        
        if (i == 0) {
            _nameField = textFiled;
            [textFiled setPlaceholder:@"最多12个汉字"];
            if (_themeType == MileageThemeEdit) {
                [textFiled setText:_mileage.name];
            }
        }
        else{
            _explainField = textFiled;
            [textFiled setPlaceholder:@"最多80个汉字"];
            if (_themeType == MileageThemeEdit) {
                [textFiled setText:_mileage.digst];
            }
        }
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(textFiled.frame.origin.x, textFiled.frame.origin.y + textFiled.frame.size.height, textFiled.frame.size.width, 0.5)];
        lineLabel.backgroundColor = [UIColor lightGrayColor];
        [headView addSubview:lineLabel];
    }

    //middle
    middleView = [[UIView alloc] initWithFrame:CGRectMake(0, headView.frame.origin.y + headView.frame.size.height + 10, winSize.width, 150)];
    middleView.backgroundColor = [UIColor whiteColor];
    middleView.userInteractionEnabled = YES;
    [self.view addSubview:middleView];
    
    UILabel *themeTip = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, winSize.width - 120, 30)];
    [themeTip setText:@"推荐宝宝里程主题:"];
    themeTip.font = [UIFont systemFontOfSize:16];
    [middleView addSubview:themeTip];
    
    UIImageView *rightImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mileageRefresh" ofType:@"png"]]];
    rightImgView.frame = CGRectMake(70, 5, 20, 20);
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeBtn addSubview:rightImgView];
    changeBtn.frame = CGRectMake(winSize.width - 100 - 10, 10, 100, 30);
    [changeBtn setTitle:@"换一组" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [changeBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [changeBtn addTarget:self action:@selector(refreshThemeName:) forControlEvents:UIControlEventTouchUpInside];
    [middleView addSubview:changeBtn];
    
    //themes
    [self themeButton];
    
    UIButton *sureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBut setTitle:@"确  认" forState:UIControlStateNormal];
    [sureBut setBackgroundColor:CreateColor(243, 155, 40)];
    [sureBut setFrame:CGRectMake(0, winSize.height - 50 - 64, winSize.width, 50)];
    [sureBut addTarget:self action:@selector(sureSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBut];
    
    [self getThemeTemplate];
}

- (void)getThemeTemplate
{
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getThemeTemplate"];
    [param setObject:@"10" forKey:@"num"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf getThemeTemplateFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf getThemeTemplateFinish:NO Data:nil];
    }];
}

- (void)getThemeTemplateFinish:(BOOL)suc Data:(id)result{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (suc) {
        if ([_tipsArr count] > 0) {
            [_tipsArr removeAllObjects];
        }
        id ret_data = [result valueForKey:@"ret_data"];
        NSArray *data = (!ret_data || [ret_data isKindOfClass:[NSNull class]]) ? [NSArray array] : ret_data;
        for (id subDic in data) {
            NSError *error;
            TemplateModel *template = [[TemplateModel alloc] initWithDictionary:subDic error:&error];
            if (error) {
                NSLog(@"%@",error.description);
                continue;
            }
            
            [_tipsArr addObject:template];
        }
        [self themeButton];
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

- (void)themeButton {
    //themes
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    UIView *tempView = [middleView viewWithTag:10];
    if (tempView) {
        [tempView removeFromSuperview];
    }
    tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, winSize.width, middleView.frame.size.height - 40)];
    tempView.backgroundColor = [UIColor clearColor];
    tempView.userInteractionEnabled = YES;
    [tempView setTag:10];
    [middleView addSubview:tempView];
    
    CGFloat butWei = 0,butHei = 20;
    NSInteger numPerRow = 0;
    CGFloat xOri = 10;
    CGFloat yOri = 10;
    
    for (int i = 0; i < [_tipsArr count]; i++) {
        TemplateModel *model = _tipsArr[i];
        CGSize size = [self calculeteConSize:20 Font:[UIFont systemFontOfSize:12] Content:model.name];
        if (xOri + size.width + 10 > winSize.width -20) {
            numPerRow ++;
            yOri = 10 + (butHei + 10) * numPerRow;
            xOri = 10;
        }
        butWei = size.width + 10;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(xOri, yOri, butWei, butHei)];
        [button setBackgroundColor:CreateColor(177, 211, 240)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3;
        button.tag = i + 1;
        [button setTitleColor:CreateColor(61, 135, 211) forState:UIControlStateNormal];
        [button setTitle:model.name forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button addTarget:self action:@selector(changeThemeName:) forControlEvents:UIControlEventTouchUpInside];
        [tempView addSubview:button];
        
        xOri += butWei + 10;
    }
    tempView.frame = CGRectMake(0, 40, winSize.width, yOri + 10 + 30);
    CGRect rect = middleView.frame;
    rect.size.height = yOri + 40 + 30;
    middleView.frame = rect;
}
- (CGSize)calculeteConSize:(CGFloat)maxWei Font:(UIFont *)font Content:(NSString *)content
{
    CGSize lastSize = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    lastSize = [content boundingRectWithSize:CGSizeMake(3000, maxWei) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return lastSize;
}

- (void)refreshThemeName:(id)sender {
    [self getThemeTemplate];
}
- (void)changeThemeName:(id)sender{
    NSInteger index = [sender tag] - 1;
    TemplateModel *model = _tipsArr[index];
    _nameField.text = model.name;
    _explainField.text = model.digst;
}

- (void)sureSubmit:(id)sender{
    if (_nameField.text.length == 0) {
        [self.view.window makeToast:@"请输入主题名称" duration:1.0 position:@"center"];
        return;
    }
    
    if ([DJTGlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    [self resignAllFields];
    __weak __typeof(self)weakSelf = self;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSString *methods = (_themeType == MileageThemeEdit) ? @"editAlbum" : @"createAlbum";
    NSMutableDictionary *param = [manager requestinitParamsWith:methods];
    if (_themeType == MileageThemeEdit) {
        [param setObject:_mileage.album_id forKey:@"album_id"];
    }
    [param setObject:_nameField.text forKey:@"name"];
    [param setObject:(_explainField.text.length == 0) ? @"" : _explainField.text forKey:@"description"];
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    
    [self.view makeToastActivity];
    [self.view setUserInteractionEnabled:NO];
    //针对新接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:@"photo"];
    self.httpOperation = [DJTHttpClient asynchronousRequest:url parameters:param successBlcok:^(BOOL success, id data, NSString *msg) {
        [weakSelf submitFinish:success Data:data];
    } failedBlock:^(NSString *description) {
        [weakSelf submitFinish:NO Data:nil];
    }];
}

- (void)resignAllFields{
    if (_explainField.isFirstResponder) {
        [_explainField resignFirstResponder];
    }
    else if (_nameField.isFirstResponder){
        [_nameField resignFirstResponder];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self resignAllFields];
}

#pragma mark - network
- (void)submitFinish:(BOOL)suc Data:(id)result{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    self.httpOperation = nil;
    if (suc) {
        if (_themeType == MileageThemeEdit) {
            if (_delegate && [_delegate respondsToSelector:@selector(editThemeFinish)]) {
                _mileage.name = _nameField.text;
                _mileage.digst = _explainField.text;
                [_delegate editThemeFinish];
            }
        }
        else if (_themeType == MileageThemeAdd)
        {
            if (_delegate && [_delegate respondsToSelector:@selector(addNewTheme:)]) {
                MileageModel *model = [[MileageModel alloc] init];
                model.name = _nameField.text;
                model.digst = _explainField.text;
                model.mileage_type = [NSNumber numberWithInteger:1];
                id ret_data = [result valueForKey:@"ret_data"];
                NSString *album_id = [ret_data valueForKey:@"album_id"];
                if ([album_id isKindOfClass:[NSNumber class]]) {
                    album_id = [(NSNumber *)album_id stringValue];
                }
                model.album_id = album_id;
                [model caculateNameHei];
                [_delegate addNewTheme:model];
            }
        }
        [self.navigationController.view makeToast:(_themeType == MileageThemeEdit) ? @"宝宝里程修改成功" : @"宝宝里程新增成功" duration:1.0 position:@"center"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        id ret_msg = [result valueForKey:@"ret_msg"];
        [self.view makeToast:ret_msg ?: REQUEST_FAILE_TIP duration:1.0 position:@"center"];
    }
}

#pragma mark - UITextFieldTextDidChangeNotification
- (void)textFieldChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if (textField == _nameField) {
        _maxLength = 12;
    }
    else if (textField == _explainField){
        _maxLength = 80;
    }
    else{
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
            [self emojiStrSplit:toBeString];
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        [self emojiStrSplit:toBeString];
    }
}

- (void)emojiStrSplit:(NSString *)str
{
    int emoji = -1;
    NSString *lastStr = str;
    while ((lastStr && [lastStr length] > 0) && ((emoji = [NSString containsEmoji:lastStr]) != -1)) {
        int lenght = emoji % 10000;
        int location = emoji / 10000;
        lastStr = [lastStr stringByReplacingCharactersInRange:NSMakeRange(location,lenght) withString:@""];
    }
    if (lastStr != str) {
        if (_maxLength == 12) {
            [_nameField setText:lastStr];
        }else{
            [_explainField setText:lastStr];
        }
    }
    
    if ([lastStr length] > _maxLength) {
        lastStr = [lastStr substringToIndex:_maxLength];
        if (_maxLength == 12) {
            [_nameField setText:lastStr];
        }else{
            [_explainField setText:lastStr];
        }
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
