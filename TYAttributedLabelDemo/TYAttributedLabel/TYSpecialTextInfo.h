//
//  TYSpecialTextInfo.h
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/4/7.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYBaseInfo.h"
#import <CoreText/CoreText.h>

@interface TYSpecialTextInfo : TYBaseInfo

@property (nonatomic, strong)   UIColor     *textColor;         // 文字颜色
@property (nonatomic, strong)   UIFont      *font;              // 文字大小

@property (nonatomic, assign)   CTUnderlineStyle underLineStyle;// 下划线样式（单 双）（默认没有）
@property (nonatomic, assign)   CTUnderlineStyleModifiers modifier;// 下划线样式 （点 线）（默认线）
@end
