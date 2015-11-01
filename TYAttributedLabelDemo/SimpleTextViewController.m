//
//  SimpleTextViewController.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/17.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "SimpleTextViewController.h"
#import "TYAttributedLabel.h"

@interface SimpleTextViewController ()

@end

@implementation SimpleTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // addAttributedText
    TYAttributedLabel *label1 = [[TYAttributedLabel alloc]init];
    label1.text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。但这个过程会很痛，会很辛苦，有时候还会觉得灰心。面对着汹涌而来的现实，觉得自己渺小无力。但这，也是生命的一部分。做好现在你能做的，然后，一切都会好的。我们都将孤独地长大，不要害怕。";
    
    // 文字间隙
    label1.characterSpacing = 2;
    // 文本行间隙
    label1.linesSpacing = 2;
    
    label1.lineBreakMode = kCTLineBreakByTruncatingTail;
    label1.numberOfLines = 3;
    // 文本字体
    label1.font = [UIFont systemFontOfSize:17];
    // 设置文字竖直对齐方式
    label1.verticalAlignment = VerticalAlignmentBottom;
    
    // 设置view的位置和宽，会自动计算高度
    [label1 setFrameWithOrign:CGPointMake(0, 64) Width:CGRectGetWidth(self.view.frame)];
    label1.backgroundColor = [UIColor cyanColor];
    CGRect frame = label1.frame;
    frame.size.height += 100;
    label1.frame = frame;
    [self.view addSubview:label1];
    
    
    // appendAttributedText
    TYAttributedLabel *label2 = [[TYAttributedLabel alloc]init];
    label2.frame = CGRectMake(0, CGRectGetMaxY(label1.frame)+10, CGRectGetWidth(self.view.frame), 200);
    [self.view addSubview:label2];
    
    // 追加(添加到最后)文本
    [label2 appendText:@"\t任何值得去的地方，”都没“有捷径；\n"];
    [label2 appendText:@"\t任何值得等待的人，都会迟来一些；\n"];
    [label2 appendText:@"\t任何值得追逐的梦想，都必须在一路艰辛中备受嘲笑。\n"];
    [label2 appendText:@"\t所以，不要怕，不要担心你所追逐的有可能是错的。\n"];
    [label2 appendText:@"\t因为，不被嘲笑的梦想不是梦想。\n"];
    
    // 自适应高度
    [label2 sizeToFit];
    
    label2.verticalAlignment = VerticalAlignmentMiddle;
    label2.backgroundColor = [UIColor lightGrayColor];
    frame = label2.frame;
    frame.size.height += 100;
    label2.frame = frame;
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
