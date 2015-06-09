//
//  TextContainerViewController.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/6/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TextContainerViewController.h"
#import "TYAttributedLabel.h"
#import "RegexKitLite.h"
#import "TYTextStorage.h"
#import "TYImageStorage.h"

@interface TextContainerViewController ()<TYAttributedLabelDelegate>
@property (nonatomic,weak) TYAttributedLabel *label1;
@property (nonatomic,strong) TYTextContainer *textContainer;
@property (nonatomic,strong) NSAttributedString *attString;
@property (nonatomic,weak) UIScrollView *scrollView;
@end

#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation TextContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createTextContainer];
    
    [self addScrollView];
    
    [self addTextAttributedLabel1];
    
    [self addTextAttributedLabel2];
}

- (void)addScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)createTextContainer
{
    NSString *text = @"[CYLoLi,320,180]其实所有漂泊的人，[haha,15,15]不过是为了有一天能够不再漂泊，[haha,15,15]能用自己的力量撑起身后的家人和自己爱的人。[avatar,60,60]";
    
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.text = text;
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // 正则匹配图片信息
    [text enumerateStringsMatchedByRegex:@"\\[(\\w+?),(\\d+?),(\\d+?)\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if (captureCount > 3) {
            // 图片信息储存
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            imageStorage.imageName = capturedStrings[1];
            imageStorage.range = capturedRanges[0];
            imageStorage.size = CGSizeMake([capturedStrings[2]intValue], [capturedStrings[3]intValue]);
            
            [tmpArray addObject:imageStorage];
        }
    }];
    
    // 添加图片信息数组到label
    [textContainer addTextStorageArray:tmpArray];
    
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
    
    _attString = [textContainer createAttributedString];
    
    _textContainer = [textContainer createTextContainerWithTextWidth:CGRectGetWidth(self.view.frame)];

}

- (void)addTextAttributedLabel1
{
    TYAttributedLabel *label1 = [[TYAttributedLabel alloc]init];
    label1.delegate = self;
    label1.attributedText = _attString;
    [label1 setFrameWithOrign:CGPointZero Width:CGRectGetWidth(self.view.frame)];
    
    [_scrollView addSubview:label1];
    _label1 = label1;
}

- (void)addTextAttributedLabel2
{
    //使用 RegexKitLite，添加 -fno-objc-arc，同时添加 libicucore.dylib
    //其实所有漂泊的人，不过是为了有一天能够不再漂泊，能用自己的力量撑起身后的家人和自己爱的人。
    TYAttributedLabel *label = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_label1.frame) + 20, CGRectGetWidth(self.view.frame), 0)];
    [_scrollView addSubview:label];
    label.delegate = self;
    
    [label setTextContainer:_textContainer];
    
    [label sizeToFit];
    
    [_scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(label.frame)+10)];
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
