//
//  LinkTextViewController.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/22.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "LinkTextViewController.h"
#import "TYAttributedLabel.h"

@interface LinkTextViewController ()<TYAttributedLabelDelegate>
@property (nonatomic, weak) TYAttributedLabel *label1;
@end
#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
@implementation LinkTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // appendAttributedText
    [self addTextAttributedLabel1];
    
    // addAttributedText
    [self addTextAttributedLabel2];
    
}

- (void)addTextAttributedLabel1
{
    TYAttributedLabel *label1 = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 0)];
    label1.delegate = self;
    label1.highlightedLinkColor = [UIColor orangeColor];
    [self.view addSubview:label1];
    NSString *text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心。\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。\n\t我们都将孤独地长大，不要害怕。";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    
    for (NSString *text in textArray) {
        
        if (index == 2) {
            // 追加链接信息
            [label1 appendLinkWithText:text linkFont:[UIFont systemFontOfSize:15+arc4random()%4] linkData:@"http://www.baidu.com"];
        }else {
            // 追加文本属性
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
            [attributedString addAttributeTextColor:colorArray[index%5]];
            [attributedString addAttributeFont:[UIFont systemFontOfSize:15+arc4random()%4]];
            [label1 appendTextAttributedString:attributedString];
        }
        [label1 appendText:@"\n\t"];
        index++;
    }
    
    [label1 appendLinkWithText:@"百度一下" linkFont:[UIFont systemFontOfSize:15+arc4random()%4] linkData:@"http://www.baidu.com"];
    
    [label1 sizeToFit];
    _label1 = label1;
}

- (void)addTextAttributedLabel2
{
    NSString *text = @"\t任何值得去的地方，都没有捷径；\n\t任何值得等待的人，都会迟来一些；\n\t任何值得追逐的梦想，都必须在一路艰辛中备受嘲笑。\n\t所以，不要怕，不要担心你所追逐的有可能是错的。\n\t因为，不被嘲笑的梦想不是梦想。\n";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    NSMutableArray *textRunArray = [NSMutableArray array];
    
    for (NSString *subText in textArray) {
        if (index == 2) {
            TYLinkTextStorage *linkTextStorage = [[TYLinkTextStorage alloc]init];
            linkTextStorage.range = [text rangeOfString:subText];
            linkTextStorage.font = [UIFont systemFontOfSize:15+arc4random()%4];
            linkTextStorage.textColor = colorArray[index%5];
            linkTextStorage.linkData = @"我被点中了哦O(∩_∩)O~";
            [textRunArray addObject:linkTextStorage];
        } else {
            TYTextStorage *textStorage = [[TYTextStorage alloc]init];
            textStorage.font = [UIFont systemFontOfSize:15+arc4random()%4];
            textStorage.textColor = colorArray[index%5];
            textStorage.range = [text rangeOfString:subText];
            [textRunArray addObject:textStorage];
        }
        index++;
    }
    
    TYAttributedLabel *label2 = [[TYAttributedLabel alloc]init];
    label2.delegate = self;
    label2.highlightedLinkColor = [UIColor redColor];
    label2.text = text;
    [label2 addTextStorageArray:textRunArray];
    
    label2.linesSpacing = 8;
    label2.characterSpacing = 2;
    [label2 setFrameWithOrign:CGPointMake(0, CGRectGetMaxY(_label1.frame)) Width:CGRectGetWidth(self.view.frame)];
    [self.view addSubview:label2];

}

#pragma mark - TYAttributedLabelDelegate

- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    NSLog(@"textStorageClickedAtPoint");
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        
        NSString *linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        
        if ([linkStr hasPrefix:@"http:"]) {
            [ [ UIApplication sharedApplication] openURL:[ NSURL URLWithString:linkStr]];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:linkStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageLongPressed:(id<TYTextStorageProtocol>)textStorage onState:(UIGestureRecognizerState)state atPoint:(CGPoint)point
{
    NSLog(@"textStorageLongPressed");
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
