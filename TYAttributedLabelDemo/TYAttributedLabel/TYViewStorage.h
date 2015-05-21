//
//  TYDrawViewStorage.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYDrawStorage.h"

@interface TYViewStorage : TYDrawStorage<TYViewStorageProtocol>

@property (nonatomic, strong)   UIView *view;       // 添加view

@end
