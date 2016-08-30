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
    label1.numberOfLines = 1;
    // 文本字体
    label1.font = [UIFont systemFontOfSize:17];
    
    // 设置view的位置和宽，会自动计算高度
    [label1 setFrameWithOrign:CGPointMake(0, 64) Width:CGRectGetWidth(self.view.frame)];
    [self.view addSubview:label1];
    
    
    // appendAttributedText
    TYAttributedLabel *label2 = [[TYAttributedLabel alloc]init];
    label2.backgroundColor = [UIColor lightGrayColor];
    label2.frame = CGRectMake(0, CGRectGetMaxY(label1.frame)+10, CGRectGetWidth(self.view.frame), 20);
    [self.view addSubview:label2];
    
    // 追加(添加到最后)文本
    [label2 appendText:@"\t任何值得去的地方"];
    [label2 appendImageWithName:@"haha" size:CGSizeMake(15, 15)];
    [label2 appendText:@",都没“有捷径“"];
    [label2 appendImageWithName:@"haha" size:CGSizeMake(15, 15)];
//    [label2 appendText:@"\t任何值得等待的人，都会迟来一些；\n"];
//    [label2 appendText:@"\t任何值得追逐的梦想，都必须在一路艰辛中备受嘲笑。\n"];
//    [label2 appendText:@"\t所以，不要怕，不要担心你所追逐的有可能是错的。\n"];
//    [label2 appendText:@"\t因为，不被嘲笑的梦想不是梦想。\n"];
    // 宽度自适应
    label2.isWidthToFit = YES;
    // 自适应高度
    [label2 sizeToFit];
    
    // label 垂直对齐方式
    // top text(default)
    TYAttributedLabel *label3 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label2.frame)+10, CGRectGetWidth(self.view.frame), 80)];
    label3.text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。(default text)";
    label3.backgroundColor = [UIColor lightGrayColor];
    // 垂直对齐方式
    //label3.verticalAlignment = TYVerticalAlignmentTop; // default top
    // 文字间隙
    label3.characterSpacing = 2;
    // 文本行间隙
    label3.linesSpacing = 2;
    
    [self.view addSubview:label3];
    
    // center text
    TYAttributedLabel *label4 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label3.frame)+10, CGRectGetWidth(self.view.frame), 80)];
    label4.text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。(center text)";
    label4.backgroundColor = [UIColor lightGrayColor];
    // 垂直对齐方式
    label4.verticalAlignment = TYVerticalAlignmentCenter;
    // 文字间隙
    label4.characterSpacing = 2;
    // 文本行间隙
    label4.linesSpacing = 2;
    
    [self.view addSubview:label4];
    
    // bottom text
    TYAttributedLabel *label5 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label4.frame)+10, CGRectGetWidth(self.view.frame), 80)];
    label5.text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。(bottom text)";
    label5.backgroundColor = [UIColor lightGrayColor];
    // 垂直对齐方式
    label5.verticalAlignment = TYVerticalAlignmentBottom;
    // 文字间隙
    label5.characterSpacing = 2;
    // 文本行间隙
    label5.linesSpacing = 2;
    
    [self.view addSubview:label5];
    
    TYAttributedLabel *label6 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label5.frame)+10, CGRectGetWidth(self.view.frame), 80)];
    label6.text = @"center text";
    label6.backgroundColor = [UIColor lightGrayColor];
    // 水平对齐方式
    label6.textAlignment = kCTTextAlignmentCenter;
    // 垂直对齐方式
    label6.verticalAlignment = TYVerticalAlignmentCenter;
    // 文字间隙
    label6.characterSpacing = 2;
    // 文本行间隙
    label6.linesSpacing = 2;
    
    [self.view addSubview:label6];
    
    TYAttributedLabel *label7 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label6.frame)+10, CGRectGetWidth(self.view.frame), 80)];
    label7.text = @"right text";
    label7.backgroundColor = [UIColor lightGrayColor];
    // 水平对齐方式
    label7.textAlignment = kCTTextAlignmentRight;
    // 垂直对齐方式
    label7.verticalAlignment = TYVerticalAlignmentCenter;
    // 文字间隙
    label7.characterSpacing = 2;
    // 文本行间隙
    label7.linesSpacing = 2;
    
    [self.view addSubview:label7];
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
