//
//  TYAttributedLabel.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYAttributedLabel;
@protocol TYTextRunProtocol;

@protocol TYAttributedLabelDelegate <NSObject>

@optional

- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textRunClicked:(id<TYTextRunProtocol>)TextRun;

@end

@interface TYAttributedLabel : UIView

@property (nonatomic, assign) id<TYAttributedLabelDelegate> delegate;

@property (nonatomic, strong)   NSString        *text;              // 内容
@property (nonatomic, strong)   UIColor         *textColor;         // 文字颜色
@property (nonatomic, strong)   UIFont          *font;              // 文字大小

@property (nonatomic, assign)   unichar         characterSpacing;   // 字距
@property (nonatomic, assign)   CGFloat         linesSpacing;       // 行距

@property (nonatomic, assign)   CTTextAlignment textAlignment;      // 文本对齐方式

@property (nonatomic, assign)   CTLineBreakMode lineBreakMode;      // 换行模式

/**
 *  设置属性文本 （初始化文本）
 *
 *  @param attributedText 属性文本
 */
- (void)setAttributedText: (NSAttributedString *)attributedText;

/**
 *  添加 textRun （自定义显示内容）
 *
 *  @param textRun 自定义run
 */
- (void)addTextRun:(id<TYTextRunProtocol>)textRun;

/**
 *  添加 textRun数组 （自定义显示内容）
 *
 *  @param textRunArray textRun数组（需遵循协议TYTextRunProtocol）
 */
- (void)addTextRunArray:(NSArray *)textRunArray;

/**
 *  获取文本真正的高度
 */
- (int)getHeightWithWidth:(CGFloat)width;

/**
 *  设置文本位置大小 （自动计算高度，根据宽度）
 */
- (void)setFrameWithOrign:(CGPoint)orign Width:(CGFloat)width;

@end

// 追加内容 （添加在AttributedString最后）
@interface TYAttributedLabel (AppendAttributedString)
/**
 *  追加 普通文本
 *
 *  @param text 普通文本
 */
- (void)appendText:(NSString *)text;

/**
 *  追加 属性文本
 *
 *  @param attributedText 属性文本
 */
- (void)appendAttributedText: (NSAttributedString *)attributedText;

/**
 *  追加 textRun （自定义显示内容）
 *
 *  @param textRun 自定义run（自定义显示内容）
 */
- (void)appendTextRun:(id<TYTextRunProtocol>)textRun;

@end
