//
//  CustomeTextViewController.m
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/17.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ParseTextViewController.h"
#import "TYAttributedLabel.h"
#import "TYTextRunParser.h"

@interface ParseTextViewController ()<TYAttributedLabelDelegate>
@property (nonatomic, strong) TYAttributedLabel *label;
@end

@implementation ParseTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // appendAttributedText
    [self addTextAttributedLabel];
    
    // jsonPath
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    
    // parseJson
    [self parseJsonFileWithPath:path];
    
    [_label sizeToFit];
}

- (void)addTextAttributedLabel
{
    TYAttributedLabel *label = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 0)];
    label.delegate = self;
    [self.view addSubview:label];
    _label = label;
}

- (void)parseJsonFileWithPath:(NSString *)filePath
{
    NSArray *textRunArray = [TYTextRunParser parseWithJsonFilePath:filePath];
    
    if (textRunArray.count > 0) {
        [_label appendTextRunArray:textRunArray];
    }
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
