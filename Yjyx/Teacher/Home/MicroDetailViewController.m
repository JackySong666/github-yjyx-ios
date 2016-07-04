//
//  MicroDetailViewController.m
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/24.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "MicroDetailViewController.h"
#import "MicroDetailModel.h"
#import "MicroSubjectModel.h"
#import "SubjectDetailCell.h"
#import "SubjectTitleCell.h"
#import "MicroNameCell.h"
#import "ReleaseMicroCell.h"
#import "MicroKnowledgeCell.h"
#import "WMPlayer.h"
#import "ReleaseMicroController.h"
#import "OneSubjectController.h"
#import "PublishHomeworkViewController.h"
#import "QuestionDataBase.h"
@interface MicroDetailViewController ()<SubjectTitleCellDelegate, SubjectDetailCellDelegate>
{
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
    BOOL isPlay;
}
@property (strong, nonatomic) MicroDetailModel *microDetailM;

// 所有的题目数组
@property (strong, nonatomic) NSMutableArray *allSubjectArr;
// 多少组
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) ReleaseMicroCell *videoCell;
@end

@implementation MicroDetailViewController

static NSString *videoID = @"videoCELL";
static NSString *subjectID = @"subjectCELL";
static NSString *NameID = @"NameCELL";
static NSString *KnowledgeID = @"KnowledgeCELL";
static NSString *TitleID = @"TitleCELL";
#pragma mark - 懒加载
- (NSMutableArray *)allSubjectArr
{
    if (_allSubjectArr == nil) {
        _allSubjectArr = [NSMutableArray array];
    }
    return _allSubjectArr;
}

//- (NSMutableArray *)addMicroArr
//{
//    if (_addMicroArr == nil) {
//        _addMicroArr = [NSMutableArray array];
//    }
//    return _addMicroArr;
//}
#pragma mark - view的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COMMONCOLOR;
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    [self loadData];
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ReleaseMicroCell class]) bundle:nil] forCellReuseIdentifier:videoID];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SubjectDetailCell class]) bundle:nil] forCellReuseIdentifier:subjectID];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SubjectTitleCell class]) bundle:nil] forCellReuseIdentifier:TitleID];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MicroNameCell class]) bundle:nil] forCellReuseIdentifier:NameID];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MicroKnowledgeCell class]) bundle:nil] forCellReuseIdentifier:KnowledgeID];
    // tableview的属性
    self.tableView.contentInset = UIEdgeInsetsMake(- 35, 0, -49, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -49, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = COMMONCOLOR;
    self.tableView.sectionHeaderHeight = 15;
    self.tableView.sectionFooterHeight = 0;
  
    //注册播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //注册播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:WMPlayerFullScreenButtonClickedNotification object:nil];
    // 返回按钮被点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backBtnClicked) name:@"BackButtonClicked" object:nil];
    // 修改标题按钮呗点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyTitleBtnClick) name:@"ModifyTitleBtnClick" object:nil];
    // 添加按钮的点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBtnClick) name:@"AddBtnClick" object:nil];
    //关闭通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeTheVideo:)
                                                 name:WMPlayerClosedNotification
                                               object:nil
     ];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [self releaseWMPlayer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)dealloc
{
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 私有方法
- (void)loadData
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSMutableDictionary *pamar = [NSMutableDictionary dictionary];
    pamar[@"action"] = @"m_preview";
    pamar[@"id"] = self.m_id;
    [mgr GET:[BaseURL stringByAppendingString:@"/api/teacher/yj_lessons/"] parameters:pamar success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);

        _microDetailM = [MicroDetailModel microDetailModelWithDict:responseObject[@"lessonobj"]];
       
        for (NSDictionary *tempDict in responseObject[@"questions"][@"choice"][@"questionlist"]) {
            [self.allSubjectArr addObject:[MicroSubjectModel microSubjectModel:tempDict andType:1]];
        }
        for (NSDictionary *tempDict in responseObject[@"questions"][@"blankfill"][@"questionlist"]) {
            [self.allSubjectArr addObject:[MicroSubjectModel microSubjectModel:tempDict andType:2]];
        }
        self.count = 4;
        // 设置footerView
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        footerView.backgroundColor = COMMONCOLOR;
        UIButton *releaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        releaseBtn.backgroundColor = RGBACOLOR(0, 128.0, 255.0, 1);
        releaseBtn.width = SCREEN_WIDTH - 20;
        releaseBtn.height = 49;
        releaseBtn.centerX = footerView.centerX;
        releaseBtn.centerY = footerView.height / 2;
        [releaseBtn setTitle:@"发布给学生" forState:UIControlStateNormal];
        releaseBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [releaseBtn addTarget:self action:@selector(releaseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [releaseBtn setTintColor:[UIColor whiteColor]];
        [footerView addSubview:releaseBtn];
        self.tableView.tableFooterView = footerView;
        // 刷新底部view
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
        [SVProgressHUD dismiss];
    }];
}
- (void)modifiContentData
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSMutableDictionary *pamar = [NSMutableDictionary dictionary];
    pamar[@"action"] = @"m_modify";
    pamar[@"id"] = self.m_id;
    
    NSLog(@"%@", [_microDetailM.questionList JSONString]);
    NSMutableArray *pamarArr = [NSMutableArray array];
    NSMutableArray *choiceArr = [NSMutableArray array];
    NSMutableArray *blankfillArr = [NSMutableArray array];
    for (MicroSubjectModel *model in _allSubjectArr) {
        NSNumber *levelNum = @1;
        if([model.level isEqualToString:@"中等"]){
            levelNum = @2;
        }else if ([model.level isEqualToString:@"较难"]){
            levelNum = @3;
        }
        if(model.type == 1){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"id"] = model.s_id;
            
            dict[@"level"] = levelNum;
           
            [choiceArr addObject:dict];
        }else{
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"id"] = model.s_id;
            dict[@"level"] = levelNum;
            [blankfillArr addObject:dict];
        }
            
    }
    NSMutableArray *tempArr1 = [NSMutableArray array];
    NSMutableArray *tempArr2 = [NSMutableArray array];
    if(choiceArr.count != 0){
    [tempArr1 addObject:@"choice"];
    [tempArr1 addObject:choiceArr];
    }
    if(blankfillArr.count != 0){
    [tempArr2 addObject:@"blankfill"];
    [tempArr2 addObject:blankfillArr];
    }
    if(tempArr1.count != 0){
        [pamarArr addObject:tempArr1];
    }
    if(tempArr2 .count != 0){
        [pamarArr addObject:tempArr2];
    }

    pamar[@"questions"] = [pamarArr JSONString];
    NSLog(@"%@", [pamarArr JSONString]);
    [mgr POST:[BaseURL stringByAppendingString:@"/api/teacher/mobile/lesson/"] parameters:pamar success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改内容成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showWithStatus:@"修改内容时出现错误"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];

}
- (void)modifiTitleData
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSMutableDictionary *pamar = [NSMutableDictionary dictionary];
    pamar[@"action"] = @"m_modify";
    pamar[@"id"] = self.m_id;
   
    pamar[@"name"] = _microDetailM.name;
    NSLog(@"%@", _microDetailM.name);
    [mgr POST:[BaseURL stringByAppendingString:@"/api/teacher/mobile/lesson/"] parameters:pamar success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改内容成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showWithStatus:@"修改内容时出现错误"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
    
}
- (void)backBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)modifyTitleBtnClick
{
    [self modifiTitleData];
    if ([self.delegate respondsToSelector:@selector(microDetailViewController:andName:)]) {
        [self.delegate microDetailViewController:self andName:_microDetailM.name];
    }
}
- (void)releaseBtnClicked
{
    ReleaseMicroController *vc = [[ReleaseMicroController alloc] init];
    vc.w_id = self.m_id;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void )addBtnClick
{
    PublishHomeworkViewController *homeVc = [[PublishHomeworkViewController alloc] init];
    [[QuestionDataBase shareDataBase] deleteMicroTable];
    for (MicroSubjectModel *model in _allSubjectArr) {
        [[QuestionDataBase shareDataBase] insertMirco:model];
    }
    [self.navigationController pushViewController:homeVc animated:YES];
}
- (void)setAddMicroArr:(NSMutableArray *)addMicroArr
{
    _addMicroArr = addMicroArr;
    NSMutableArray *choiceArr = [NSMutableArray array];
    NSMutableArray *blankfillArr = [NSMutableArray array];
    for (MicroSubjectModel *model in addMicroArr) {
        if(model.type == 1){
            [choiceArr addObject:model];
        }else{
            [blankfillArr addObject:model];
        }
    }
    [self.allSubjectArr removeAllObjects];
    [self.allSubjectArr addObjectsFromArray:choiceArr];
    [self.allSubjectArr addObjectsFromArray:blankfillArr];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:3];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - wmPlayer的方法
-(void)videoDidFinished:(NSNotification *)notice{
    ReleaseMicroCell *currentCell = (ReleaseMicroCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    isPlay = NO;
    currentCell.playBtn.hidden = NO;
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}
-(void)closeTheVideo:(NSNotification *)obj{
    
    ReleaseMicroCell *currentCell = (ReleaseMicroCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    currentCell.playBtn.hidden = NO;
    isPlay = NO;
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}
-(void)fullScreenBtnClick:(NSNotification *)notice{
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        wmPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
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
                
                [self setNeedsStatusBarAppearanceUpdate];
                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            if (wmPlayer.isFullscreen == NO) {
                wmPlayer.isFullscreen = YES;
                [self setNeedsStatusBarAppearanceUpdate];
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
        [self setNeedsStatusBarAppearanceUpdate];
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
        [self setNeedsStatusBarAppearanceUpdate];
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
        [wmPlayer setVideoURLStr:_microDetailM.videoUrl];
        [wmPlayer.player play];
    }else{
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.videoCell.backgroundIV.bounds videoURLStr:_microDetailM.videoUrl];
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

#pragma mark - Table view 数据源方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return 1;
    }else if(section == 2){
        return 1;
    }else{
        return self.allSubjectArr.count + 1;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ReleaseMicroCell *cell = [tableView dequeueReusableCellWithIdentifier:videoID];
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
        
        return cell;

        
    }else if(indexPath.section == 1){
        MicroNameCell *cell = [tableView dequeueReusableCellWithIdentifier:NameID];
        cell.model = _microDetailM;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(indexPath.section == 2){
        MicroKnowledgeCell *cell = [tableView dequeueReusableCellWithIdentifier:KnowledgeID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = _microDetailM;
        return cell;
    }else if(indexPath.section == 3){
        if (indexPath.row == 0) {
            SubjectTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleID];
            cell.model = _microDetailM;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }else{
            SubjectDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:subjectID forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.model = self.allSubjectArr[indexPath.row - 1];
            cell.subjectNumLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
            return cell;
        }
        
    }
   
    return nil;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return  (SCREEN_WIDTH)*184/320;
    }else if (indexPath.section == 1) {
        return 70;
    }else if(indexPath.section == 2){
        return 70;
    }else if(indexPath.section == 3){
        if (indexPath.row == 0) {
            return 30;
        }else{
            MicroSubjectModel *model = self.allSubjectArr[indexPath.row - 1];
            return model.cellHeight;
        }
    }
    return 0;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 3 && indexPath.row != 0){
        OneSubjectController *vc = [[OneSubjectController alloc] init];
        MicroSubjectModel *model = self.allSubjectArr[indexPath.row - 1];
        vc.w_id =  [model.s_id stringValue];
        vc.qtype = model.type == 1 ? @"choice" : @"blankfill";
        [self.navigationController  pushViewController:vc animated:YES];
    }
}
#pragma mark - SubjectTitleCellDelegate代理方法
- (void)subjectTitleCell:(SubjectTitleCell *)cell editBtnClicked:(UIButton *)btn
{
    if (btn.selected) {
        for (MicroSubjectModel *model in _allSubjectArr) {
            model.btnIsShow = YES;
        }
        
    }else{
        
        [self modifiContentData];
        for (MicroSubjectModel *model in _allSubjectArr) {
            model.btnIsShow = NO;
        }
    }
    [self.tableView reloadData];
}
#pragma mark - SubjectDetailCell代理方法
- (void)subjectDetailCell:(SubjectDetailCell *)cell deletedBtnClick:(UIButton *)btn
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"%ld--%ld", indexPath.section, indexPath.row);
    [self.allSubjectArr removeObjectAtIndex:(indexPath.row - 1)];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:indexPath.section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
- (void)subjectDetailCell:(SubjectDetailCell *)cell moveUpBtnClick:(UIButton *)btn
{
  
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 1) {
        [SVProgressHUD showWithStatus:@"已经是第一行了"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        return;
    }
    MicroSubjectModel *model1 = self.allSubjectArr[indexPath.row - 1];
    MicroSubjectModel *model2 = self.allSubjectArr[indexPath.row - 2];
    if (model1.type != model2.type) {
        [SVProgressHUD showWithStatus:@"填空题与选择题不能混合"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    [self.allSubjectArr exchangeObjectAtIndex:indexPath.row - 1 withObjectAtIndex:indexPath.row - 2];
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:indexPath.section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

}
- (void)subjectDetailCell:(SubjectDetailCell *)cell moveDownBtnClick:(UIButton *)btn
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"%ld, %ld", indexPath.row, self.allSubjectArr.count);
    if (indexPath.row == self.allSubjectArr.count) {
        [SVProgressHUD showWithStatus:@"已经是最后一行了"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    MicroSubjectModel *model1 = self.allSubjectArr[indexPath.row - 1];
    MicroSubjectModel *model2 = self.allSubjectArr[indexPath.row];
    if (model1.type != model2.type) {
        [SVProgressHUD showWithStatus:@"填空题与选择题不能混合"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    [self.allSubjectArr exchangeObjectAtIndex:indexPath.row - 1 withObjectAtIndex:indexPath.row];
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:indexPath.section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end