//
//  AddViewTextViewController.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/22.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "AddViewTextViewController.h"
#import "TYAttributedLabel.h"

@interface AddViewTextViewController ()
@property (nonatomic, weak) TYAttributedLabel *label;
@property (nonatomic, weak) UIScrollView *scrollView;
@end

#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation AddViewTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addScrollView];
    
    // appendAttributedText
    [self addTextAttributedLabel];
}

- (void)addScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)addTextAttributedLabel
{
    TYAttributedLabel *label = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.view.frame), 0)];
    [_scrollView addSubview:label];
    _label = label;
    
    NSString *text = @"\t↑↑(UIImageView)总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心。\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。→→(UIButton)\n\t我们都将孤独地长大，不要害怕。";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    
    // 添加UIImageView
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CYLoLi"]];
    imageView.frame = CGRectMake(0, 0, CGRectGetWidth(label.frame), 180);
    [label appendView:imageView];
    
    for (NSString *text in textArray) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        
        if (index != 4) {
            
            [attributedString addAttributeTextColor:colorArray[index%5]];
            [attributedString addAttributeFont:[UIFont systemFontOfSize:15+arc4random()%4]];
            [label appendTextAttributedString:attributedString];
            
            if (index == 3) {
                // 追加(添加到最后) button
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [button setTitle:@"点我看看" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
                button.frame = CGRectMake(0, 0, 60, 15);
                [label appendView:button];
                [label appendText:@"\n\t"];
            }else {
                [label appendText:@"\n\t"];
            }

        }else {
        
            [label appendText:@"(UIImageView)→ →"];
        
            UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"avatar"]];
            imageView.frame = CGRectMake(0, 0,60,60);
            [label appendView:imageView];
            [label appendText:text];
        }
        index++;
    }
    
    [label appendImageWithName:@"haha" size:CGSizeMake(15, 15)];
    
    [label sizeToFit];
    [_scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(_label.frame)+10)];
}

- (void)buttonClicked
{
    _label.characterSpacing += 1;
    _label.linesSpacing += 1;
    _label.font = [UIFont systemFontOfSize:_label.font.pointSize +1];
    [_label sizeToFit];
    [_scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(_label.frame)+10)];
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
