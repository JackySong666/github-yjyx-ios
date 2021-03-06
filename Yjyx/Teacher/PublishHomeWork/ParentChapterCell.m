//
//  ParentChapterCell.m
//  Yjyx
//
//  Created by yjyx-iOS2 on 16/6/7.
//  Copyright © 2016年 Alibaba. All rights reserved.
//

#import "ParentChapterCell.h"
#import "TreeNode.h"
@implementation ParentChapterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setNode:(TreeNode *)node
{
    _node = node;
    if (node.depth == 0) {
        self.widthConstant.constant = 25;
        self.heightConstant.constant = 25;
        self.imageVleadConstant.constant = 12;
    }else if(node.depth == 1){
        self.widthConstant.constant = 25;
        self.heightConstant.constant = 25;
        self.imageVleadConstant.constant = 12;
    }else if(node.depth == 2){
        self.widthConstant.constant = 20;
        self.heightConstant.constant = 20;
        self.imageVleadConstant.constant = 20;
    }else if (node.depth == 3) {
    
        self.widthConstant.constant = 15;
        self.heightConstant.constant = 15;
        self.imageVleadConstant.constant = 40;

        
    }else if (node.depth == 4) {
    
        self.widthConstant.constant = 10;
        self.heightConstant.constant = 10;
        self.imageVleadConstant.constant = 50;

    }else if (node.depth == 5) {
    
        self.widthConstant.constant = 6;
        self.heightConstant.constant = 6;
        self.imageVleadConstant.constant = 55;

    }
}

@end
