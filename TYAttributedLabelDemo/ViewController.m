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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
