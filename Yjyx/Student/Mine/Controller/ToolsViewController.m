//
//  ToolsViewController.m
//  Yjyx
//
//  Created by liushaochang on 16/8/12.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "ToolsViewController.h"

@interface ToolsViewController ()

@end

@implementation ToolsViewController


- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"常用工具";
    UIImage *image = [UIImage imageNamed:@"isbuilding"];
    UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
    imageV.width = SCREEN_WIDTH - 80;
    imageV.height = image.size.height *imageV.width/image.size.width;
    imageV.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);

    [self.view addSubview:imageV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
