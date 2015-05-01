//
//  ViewController.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYAttributedLabel.h"
#import "TYDrawImageStorage.h"
#import "TYDrawViewStorage.h"
#import "SimpleTextViewController.h"
#import "AttributedTextViewController.h"
#import "ImageTextViewController.h"
#import "LinkTextViewController.h"
#import "ParseTextViewController.h"
#import "AddViewTextViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) TYAttributedLabel *label;
@property (nonatomic, strong) NSDictionary *dataDic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.dataDic = @{@"SimpleText":[SimpleTextViewController class],@"AttributedText":[AttributedTextViewController class],@"ImageText":[ImageTextViewController class],@"LinkText":[LinkTextViewController class],@"parseText":[ParseTextViewController class],@"AddViewText":[AddViewTextViewController class]};
    
    [self addTableView];
    
}

- (void)addTableView
{
    // 添加tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.dataDic allKeys][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class class = [self.dataDic allValues][indexPath.row];
    UIViewController *VC = [[class alloc]init];
    VC.view.backgroundColor = [UIColor whiteColor];
    VC.title = [self.dataDic allKeys][indexPath.row];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)addAttributedLabel
{
    TYAttributedLabel *label = [[TYAttributedLabel alloc]init];
    label.longPressShowMenuEnable = YES;
    //label.sizeToFitTextChange = YES;
    self.label = label;
    //[label addTextRunArray:@[@" ",@" "]];
    [label appendImageWithContent:@"avatar" size:CGSizeMake(60, 60)];
    NSString *text  = @"say:\n有人问一位登山家为什么要去登山——谁都知道登山这件事既危险，又没什么实际的好处。[haha][haha][haha][haha]他回答道：“因为那座山峰在那里。”我喜欢这个答案，因为里面包含着幽默感——明明是自己想要登山，偏说是山在那里使他心里痒痒。除此之外，我还喜欢这位登山家干的事，没来由地往悬崖上爬。[haha][haha][haha]它会导致肌肉疼痛，还要冒摔出脑子的危险，所以一般人尽量避免爬山。[haha][haha][haha]用热力学的角度来看，这是个反熵的现象，所发趋害避利肯定反熵。";
    NSArray *components = [text componentsSeparatedByString:@"[haha]"];
    NSUInteger count = [components count];
    for (NSUInteger i = 0; i < count; i++)
    {
        [label appendText:[components objectAtIndex:i]];
        if (i != count - 1)
        {
            TYDrawImageStorage *imageRun = [[TYDrawImageStorage alloc]init];
            imageRun.imageContent = @"haha";
            imageRun.size = CGSizeMake(15, 15);
            [label appendTextStorage:imageRun];
        }
    }
    TYDrawImageStorage *imageRun1 = [[TYDrawImageStorage alloc]init];
    imageRun1.imageContent = @"avatar";
    imageRun1.drawAlignment = TYDrawAlignmentCenter;
    imageRun1.size = CGSizeMake(60, 60);
    imageRun1.range = NSMakeRange(120, 1);
    [label addTextStorage:imageRun1];
    
    TYDrawImageStorage *imageRun2 = [[TYDrawImageStorage alloc]init];
    imageRun2.imageContent = @"haha";
    imageRun2.size = CGSizeMake(15, 15);
    imageRun2.range = NSMakeRange(68, 1);
    [label addTextStorage:imageRun2];
    
    //[label addImageWithContent:@"avatar" range:NSMakeRange(120, 2) size:CGSizeMake(60, 60)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"点我啊" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeFont) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 60, 15);
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"avatar"]];
    imageView.frame = CGRectMake(0, 0, 60, 60);
    TYDrawViewStorage * drawView = [[TYDrawViewStorage alloc]init];
    drawView.view = button;
    drawView.range = NSMakeRange(146, 1);
    [label addTextStorage:drawView];
    //[label addView:button range:NSMakeRange(146, 1)];
    [label appendView:imageView alignment:TYDrawAlignmentButtom];
    [label appendImageWithContent:@"haha"];
    [label setFrameWithOrign:CGPointMake(0, 64) Width:CGRectGetWidth(self.view.frame)];
    [self.view addSubview:label];
}

- (void)changeFont
{
    self.label.font = [self.label.font fontWithSize:self.label.font.pointSize +2];
    self.label.textColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    [self.label sizeToFit];
    
    [self performSelector:@selector(deleteLabel) withObject:nil afterDelay:2];
}

- (void)deleteLabel
{
    [self.label removeFromSuperview];
    self.label = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
