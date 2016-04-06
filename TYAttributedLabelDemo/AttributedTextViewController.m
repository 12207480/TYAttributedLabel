//
//  AttributedTextViewController.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/17.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "AttributedTextViewController.h"
#import "TYAttributedLabel.h"

@interface AttributedTextViewController ()<TYAttributedLabelDelegate>
@property (nonatomic, weak) TYAttributedLabel *label1;
@end

#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation AttributedTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // appendAttributedText
    [self addTextAttributedLabel1];
    
    // addAttributedText
    [self addTextAttributedLabel2];
    
}

// appendAttributedText
- (void)addTextAttributedLabel1
{
    TYAttributedLabel *label1 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 0)];
    
    [self.view addSubview:label1];
    NSString *text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心。\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。\n\t我们都将孤独地长大，不要害怕。";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    for (NSString *text in textArray) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        // 设置当前文本字体
        [attributedString addAttributeTextColor:colorArray[index%5]];
        // 设置当前文本颜色
        [attributedString addAttributeFont:[UIFont systemFontOfSize:15+arc4random()%4]];
        if (index == 2) {
            // 当前文本添加下划线
            [attributedString addAttributeUnderlineStyle:kCTUnderlineStyleSingle modifier:kCTUnderlinePatternSolid];
        }
        if (index == 4) {
            [attributedString addAttributeUnderlineStyle:kCTUnderlineStyleSingle modifier:kCTUnderlinePatternDot];
        }
        
        // 追加(添加到最后)属性文本
        [label1 appendTextAttributedString:attributedString];
        [label1 appendText:@"\n\t"];
        index++;
    }
    // 设置空心字
    label1.strokeWidth = 2;
    
    [label1 sizeToFit];
    //[label1 setFrameWithOrign:CGPointMake(0, 64) Width:CGRectGetWidth(self.view.frame)];
    _label1 = label1;
}

// addAttributedText
- (void)addTextAttributedLabel2
{
    NSString *text = @"\t任何值得去的地方，都没有捷径；\n\t任何值得等待的人，都会迟来一些；\n\t任何值得追逐的梦想，都必须在一路艰辛中备受嘲笑。\n\t所以，不要怕，不要担心你所追逐的有可能是错的。\n\t因为，不被嘲笑的梦想不是梦想。\n";
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
     NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    NSMutableAttributedString *totalAttributedString = [[NSMutableAttributedString alloc]init];
    
    for (NSString *text in textArray) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        
        [attributedString addAttributeTextColor:colorArray[index%5]];
        [attributedString addAttributeFont:[UIFont systemFontOfSize:15+arc4random()%4]];
        [totalAttributedString appendAttributedString:attributedString];
        [totalAttributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n\t"]];
        index++;
    }
    
    TYAttributedLabel *label2 = [[TYAttributedLabel alloc]init];
    [label2 setAttributedText:totalAttributedString];
    
    label2.linesSpacing = 5;
    label2.characterSpacing = 2;
    [label2 setFrameWithOrign:CGPointMake(0, CGRectGetMaxY(_label1.frame)) Width:CGRectGetWidth(self.view.frame)];
    [self.view addSubview:label2];
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
