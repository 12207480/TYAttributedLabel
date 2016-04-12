//
//  NSMutableAttributedString+TY.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "NSMutableAttributedString+TY.h"

@implementation NSMutableAttributedString (TY)

#pragma mark - 文本颜色属性
- (void)addAttributeTextColor:(UIColor*)color
{
    [self addAttributeTextColor:color range:NSMakeRange(0, [self length])];
}

- (void)addAttributeTextColor:(UIColor*)color range:(NSRange)range
{
    if (color.CGColor)
    {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
    
}

#pragma mark - 文本字体属性
- (void)addAttributeFont:(UIFont *)font
{
    [self addAttributeFont:font range:NSMakeRange(0, [self length])];
}

- (void)addAttributeFont:(UIFont *)font range:(NSRange)range
{
    if (font)
    {
        [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (nil != fontRef)
        {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

#pragma mark - 文本字符间隔属性
- (void)addAttributeCharacterSpacing:(unichar)characterSpacing
{
    [self addAttributeCharacterSpacing:characterSpacing range:NSMakeRange(0, self.length)];
}

- (void)addAttributeCharacterSpacing:(unichar)characterSpacing range:(NSRange)range
{
    [self removeAttribute:(id)kCTKernAttributeName range:range];
    
    CFNumberRef num =  CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&characterSpacing);
    [self addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:range];
    CFRelease(num);
}

#pragma mark - 文本下划线属性
- (void)addAttributeUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
{
    [self addAttributeUnderlineStyle:style
                   modifier:modifier
                      range:NSMakeRange(0, self.length)];
}

- (void)addAttributeUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range
{
    [self removeAttribute:(NSString *)kCTUnderlineColorAttributeName range:range];
    
    if (style != kCTUnderlineStyleNone) {
        [self addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                     value:[NSNumber numberWithInt:(style|modifier)]
                     range:range];
    }
    
}

#pragma mark - 文本空心字及颜色

- (void)addAttributeStrokeWidth:(unichar)strokeWidth
                    strokeColor:(UIColor *)strokeColor
{
    [self addAttributeStrokeWidth:strokeWidth strokeColor:strokeColor range:NSMakeRange(0, self.length)];
}

- (void)addAttributeStrokeWidth:(unichar)strokeWidth
                    strokeColor:(UIColor *)strokeColor
                          range:(NSRange)range
{
    [self removeAttribute:(id)kCTStrokeWidthAttributeName range:range];
    if (strokeWidth > 0) {
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&strokeWidth);
        
        [self addAttribute:(id)kCTStrokeWidthAttributeName value:(__bridge id)num range:range];
    }
    
    [self removeAttribute:(id)kCTStrokeColorAttributeName range:range];
    if (strokeColor) {
        [self addAttribute:(id)kCTStrokeColorAttributeName value:(id)strokeColor.CGColor range:range];
    }
    
}

#pragma mark - 文本段落样式属性
- (void)addAttributeAlignmentStyle:(CTTextAlignment)textAlignment
                    lineSpaceStyle:(CGFloat)linesSpacing
               paragraphSpaceStyle:(CGFloat)paragraphSpacing
                    lineBreakStyle:(CTLineBreakMode)lineBreakMode
{
    [self addAttributeAlignmentStyle:textAlignment lineSpaceStyle:linesSpacing paragraphSpaceStyle:paragraphSpacing lineBreakStyle:lineBreakMode range:NSMakeRange(0, self.length)];
}

- (void)addAttributeAlignmentStyle:(CTTextAlignment)textAlignment
                    lineSpaceStyle:(CGFloat)linesSpacing
               paragraphSpaceStyle:(CGFloat)paragraphSpacing
                    lineBreakStyle:(CTLineBreakMode)lineBreakMode
                             range:(NSRange)range
{
    [self removeAttribute:(id)kCTParagraphStyleAttributeName range:range];
    
    // 创建文本对齐方式
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize = sizeof(textAlignment);
    alignmentStyle.value = &textAlignment;
    
    // 创建文本行间距
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    lineSpaceStyle.valueSize = sizeof(linesSpacing);
    lineSpaceStyle.value = &linesSpacing;
    
    //段落间距
    CTParagraphStyleSetting paragraphSpaceStyle;
    paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraphSpaceStyle.value = &paragraphSpacing;
    paragraphSpaceStyle.valueSize = sizeof(paragraphSpacing);
    
    //换行模式
    CTParagraphStyleSetting lineBreakStyle;
    lineBreakStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakStyle.value = &lineBreakMode;
    lineBreakStyle.valueSize = sizeof(lineBreakMode);
    
    // 创建样式数组
    CTParagraphStyleSetting settings[] = {alignmentStyle ,lineSpaceStyle, paragraphSpaceStyle, lineBreakStyle};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));	// 设置样式
    
    // 设置段落属性
    [self addAttribute:(id)kCTParagraphStyleAttributeName value:(id)CFBridgingRelease(paragraphStyle) range:range];
}

@end
