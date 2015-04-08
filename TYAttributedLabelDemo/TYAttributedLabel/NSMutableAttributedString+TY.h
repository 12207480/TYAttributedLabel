//
//  NSMutableAttributedString+TY.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSMutableAttributedString (TY)

/**
 *  添加文本颜色属性
 *
 *  @param color 文本颜色
 */
- (void)addAttributeTextColor:(UIColor*)color;

- (void)addAttributeTextColor:(UIColor*)color range:(NSRange)range;

/**
 *  添加文本字体属性
 *
 *  @param font 字体
 */
- (void)addAttributeFont:(UIFont *)font;

- (void)addAttributeFont:(UIFont *)font range:(NSRange)range;

/**
 *  添加文本字符间隔
 *
 *  @param characterSpacing 字符间隔
 */
- (void)addAttributeCharacterSpacing:(unichar)characterSpacing;

- (void)addAttributeCharacterSpacing:(unichar)characterSpacing range:(NSRange)range;

/**
 *  添加下划线样式
 *
 *  @param style    下划线 （单下划线 双 无）
 *  @param modifier 下划线样式 （点 线）
 */
- (void)addAttributeUnderlineStyle:(CTUnderlineStyle)style
                          modifier:(CTUnderlineStyleModifiers)modifier;

- (void)addAttributeUnderlineStyle:(CTUnderlineStyle)style
                          modifier:(CTUnderlineStyleModifiers)modifier
                             range:(NSRange)range;

/**
 *  添加文本段落样式
 *
 *  @param textAlignment 文本对齐样式
 *  @param linesSpacing  文本行间距
 *  @param lineBreakMode 文本换行样式
 */
- (void)addAttributeAlignmentStyle:(CTTextAlignment)textAlignment
                    lineSpaceStyle:(CGFloat)linesSpacing
                    lineBreakStyle:(CTLineBreakMode)lineBreakMode;

- (void)addAttributeAlignmentStyle:(CTTextAlignment)textAlignment
                    lineSpaceStyle:(CGFloat)linesSpacing
                    lineBreakStyle:(CTLineBreakMode)lineBreakMode
                             range:(NSRange)range;

@end
