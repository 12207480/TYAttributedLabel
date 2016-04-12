//
//  LabelXibViewController.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/12/1.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "LabelXibViewController.h"
#import "TYAttributedLabel.h"

@interface LabelXibViewController ()
@property (weak, nonatomic) IBOutlet TYAttributedLabel *label;
@property (weak, nonatomic) IBOutlet TYAttributedLabel *label2;

@end

@implementation LabelXibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 如果你需要自动推断高度，需要设置preferredMaxLayoutWidth
    //_label.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds)-2*10;
    _label.numberOfLines = 1;
    _label.lineBreakMode = kCTLineBreakByTruncatingTail;
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor darkTextColor];
    _label.text = @"总有一天你将破蛹而出，成长得比人们期待的还要美丽。但这个过程会很痛，会很辛苦，有时候还会觉得灰心。面对着汹涌而来的现实，觉得自己渺小无力。\n但这，也是生命的一部分。做好现在你能做的，然后，一切都会好的。我们都将孤独地长大，不要害怕";
    
    // 如果你需要自动推断高度，需要设置preferredMaxLayoutWidth
    _label2.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds)-2*10;
    _label2.font = [UIFont systemFontOfSize:15];
    _label2.textColor = [UIColor darkTextColor];
    _label2.linesSpacing = 2;
    _label2.characterSpacing = 2;
    // 段落间距
    _label2.paragraphSpacing = 20;
    _label2.text = _label.text;
    
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
