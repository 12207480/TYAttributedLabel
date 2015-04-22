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

- (instancetype)init
{
    if (self = [super init]) {
        _font = [UIFont systemFontOfSize:15];
    }
    return self;
}

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

- (NSAttributedString *)appendTextRunAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_text];
    
    // 验证范围
    if (NSEqualRanges(self.range, NSMakeRange(0, 0))) {
        self.range = NSMakeRange(0, attributedString.length);
    }
    [self addTextRunWithAttributedString:attributedString];
    return [attributedString copy];
}

@end
