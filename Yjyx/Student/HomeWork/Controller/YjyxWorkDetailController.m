//
//  YjyxWorkDetailController.m
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/7/6.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "YjyxWorkDetailController.h"
#import "YjyxStuAnswerModel.h"
#import "YjyxWorkDetailModel.h"
#import "YjyxWorkContentCell.h"
#import "YjyxMicroWorkModel.h"
#import "ReleaseMicroCell.h"
#import "MicroKnowledgeCell.h"
#import "YjyxStuAnswerModel.h"
#import "ChildrenVideoViewController.h"
#import "ChildrenResultCell.h"
#import "WMPlayer.h"
#import "YjyxOneSubjectViewController.h"
@interface YjyxWorkDetailController ()<UITableViewDelegate, UITableViewDataSource>
{
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
    BOOL isPlay;
}
@property (strong, nonatomic) NSArray *stuChoiceAnswerArr;
@property (strong, nonatomic) NSArray *stuBlankAnswerArr;
@property (strong, nonatomic) NSArray *stuChoiceContentArr;
@property (strong, nonatomic) NSArray *stuBlankContentArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) YjyxMicroWorkModel *model;

@property (nonatomic, strong) NSMutableDictionary *choiceCellHeightDic;
@property (nonatomic, strong) NSMutableDictionary *blankfillHeightDic;
@property (nonatomic, strong) NSMutableDictionary *blankfillExpandDic;

@property (strong, nonatomic) ReleaseMicroCell *videoCell;
@end

@implementation YjyxWorkDetailController

static NSString *ID = @"CELL";
static NSString *NorID = @"cell";
static NSString *MicroID = @"MicroID";
static NSString *KnowID = @"KnowID";
#pragma mark - 懒加载

#pragma mark - view的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"comm_back"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    [self loadData];
    self.choiceCellHeightDic = [[NSMutableDictionary alloc] init];
    self.blankfillHeightDic = [[NSMutableDictionary alloc] init];
    self.blankfillExpandDic = [[NSMutableDictionary alloc] init];
    self.tableView.sectionFooterHeight = 10;
    self.tableView.sectionHeaderHeight = 20;
    self.tableView.backgroundColor = COMMONCOLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ChildrenResultCell class]) bundle:nil] forCellReuseIdentifier:ID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NorID];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ReleaseMicroCell class]) bundle:nil] forCellReuseIdentifier:MicroID];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MicroKnowledgeCell class]) bundle:nil] forCellReuseIdentifier:KnowID];
    // 注册加载完成高度的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableviewCellHeight:) name:@"WEBVIEW_HEIGHT" object:nil];

    
    //注册播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //注册播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:WMPlayerFullScreenButtonClickedNotification object:nil];
    // 返回按钮被点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backBtnClicked) name:@"BackButtonClicked" object:nil];
    //关闭通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeTheVideo:)
                                                 name:WMPlayerClosedNotification
                                               object:nil
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self setNeedsStatusBarAppearanceUpdate];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    if ([self.taskType isEqual:@1]) {
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.navigationController.navigationBarHidden = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
    }
}
- (void)dealloc
{
    [self releaseWMPlayer];
}
- (BOOL)prefersStatusBarHidden
{
    
    if ([self.taskType isEqual:@1]) {
        return NO;
    }else{
    return YES;
    }
}
#pragma mark - 私有方法
- (void)backBtnClicked
{
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if([vc isKindOfClass:[YjyxOneSubjectViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
// 通知方法
- (void)refreshTableviewCellHeight:(NSNotification *)sender {
    
   YjyxWorkContentCell *cell = [sender object];
    NSLog(@"%ld-%ld", cell.indexPath.section, cell.indexPath.row);
    // 保存高度
    if (cell.indexPath.section == 3) {
        
        if (![self.choiceCellHeightDic objectForKey:[NSString stringWithFormat:@"%ld",cell.tag]]||[[self.choiceCellHeightDic objectForKey:[NSString stringWithFormat:@"%ld",cell.tag]] floatValue] != cell.height)
        {
            [self.choiceCellHeightDic setObject:[NSNumber numberWithFloat:cell.height] forKey:[NSString stringWithFormat:@"%ld",cell.tag]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:3 ]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }else if(cell.indexPath.section == 4){
        if (![self.blankfillHeightDic objectForKey:[NSString stringWithFormat:@"%ld",cell.tag]]||[[self.blankfillHeightDic objectForKey:[NSString stringWithFormat:@"%ld",cell.tag]] floatValue] != cell.height)
        {
            
            NSLog(@"%@", [self.blankfillHeightDic objectForKey:[NSString stringWithFormat:@"%ld",cell.tag]]);
            NSLog(@"%.f", cell.height);
            
            [self.blankfillHeightDic setObject:[NSNumber numberWithFloat:cell.height] forKey:[NSString stringWithFormat:@"%ld",cell.tag]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:4 ]] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
    }
    
}

- (void)loadData
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"action"] = @"m_viewresult";
    NSLog(@"%@", self.t_id);
    param[@"tasktrackid"] = self.t_id;
    
    NSLog(@"----%@", param);
    [mgr GET:[BaseURL stringByAppendingString:@"/api/student/tasks/"] parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        NSLog(@"%@", responseObject);
//        NSLog(@"%@",responseObject[@"data"][@"result"][@"choice"]);
        YjyxMicroWorkModel *model = [YjyxMicroWorkModel microWorkModelWithDict:responseObject[@"data"][@"lessonobj"]];
        _model = model;
        NSMutableArray *tempArr1 = [NSMutableArray array];
        NSMutableArray *tempArr2 = [NSMutableArray array];
        for (NSArray *arr in responseObject[@"data"][@"result"][@"choice"]) {
            YjyxStuAnswerModel *model = [YjyxStuAnswerModel stuAnswerModelWithArr:arr];
            model.subject_type = @1;
            [tempArr1 addObject:model];
        }
        for (NSArray *arr in responseObject[@"data"][@"result"][@"blankfill"]) {
            YjyxStuAnswerModel *model = [YjyxStuAnswerModel stuAnswerModelWithArr:arr];
            model.subject_type = @2;
            [tempArr2 addObject:model];
        }
        self.stuChoiceAnswerArr = tempArr1;
        self.stuBlankAnswerArr = tempArr2;
        NSMutableArray *tempArr3 = [NSMutableArray array];
        NSMutableArray *tempArr4 = [NSMutableArray array];
        NSLog(@"%@", responseObject[@"data"][@"choices"]);
        NSDictionary *dict = responseObject[@"data"][@"choices"];
        for (YjyxStuAnswerModel *model in tempArr1) {
          

            YjyxWorkDetailModel *model1 = [YjyxWorkDetailModel workDetailModelWithDict:dict[model.t_id]];
            [tempArr3 addObject:model1];
        }
        for (YjyxStuAnswerModel *model in tempArr2) {
            NSDictionary *dict = responseObject[@"data"][@"blankfills"];
            YjyxWorkDetailModel *model1 = [YjyxWorkDetailModel workDetailModelWithDict:dict[model.t_id]];
            [tempArr4 addObject:model1];
        }
//        self.stuChoiceContentArr;
        self.stuChoiceContentArr = tempArr3;
        self.stuBlankContentArr = tempArr4;
//        NSLog(@"%@------%ld", tempArr3, tempArr4.count);
        NSLog(@"%ld",  self.stuChoiceContentArr.count);
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:error.localizedDescription duration:1.0 position:SHOW_CENTER complete:nil];
        [SVProgressHUD showWithStatus:error.localizedDescription];
    }];
}
#pragma mark - wmPlayer的方法
-(void)videoDidFinished:(NSNotification *)notice{
    ReleaseMicroCell *currentCell = (ReleaseMicroCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    isPlay = NO;
    currentCell.playBtn.hidden = NO;
    [self releaseWMPlayer];
//    [self setNeedsStatusBarAppearanceUpdate];
}
-(void)closeTheVideo:(NSNotification *)obj{
    
    ReleaseMicroCell *currentCell = (ReleaseMicroCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    currentCell.playBtn.hidden = NO;
    isPlay = NO;
    [self releaseWMPlayer];
//    [self setNeedsStatusBarAppearanceUpdate];
}
-(void)fullScreenBtnClick:(NSNotification *)notice{
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        wmPlayer.isFullscreen = YES;
//        [self setNeedsStatusBarAppearanceUpdate];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        if (isSmallScreen) {
            //放widow上,小屏显示
            [self toSmallScreen];
        }else{
            [self toCell];
        }
    }
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange{
    if (wmPlayer==nil||wmPlayer.superview==nil){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            if (wmPlayer.isFullscreen) {
                if (isSmallScreen) {
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }else{
                    [self toCell];
                }
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            if (wmPlayer.isFullscreen == NO) {
                wmPlayer.isFullscreen = YES;
                
//                [self setNeedsStatusBarAppearanceUpdate];
                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            if (wmPlayer.isFullscreen == NO) {
                wmPlayer.isFullscreen = YES;
//                [self setNeedsStatusBarAppearanceUpdate];
                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            }
        }
            break;
        default:
            break;
    }
}


-(void)toCell{
    ReleaseMicroCell *currentCell = (ReleaseMicroCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [wmPlayer removeFromSuperview];
    NSLog(@"row = %ld",(long)currentIndexPath.row);
    wmPlayer.closeBtn.hidden = YES;
    [UIView animateWithDuration:0.5f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = currentCell.backgroundIV.bounds;
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [currentCell.backgroundIV addSubview:wmPlayer];
        [currentCell.backgroundIV bringSubviewToFront:wmPlayer];
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(5);
        }];
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        isSmallScreen = NO;
        wmPlayer.fullScreenBtn.selected = NO;
        
    }];
    
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [wmPlayer removeFromSuperview];
    wmPlayer.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    wmPlayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    wmPlayer.playerLayer.frame =  CGRectMake(0,0, SCREEN_HEIGHT,SCREEN_WIDTH);
    wmPlayer.closeBtn.hidden = NO;
    [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(SCREEN_WIDTH-40);
        make.width.mas_equalTo(SCREEN_HEIGHT);
    }];
    
    [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wmPlayer).with.offset((-SCREEN_HEIGHT/2));
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.top.equalTo(wmPlayer).with.offset(5);
        
    }];
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
    
    wmPlayer.fullScreenBtn.selected = YES;
    [wmPlayer bringSubviewToFront:wmPlayer.bottomView];
    
}
-(void)toSmallScreen{
    //放widow上
    [wmPlayer removeFromSuperview];
    [UIView animateWithDuration:0.5f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = CGRectMake(SCREEN_WIDTH/2,SCREEN_HEIGHT-60-(SCREEN_WIDTH/2)*0.575, SCREEN_WIDTH/2, (SCREEN_WIDTH/2)*0.575);
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
        wmPlayer.closeBtn.hidden = NO;
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(5);
            
        }];
        
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        wmPlayer.fullScreenBtn.selected = NO;
        isSmallScreen = YES;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:wmPlayer];
    }];
    
}
-(void)startPlayVideo:(UIButton *)sender{
    currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NSLog(@"currentIndexPath.row = %ld",(long)currentIndexPath.row);
    
    isPlay = YES;
    
    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
        self.videoCell = (ReleaseMicroCell *)sender.superview.superview;
    }else{//ios7系统 UITableViewCell上多了一个层级UITableViewCellScrollView
        self.videoCell = (ReleaseMicroCell *)sender.superview.superview.subviews;
        
    }
    
    //    isSmallScreen = NO;
    if (isSmallScreen) {
        [self releaseWMPlayer];
        isSmallScreen = NO;
        
    }
    if (wmPlayer) {
        [wmPlayer removeFromSuperview];
        wmPlayer.backBtn.hidden = YES;
        wmPlayer.closeBtn.hidden = YES;
        [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
        [wmPlayer setVideoURLStr:_model.videoobjlist.firstObject[@"url"]];
        [wmPlayer.player play];
    }else{
        
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.videoCell.backgroundIV.bounds videoURLStr:_model.videoobjlist.firstObject[@"url"]];
        wmPlayer.backBtn.hidden = YES;
        wmPlayer.closeBtn.hidden = YES;
        
    }
    
    // 将按钮放到底部
    [self.videoCell.backgroundIV addSubview:wmPlayer];
    [self.videoCell.backgroundIV bringSubviewToFront:wmPlayer];
    //    [self.videoCell.playBtn.superview sendSubviewToBack:self.videoCell.playBtn];
    self.videoCell.playBtn.hidden = YES;
    
    [self.tableView reloadData];
    
}
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [wmPlayer.player.currentItem cancelPendingSeeks];
    [wmPlayer.player.currentItem.asset cancelLoading];
    [wmPlayer.player pause];
    
    //移除观察者
    [wmPlayer.currentItem removeObserver:wmPlayer forKeyPath:@"status"];
    
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
    
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    [wmPlayer.durationTimer invalidate];
    wmPlayer.durationTimer = nil;
    
    
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.tableView){
        if (wmPlayer==nil) {
            return;
        }
        
        if (wmPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:currentIndexPath];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            if (rectInSuperview.origin.y<-self.videoCell.backgroundIV.frame.size.height||rectInSuperview.origin.y>SCREEN_HEIGHT-64-60) {//往上拖动
                
                if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]&&isSmallScreen) {
                    isSmallScreen = YES;
                }else{
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }
                
            }else{
                if ([self.videoCell.backgroundIV.subviews containsObject:wmPlayer]) {
                    
                }else{
                    [self toCell];
                }
            }
        }
        
    }
}


#pragma mark -myevent
-(void)playVideo:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    ChildrenResultCell *cell = (ChildrenResultCell *)btn.superview.superview.superview;
    
    NSString *videoUrl;
    NSString *explantionStr;
    
    if (cell.indexPath.section == 3) {//选择题
        if (self.stuChoiceAnswerArr.count > 0) {
            YjyxWorkDetailModel *rmodel = self.stuChoiceContentArr[cell.indexPath.row - 1];
            //        ChildrenResultModel *model = [self.choiceModelDic objectForKey:[NSString stringWithFormat:@"%@", rmodel.q_id]];
            
            videoUrl = rmodel.videourl;
            explantionStr = rmodel.explanation;
        }else{
            YjyxWorkDetailModel *rmodel = self.stuBlankContentArr[cell.indexPath.row -1];
            //        ChildrenResultModel *model = [self.blankfillModelDic objectForKey:[NSString stringWithFormat:@"%@", rmodel.q_id]];
            
            videoUrl = rmodel.videourl;
            explantionStr = rmodel.explanation;
        }
    
    }else if(cell.indexPath.section == 4){//填空题
        YjyxWorkDetailModel *rmodel = self.stuBlankContentArr[cell.indexPath.row -1];
//        ChildrenResultModel *model = [self.blankfillModelDic objectForKey:[NSString stringWithFormat:@"%@", rmodel.q_id]];
        
        videoUrl = rmodel.videourl;
        explantionStr = rmodel.explanation;
    }
    
    //判断是否有权限查看视频解析
    
    if (videoUrl.length == 0 &&explantionStr.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"查看解题方法需要会员权限，是否前往试用或成为会员" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alertView show];
    }else{
        ChildrenVideoViewController *vc = [[ChildrenVideoViewController alloc] init];
        vc.URLString = videoUrl;
        vc.explantionStr = explantionStr;
        vc.title = @"详解";
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
- (void)studentChangeCellHeight:(UIButton *)sender {
    
    ChildrenResultCell *cell = (ChildrenResultCell *)sender.superview.superview.superview;
    cell.expandBtn.selected = !cell.expandBtn.selected;
    
    if (cell.expandBtn.selected == YES) {
        [self.blankfillExpandDic setObject:@"YES" forKey:[NSString stringWithFormat:@"%ld", cell.indexPath.row]];
    }else {
        [self.blankfillExpandDic setObject:@"NO" forKey:[NSString stringWithFormat:@"%ld", cell.indexPath.row]];
    }
    NSLog(@"%ld---- %ld", cell.indexPath.section, cell.indexPath.row);
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.indexPath.row inSection:cell.indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    
}
#pragma mark - UITableView数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%ld, %ld", self.stuBlankAnswerArr.count, self.stuChoiceAnswerArr.count);
    if (self.stuBlankAnswerArr.count == 0 && self.stuChoiceAnswerArr.count == 0) {
        return 0;
    }
    if (self.stuBlankAnswerArr.count != 0 && self.stuChoiceAnswerArr.count != 0) {
        return 2 + 3;
    }else{
        return 1 + 3;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3) {
        if (self.stuChoiceAnswerArr.count != 0) {
            return self.stuChoiceAnswerArr.count + 1;
        }else{
           return  self.stuBlankAnswerArr.count + 1;
        }
    }else if(section == 4){
        return self.stuBlankAnswerArr.count + 1;
    }else{
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        ReleaseMicroCell *cell = [tableView dequeueReusableCellWithIdentifier:MicroID];
        
        self.videoCell = cell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.playBtn.tag = indexPath.row;
        
        // 按钮的显示
        if (isPlay == YES) {
            cell.playBtn.hidden = YES;
        }else {
            
            cell.playBtn.hidden = NO;
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
        }
        
        if (wmPlayer&&wmPlayer.superview) {
            if (indexPath.row == currentIndexPath.row) {
                [cell.backgroundIV.superview sendSubviewToBack:cell.backgroundIV];
            }else{
                
                
            }
            
            NSArray *indexpaths = [tableView indexPathsForVisibleRows];
            
            if (![indexpaths containsObject:currentIndexPath]&&currentIndexPath!=nil) {//复用
                
                if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]) {
                    wmPlayer.hidden = NO;
                }else{
                    wmPlayer.hidden = YES;
                    
                    NSLog(@"%d", isPlay);
                    
                }
            }else{
                if ([cell.backgroundIV.subviews containsObject:wmPlayer]) {
                    [cell.backgroundIV addSubview:wmPlayer];
                    
                    [wmPlayer.player play];
                    wmPlayer.hidden = NO;
                }
                
            }
        }
        cell.model = _model;
        return cell;
    
    }else if(indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NorID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = self.model.name;
        return cell;
    }else if(indexPath.section == 2){
        MicroKnowledgeCell *cell = [tableView dequeueReusableCellWithIdentifier:KnowID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.workModel = self.model;
        return cell;
    }else if (indexPath.section == 3){
        if (self.stuChoiceAnswerArr.count != 0) {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NorID];
                cell.textLabel.text = @"选择题";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                ChildrenResultCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
                [cell.solutionBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                YjyxWorkDetailModel *model = self.stuChoiceContentArr[indexPath.row - 1];
                YjyxStuAnswerModel *model1 = self.stuChoiceAnswerArr[indexPath.row - 1];
                [cell setSubviewsWithWorkDetailModel:model andStuResultModel:model1];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.indexPath = indexPath;
                cell.tag = indexPath.row ;
                return cell;
            }
        }else{
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NorID];
                cell.textLabel.text = @"填空题";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                ChildrenResultCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
                [cell.solutionBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                YjyxWorkDetailModel *model = self.stuBlankContentArr[indexPath.row - 1];
                YjyxStuAnswerModel *model1 = self.stuBlankAnswerArr[indexPath.row - 1];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
             
                cell.indexPath = indexPath;
                cell.tag = indexPath.row;
                [cell.expandBtn addTarget:self action:@selector(studentChangeCellHeight:) forControlEvents:UIControlEventTouchUpInside];
                cell.expandBtn.selected = [[self.blankfillExpandDic objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] boolValue];
                
                NSString *expand = [self.blankfillExpandDic objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                
                if (expand == nil) {
                    cell.expandBtn.selected = NO;
                }else {
                    cell.expandBtn.selected = [expand boolValue];
                }
                [cell setSubviewsWithWorkDetailModel:model andStuResultModel:model1];
                return cell;
            }
        }
    }else{
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NorID];
            cell.textLabel.text = @"填空题";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            ChildrenResultCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            [cell.solutionBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            YjyxWorkDetailModel *model = self.stuBlankContentArr[indexPath.row - 1];
            YjyxStuAnswerModel *model1 = self.stuBlankAnswerArr[indexPath.row - 1];
            [cell setSubviewsWithWorkDetailModel:model andStuResultModel:model1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.indexPath = indexPath;
            cell.tag = indexPath.row;
            [cell.expandBtn addTarget:self action:@selector(studentChangeCellHeight:) forControlEvents:UIControlEventTouchUpInside];
            cell.expandBtn.selected = [[self.blankfillExpandDic objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] boolValue];
            
            NSString *expand = [self.blankfillExpandDic objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            
            if (expand == nil) {
                cell.expandBtn.selected = NO;
            }else {
                cell.expandBtn.selected = [expand boolValue];
            }
            [cell setSubviewsWithWorkDetailModel:model andStuResultModel:model1];
            return cell;
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSLog(@"%@, %@", _model.knowledgedesc, _model.videoobjlist);
        if ([self.taskType isEqual:@1]) {
            return 0;
        }else{
            return  (SCREEN_WIDTH)*184/320;
        }
    }else if(indexPath.section == 1){
        if ([self.taskType isEqual:@1]) {
            return 0;
        }else{
            return  40;
        }
    }else if(indexPath.section == 2){
        if ([self.taskType isEqual:@1]) {
            return 0;
        }else{
            return  70;
        }
    }else if (indexPath.section == 3) {
        if (self.stuChoiceAnswerArr.count != 0) {
            if(indexPath.row == 0){
                return 40;
            }else{
                CGFloat height = [[self.choiceCellHeightDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                return height;
                
            }
        }else{
            if(indexPath.row == 0){
                return 40;
            }else{
                CGFloat height = [[self.choiceCellHeightDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
                return height;
            }
        }
    }else{
        if(indexPath.row == 0){
            return 40;
        }else{
            CGFloat height = [[self.blankfillHeightDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] floatValue];
            return height;
        }
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    if (section == 1 || section == 2) {
        if ([self.taskType isEqual:@1]) {
            return 0;
        }else{
        return 15;
        }
    }else{
        return 0;
    }
}
@end
