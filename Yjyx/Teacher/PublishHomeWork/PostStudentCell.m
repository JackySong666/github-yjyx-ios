//
//  PostStudentCell.m
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/16.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "PostStudentCell.h"

#import "StudentEntity.h"
#import "StuClassEntity.h"
#import "StuGroupEntity.h"
@interface PostStudentCell()
@property (weak, nonatomic) IBOutlet UILabel *classOrStudentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UIButton *isSelectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeadConstrait;


@end
@implementation PostStudentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)isSelectedBtnClick:(UIButton *)sender {
    PostStudentCell *cell =  (PostStudentCell *)sender.superview.superview;
    NSIndexPath *path = [(UITableView *)self.superview.superview indexPathForCell:cell];
    sender.selected = !sender.selected;
    
    
//    if (path.row == 0) {
//        self.stuClassModel.isSelect = !self.stuClassModel.isSelect;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FirstCellClicked" object:nil userInfo:@{@"BtnIsSelect" : sender, @"ClickIsSection": path}];
//    }else{
//        self.studentModel.isSelect = !self.studentModel.isSelect;
//        if(self.studentModel.isSelect == NO){
//          PostStudentCell *cell1 =[((UITableView *)self.superview.superview) cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:path.section]];
//            cell1.stuClassModel.isSelect = NO;
//            [((UITableView *)self.superview.superview) reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:path.section]] withRowAnimation:UITableViewRowAnimationNone];
//        }
//    }
    
}



- (void)setStudentModel:(StudentEntity *)studentModel
{
    _studentModel = studentModel;
    self.classOrStudentLabel.text = studentModel.realname;
     [self.iconImageV setImageWithURL:[NSURL URLWithString:studentModel.avatar_url] placeholderImage:[UIImage imageNamed:@"hpic_placeholder"]];
     self.iconLeadConstrait.constant = 25;
    if (studentModel.isSelect == YES) {
        self.isSelectBtn.selected = YES;
    }else{
        self.isSelectBtn.selected = NO;
    }
}
- (void)setStuClassModel:(StuClassEntity *)stuClassModel
{
    _stuClassModel = stuClassModel;
    self.iconLeadConstrait.constant = 15;

    self.classOrStudentLabel.text = [NSString stringWithFormat:@"%@",  stuClassModel.name];
    self.iconImageV.image  = [UIImage imageNamed:@"tab_home"];
    if (stuClassModel.isSelect == YES) {
        self.isSelectBtn.selected = YES;
    }else{
        self.isSelectBtn.selected = NO;
    }
}

- (void)setStuGroupModel:(StuGroupEntity *)stuGroupModel
{
    _stuGroupModel = stuGroupModel;
    self.iconLeadConstrait.constant = 15;
    
    self.classOrStudentLabel.text = [NSString stringWithFormat:@"%@",  stuGroupModel.name];
    self.iconImageV.image  = [UIImage imageNamed:@"tab_home"];
    if (stuGroupModel.isSelect == YES) {
        self.isSelectBtn.selected = YES;
    }else{
        self.isSelectBtn.selected = NO;
    }
}
@end
