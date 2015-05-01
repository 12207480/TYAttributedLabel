//
//  TYTextStorage.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextRunProtocol.h"
#import <CoreText/CoreText.h>

@interface TYTextStorage : NSObject<TYAppendTextStorageProtocol>

@property (nonatomic, assign)   NSRange     range;
@property (nonatomic, strong)   NSString    *text;              // append text文本
@property (nonatomic, strong)   UIColor     *textColor;         // 文本颜色
@property (nonatomic, strong)   UIFont      *font;              // 字体

@property (nonatomic, assign)   CTUnderlineStyle underLineStyle;// 下划线样式（单 双）（默认没有）
@property (nonatomic, assign)   CTUnderlineStyleModifiers modifier;// 下划线样式 （点 线）（默认线）

@end
