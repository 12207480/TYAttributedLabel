//
//  ImageTextViewController.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/17.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ImageTextViewController.h"
#import "TYAttributedLabel.h"
#import "TYDrawImageRun.h"
#import "RegexKitLite.h"

@interface ImageTextViewController ()

@end

#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation ImageTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    TYAttributedLabel *label1 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 0)];
    [self.view addSubview:label1];
    
    NSString *text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心。\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。\n\t我们都将孤独地长大，不要害怕。";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    for (NSString *text in textArray) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        
        if (index != 4) {
            [attributedString addAttributeTextColor:colorArray[index%5]];
            [attributedString addAttributeFont:[UIFont systemFontOfSize:15+arc4random()%4]];
            [label1 appendTextAttributedString:attributedString];
            [label1 appendImageWithContent:@"haha"];
            if (index == 2) {
                TYDrawImageRun *imageRun = [[TYDrawImageRun alloc]init];
                imageRun.imageContent = @"avatar";
                imageRun.size = CGSizeMake(60, 60);
                [label1 appendTextRun:imageRun];
            }
            [label1 appendText:@"\n\t"];
        } else {
            [label1 appendImageWithContent:@"avatar" size:CGSizeMake(60, 60)];
            [label1 appendText:text];
        }
        index++;
    }
    //[label1 appendImageWithContent:@"avatar" size:CGSizeMake(60, 60)];  都可以
    TYDrawImageRun *imageRun = [[TYDrawImageRun alloc]init];
    imageRun.imageContent = @"haha";
    imageRun.size = CGSizeMake(15, 15);
    [label1 appendTextRun:imageRun];
    
    [label1 sizeToFit];
    
    //使用时一般使用 RegexKitLite，它同样是 -fno-objc-arc，同时添加 libicucore.dylib
    
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
