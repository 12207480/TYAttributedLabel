//
//  TextViewController.m
//  TYAttributedLabelDemo
//
//  Created by Macrotellect-iOSDev on 2020/1/15.
//  Copyright © 2020 tanyang. All rights reserved.
//
#define RGB(r,g,b,a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#import "TextViewController.h"
#import "TYAttributedLabel.h"
@interface TextViewController ()<TYAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TYAttributedLabel *label1;

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addTextAttributedLabel1];
       
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%s", __func__);
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self addTextAttributedLabel1];
    }else{
       [self addTextAttributedLabel1];
    }
}



- (void)addTextAttributedLabel1
{
    _label1.attributedText = [[NSAttributedString alloc] initWithString:@""];
    _label1.delegate = self;
    _label1.highlightedLinkColor = [UIColor orangeColor];
    
    NSString *text = @"总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心但这个过程会很痛，会很辛苦，有时候还会觉得灰心\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。\n\t我们都将孤独地长大，不要害怕。\n\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n\t但这个过程会很痛，会很辛苦，有时候还会觉得灰心。\n\t面对着汹涌而来的现实，觉得自己渺小无力。\n\t但这，也是生命的一部分，做好现在你能做的，然后，一切都会好的。\n\t我们都将孤独地长大，不要害怕。";
    
    NSArray *textArray = [text componentsSeparatedByString:@"\n\t"];
    NSArray *colorArray = @[RGB(213, 0, 0, 1),RGB(0, 155, 0, 1),RGB(103, 0, 207, 1),RGB(209, 162, 74, 1),RGB(206, 39, 206, 1)];
    NSInteger index = 0;
    
    for (NSString *text in textArray) {
        
        if (index == 2) {
            // 追加链接信息
            [_label1 appendLinkWithText:text linkFont:[UIFont systemFontOfSize:15+arc4random()%4] linkData:@"http://www.baidu.com"];
        }else {
            
              NSLog(@"=====index: %ld",(long)index);
            // 追加文本属性
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
            //局部
            [attributedString addAttributeCharacterSpacing:10];
            [attributedString addAttributeAlignmentStyle:kCTTextAlignmentLeft lineSpaceStyle:10.0 paragraphSpaceStyle:20.0 lineBreakStyle:kCTLineBreakByWordWrapping];
            [attributedString addAttributeTextColor:colorArray[index%5]];
            [attributedString addAttributeFont:[UIFont systemFontOfSize:15+arc4random()%4]];
            
            [_label1 appendTextAttributedString:attributedString];
        }
        [_label1 appendText:@"\n\t  11111 \n\t"];
        index++;
    }
    //全局
//    _label1.characterSpacing =20;
//         _label1.linesSpacing = 20.0;
//        _label1.paragraphSpacing =20.0;
    [_label1 appendLinkWithText:@"百度一下" linkFont:[UIFont systemFontOfSize:15+arc4random()%4] linkData:@"http://www.baidu.com"];


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
