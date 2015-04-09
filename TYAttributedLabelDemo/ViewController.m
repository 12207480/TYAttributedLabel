//
//  ViewController.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYAttributedLabel.h"
#import "TYDrawImageRun.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TYAttributedLabel *label = [[TYAttributedLabel alloc]init];
    NSString *text  = @" say:\n有人问一位登山家为什么要去登山——谁都知道登山这件事既危险，又没什么实际的好处。[haha][haha][haha][haha]他回答道：“因为那座山峰在那里。”我喜欢这个答案，因为里面包含着幽默感——明明是自己想要登山，偏说是山在那里使他心里痒痒。除此之外，我还喜欢这位登山家干的事，没来由地往悬崖上爬。[haha][haha][haha]它会导致肌肉疼痛，还要冒摔出脑子的危险，所以一般人尽量避免爬山。[haha][haha][haha]用热力学的角度来看，这是个反熵的现象，所发趋害避利肯定反熵。";
    NSArray *components = [text componentsSeparatedByString:@"[haha]"];
    NSUInteger count = [components count];
    for (NSUInteger i = 0; i < count; i++)
    {
        [label appendText:[components objectAtIndex:i]];
        if (i != count - 1)
        {
            TYDrawImageRun *imageRun = [[TYDrawImageRun alloc]init];
            imageRun.imageName = @"haha";
            imageRun.size = CGSizeMake(15, 15);
            [label appendTextRun:imageRun];
        }
    }
    TYDrawImageRun *imageRun = [[TYDrawImageRun alloc]init];
    imageRun.imageName = @"avatar";
    imageRun.size = CGSizeMake(60, 60);
    imageRun.range = NSMakeRange(0, 1);
    [label addTextRun:imageRun];
    [label setFrameWithOrign:CGPointMake(0, 64) Width:CGRectGetWidth(self.view.frame)];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
