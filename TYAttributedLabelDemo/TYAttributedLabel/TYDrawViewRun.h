//
//  TYDrawViewRun.h
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawRun.h"

@interface TYDrawViewRun : TYDrawRun

@property (nonatomic, strong)   UIView *view;       // 添加view

@property (nonatomic, weak)     UIView *superView;  // 父类view

@end
