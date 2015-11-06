//
//  UpdateLabelViewController.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/11/6.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "UpdateLabelViewController.h"
#import "TYAttributedLabel.h"
#import "RegexKitLite.h"

@interface UpdateLabelViewController ()<TYAttributedLabelDelegate>
@property (nonatomic,weak) TYAttributedLabel *label;
@end

#define RGB(r,g,b,a)	[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation UpdateLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(updateLabel)];
    
    [self addTextAttributedLabel];
}

// addAttributedText
- (void)addTextAttributedLabel
{
    //使用 RegexKitLite，添加 -fno-objc-arc，同时添加 libicucore.dylib
    //其实所有漂泊的人，不过是为了有一天能够不再漂泊，能用自己的力量撑起身后的家人和自己爱的人。
    TYAttributedLabel *label = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 0)];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor lightGrayColor];
    _label = label;
    label.delegate = self;
    NSString *text = [NSString stringWithFormat:@"[CYLoLi,%d,180]其实所有漂泊的人，[haha,15,15]不过是为了有一天能够不再[CYLoLi,%d,90]漂泊，[haha,15,15]能用自己的力量撑起身后的家人和自己爱的人。[avatar,60,60]",(int)CGRectGetWidth(self.view.frame),(int)CGRectGetWidth(self.view.frame)/2];
    
    // 属性文本生成器
    TYTextContainer *attStringCreater = [[TYTextContainer alloc]init];
    attStringCreater.text = text;
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
    [attStringCreater addTextStorageArray:tmpArray];
    
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [text rangeOfString:@"[CYLoLi,320,180]其实所有漂泊的人，"];
    textStorage.textColor = RGB(213, 0, 0, 1);
    textStorage.font = [UIFont systemFontOfSize:16];
    [attStringCreater addTextStorage:textStorage];
    
    textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [text rangeOfString:@"不过是为了有一天能够"];
    textStorage.textColor = RGB(0, 155, 0, 1);
    textStorage.font = [UIFont systemFontOfSize:18];
    [attStringCreater addTextStorage:textStorage];
    
    [attStringCreater createTextContainerWithTextWidth:CGRectGetWidth(self.view.frame)];
    
    [label setTextContainer:attStringCreater];
    [label sizeToFit];
}

- (void)updateLabel
{
    [_label updateDrawStorageLayoutUsingBlock:^(id<TYDrawStorageProtocol> drawStorage, BOOL *stop) {
        if ([drawStorage isKindOfClass:[TYImageStorage class]]) {
            TYImageStorage *imageStorage = drawStorage;
            
            if (imageStorage.size.width > 100) {
                imageStorage.size = CGSizeMake(imageStorage.size.width/2, imageStorage.size.height/2);
            }
        }
    }];
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
