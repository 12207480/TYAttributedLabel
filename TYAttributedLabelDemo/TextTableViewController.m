//
//  TextTableViewController.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/9/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TextTableViewController.h"
#import "AttributedLabelCell.h"
#import "RegexKitLite.h"

@interface TextTableViewController ()<TYAttributedLabelDelegate>
@property (nonatomic, strong) NSArray *textContainers;
@end

static NSString *cellId = @"AttributedLabelCell";
#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation TextTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[AttributedLabelCell class] forCellReuseIdentifier:cellId];
    
    [self addTableViewItems];
}

- (void)addTableViewItems
{
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 16; ++i) {
        [tmp addObject:[self creatTextContainer]];
    }
    _textContainers = [tmp copy];
}

- (TYTextContainer *)creatTextContainer
{
    NSString *text = @"@青春励志: [haha,15,15]其实所有漂泊的人，[haha,15,15]不过是为了有一天能够不再漂泊，[haha,15,15][haha,15,15]能用自己的力量撑起身后的家人和自己爱的人。 [haha,15,15]#青春励志#[button]";
    
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.text = text;
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // 正则匹配图片信息
    [text enumerateStringsMatchedByRegex:@"\\[(\\w+?),(\\d+?),(\\d+?)\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if (captureCount > 3) {
            // 图片信息储存
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            imageStorage.cacheImageOnMemory = YES;
            imageStorage.imageName = capturedStrings[1];
            imageStorage.range = capturedRanges[0];
            imageStorage.size = CGSizeMake([capturedStrings[2]intValue], [capturedStrings[3]intValue]);
            
            [tmpArray addObject:imageStorage];
        }
    }];
    
    // 添加图片信息数组到label
    [textContainer addTextStorageArray:tmpArray];
    
    [textContainer addLinkWithLinkData:@"点击了@青春励志" linkColor:nil underLineStyle:kCTUnderlineStyleNone range:[text rangeOfString:@"@青春励志"]];
    
    [textContainer addLinkWithLinkData:@"点击了#青春励志#" linkColor:nil underLineStyle:kCTUnderlineStyleNone range:[text rangeOfString:@"#青春励志#"]];
    
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [text rangeOfString:@"[CYLoLi,320,180]其实所有漂泊的人，"];
    textStorage.textColor = RGB(213, 0, 0, 1);
    textStorage.font = [UIFont systemFontOfSize:16];
    [textContainer addTextStorage:textStorage];
    
    textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [text rangeOfString:@"不过是为了有一天能够不再漂泊，"];
    textStorage.textColor = RGB(0, 155, 0, 1);
    textStorage.font = [UIFont systemFontOfSize:18];
    [textContainer addTextStorage:textStorage];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 2;
    [button setBackgroundColor:[UIColor redColor]];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitle:@"UIButton" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 60, 15);
    [textContainer addView:button range:[text rangeOfString:@"[button]"]];
    textContainer.linesSpacing = 2;
    textContainer = [textContainer createTextContainerWithTextWidth:CGRectGetWidth(self.view.frame)];
    return textContainer;
}

#pragma mark - action

- (void)buttonClicked:(UIButton *)button
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:@"我是UIButton哦" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _textContainers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttributedLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    // Configure the cell...
    cell.label.delegate = self;
    cell.label.textContainer = _textContainers[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYTextContainer *textContaner = _textContainers[indexPath.row];
    return textContaner.textHeight+30;// after createTextContainer, have value
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了cell index:%ld",indexPath.row);
}

#pragma mark - TYAttributedLabelDelegate

- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    NSLog(@"textStorageClickedAtPoint");
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        
        id linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        if ([linkStr isKindOfClass:[NSString class]]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:linkStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }else if ([TextRun isKindOfClass:[TYImageStorage class]]) {
        TYImageStorage *imageStorage = (TYImageStorage *)TextRun;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"点击提示" message:[NSString stringWithFormat:@"你点击了%@图片",imageStorage.imageName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
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
