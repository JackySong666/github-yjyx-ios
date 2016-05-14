//
//  AddChildrenViewController.m
//  Yjyx
//
//  Created by zhujianyu on 16/2/16.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "AddChildrenViewController.h"

@interface AddChildrenViewController ()

@end

@implementation AddChildrenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self loadBackBtn];
    self.title = @"添加小孩";
    
    _parentCodeView.hidden = NO;
    _parentRegistView.hidden = YES;
    
    codeTextField.delegate = self;
    textField1.delegate = self;
    textField2.delegate = self;
    textField3.delegate = self;
    textField4.delegate = self;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked:)];
    [self.view addGestureRecognizer:tap];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    self.navigationController.navigationBarHidden = YES;
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 键盘处理
#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note{
    
    if (IS_INCH_3_5) {
        CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat ty = - rect.size.height+40;
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            self.view.center = CGPointMake(160, [UIScreen mainScreen].bounds.size.height/2 +ty);
        }];
    }
    else
    {
        CGFloat ty = - 100;
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            self.view.center = CGPointMake(160, [UIScreen mainScreen].bounds.size.height/2 +ty);
            
        }];
    }
    
}
#pragma mark 键盘即将退出
- (void)keyBoardWillHide:(NSNotification *)note{
    
    if (IS_INCH_3_5) {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            self.view.center = CGPointMake(160, [UIScreen mainScreen].bounds.size.height/2 );
        }];
    }
    else
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            self.view.center = CGPointMake(160, [UIScreen mainScreen].bounds.size.height/2 );
        }];
    }
}
#pragma mark - 文本框代理方法
#pragma mark 点击textField键盘的回车按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)clicked:(id)sender
{
    [self.view hideKeyboard];
}


#pragma mark -BtnClicked

-(IBAction)checkCode:(id)sender
{
    if (codeTextField.text.length == 0) {
        [self.view makeToast:@"请输入邀请码" duration:1.0 position:SHOW_CENTER complete:nil];
        return;
    }
    [self.view makeToastActivity:SHOW_CENTER];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:codeTextField.text,@"code",@"checkcode",@"action",[YjyxOverallData sharedInstance].parentInfo.pid,@"pid",nil];
    [[YjxService sharedInstance] parentsAboutChildrenSetting:dic withBlock:^(id result, NSError *error){
        [self.view hideToastActivity];
        if (result) {
            if ([[result objectForKey:@"retcode"] integerValue] == 0) {
                _parentRegistView.hidden = NO;
                _parentCodeView.hidden = YES;
                childrenLb.text = [result objectForKey:@"school"];
                relationshipLb.text =[NSString stringWithFormat:@"是%@的",[result objectForKey:@"childname"]];
                childrenCid = [result objectForKey:@"cid"];
                childrenEntity = [[ChildrenEntity alloc] init];
                childrenEntity.name = [result objectForKey:@"childname"];
                childrenEntity.cid = [result objectForKey:@"cid"];
                
            }else{
                [self.view makeToast:[result objectForKey:@"msg"] duration:1.0 position:SHOW_CENTER complete:nil];
            }
            
        }else{
            [self.view makeToast:[error description] duration:1.0 position:SHOW_CENTER complete:nil];
        }
    }];
}

-(IBAction)registBtn:(id)sender
{
    if (textField4.text.length == 0) {
        [self.view makeToast:@"请输入完整信息" duration:1.0 position:SHOW_CENTER complete:nil];
    }else{
        [self.view makeToastActivity:SHOW_CENTER];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:textField4.text,@"relation",childrenCid,@"cid",@"submit",@"action",[YjyxOverallData sharedInstance].parentInfo.pid,@"pid",nil];
        [[YjxService sharedInstance] parentsAboutChildrenSetting:dic withBlock:^(id result, NSError *error){
            [self.view hideToastActivity];
            if (result) {
                if ([[result objectForKey:@"retcode"] integerValue] == 0) {
                    childrenEntity.relation = textField4.text;
                    childrenEntity.childavatar = @"";
                    [[YjyxOverallData sharedInstance].parentInfo.childrens addObject:childrenEntity];
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [self.view makeToast:[result objectForKey:@"msg"] duration:1.0 position:SHOW_CENTER complete:nil];
                }
            }else{
                [self.view makeToast:[error description] duration:1.0 position:SHOW_CENTER complete:nil];
            }
        }];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
