//
//  TYTextRun.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYTextRun.h"
#import "NSMutableAttributedString+TY.h"

@implementation TYTextRun

- (void)addTextRunWithAttributedString:(NSMutableAttributedString *)attributedString
{
    // 颜色
    if (self.textColor) {
        [attributedString addAttributeTextColor:self.textColor range:self.range];
    }
    // 字体
    if (self.font) {
        [attributedString addAttributeFont:self.font range:self.range];
    }
    
    // 下划线
    if (self.underLineStyle) {
        [attributedString addAttributeUnderlineStyle:self.underLineStyle modifier:self.modifier range:self.range];
    }
}

@end
