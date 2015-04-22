//
//  TYAttributedLabel.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableAttributedString+TY.h"
#import "TYTextRunProtocol.h"

@class TYAttributedLabel;
@protocol TYAttributedLabelDelegate <NSObject>
@optional
// 点击代理
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textRunClicked:(id<TYTextRunProtocol>)TextRun;

@end

/**
 *  TYAttributedLabel 属性文本 支持富文本显示，支持添加image和view（UI控件）
 */
@interface TYAttributedLabel : UIView

@property (nonatomic, assign) id<TYAttributedLabelDelegate> delegate;

@property (nonatomic, strong)   NSString        *text;
@property (nonatomic, strong)   UIColor         *textColor;         // 文字颜色
@property (nonatomic, strong)   UIFont          *font;              // 文字大小

@property (nonatomic, assign)   unichar         characterSpacing;   // 字距
@property (nonatomic, assign)   CGFloat         linesSpacing;       // 行距

@property (nonatomic, assign)   CTTextAlignment textAlignment;      // 文本对齐方式

@property (nonatomic, assign)   CTLineBreakMode lineBreakMode;      // 换行模式

@property (nonatomic, assign)   BOOL            longPressShowMenuEnable;// 长按出现菜单选择,默认不启用

/**
 *  获取普通文本内容
 */
- (NSString *)text;

/**
 *  获取属性文本内容
 */
- (NSAttributedString *)attributedText;

/**
 *  设置普通初始化文本内容
 *
 *  @param text 普通文本内容
 */
- (void)setText:(NSString *)text;

/**
 *  设置属性初始化文本内容
 *
 *  @param attributedText 属性文本内容
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
 *  @param textRunArray textRun数组（需遵循协议TYTextRunProtocol,否则不会添加）
 */
- (void)addTextRunArray:(NSArray *)textRunArray;

/**
 *  调用可以自动计算frame大小
 */
- (void)sizeToFit;

/**
 *  获取文本真正的高度
 */
- (int)getHeightWithWidth:(CGFloat)width;

/**
 *  设置文本位置大小 （自动计算高度，根据宽度）
 */
- (void)setFrameWithOrign:(CGPoint)orign Width:(CGFloat)width;

@end

#pragma mark - 扩展追加内容 (AppendAttributedString)
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
- (void)appendTextAttributedString: (NSAttributedString *)attributedText;

/**
 *  追加 textRun （自定义显示内容）
 *
 *  @param textRun 自定义run（自定义显示内容）
 */
- (void)appendTextRun:(id<TYAppendTextRunProtocol>)textRun;

/**
 *  追加 textRun 数组
 *
 *  @param textRunArray 自定义run数组（需遵循协议TYAppendTextRunProtocol,否则不会添加）
 */
- (void)appendTextRunArray:(NSArray *)textRunArray;

@end

#pragma mark - 扩展支持UIImage和UIView

@interface TYAttributedLabel (UIImageAndUIView)

#pragma mark - addRun
/**
 *  添加 imageRun (默认size大小: UIImage 按照image.size, 其他按照font大小)
 */
- (void)addImageWithContent:(id)imageContent range:(NSRange)range;

/**
 *  添加 imageRun（imageContent:NSString - 本地image名, NSURL - image图片网址, UIImage - image数据）
 */
- (void)addImageWithContent:(id)imageContent
                      range:(NSRange)range
                       size:(CGSize)size;

/**
 *  添加 imageRun（imageContent:NSString - 本地image名, NSURL - image图片网址, UIImage - image数据）
 *
 *  @param imageContent 格式（NSURL，NSString，UIImage）
 *  @param range        所在文本位置
 *  @param size         图片大小
 *  @param alignment    图片对齐方式
 */
- (void)addImageWithContent:(id)imageContent
                      range:(NSRange)range
                       size:(CGSize)size
                  alignment: (TYDrawAlignment)alignment;

/**
 *  添加 viewRun (添加 UI控件 需要设置frame)
 */
- (void)addView:(UIView *)view range:(NSRange)range;

/**
 *  添加 viewRun (添加 UI控件 需要设置frame)
 *
 *  @param view         UIView (UI控件)
 *  @param range        所在文本位置
 *  @param alignment    view对齐方式
 */
- (void)addView:(UIView *)view
          range:(NSRange)range
      alignment:(TYDrawAlignment)alignment;

#pragma mark - appendRun

/**
 *  追加 imageRun （imageContent:NSString - 本地image名, NSURL - image图片网址, UIImage - image数据）
 */
- (void)appendImageWithContent:(id)imageContent;

/**
 *  追加 imageRun（imageContent:NSString - 本地image名, NSURL - image图片网址, UIImage - image数据）
 */
- (void)appendImageWithContent:(id)imageContent size:(CGSize)size ;

/**
 *  追加 imageRun（imageContent:NSString - 本地image名, NSURL - image图片网址, UIImage - image数据）
 *
 *  @param imageContent 格式（NSURL，NSString，UIImage）
 *  @param size         图片大小
 *  @param alignment    图片对齐
 */
- (void)appendImageWithContent:(id)imageContent
                          size:(CGSize)size
                     alignment:(TYDrawAlignment)alignment;

/**
 *  追加 viewRun (添加 UI控件 需要设置frame)
 */
- (void)appendView:(UIView *)view;

/**
 *  追加 viewRun (添加 UI控件 需要设置frame)
 *
 *  @param view  UIView (UI控件)
 *  @param alignment view对齐
 */
- (void)appendView:(UIView *)view alignment:(TYDrawAlignment)alignment;

@end
