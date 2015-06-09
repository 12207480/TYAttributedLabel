//
//  TYTextContainer.h
//  TYAttributedLabelDemo
//
//  Created by SunYong on 15/6/4.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextStorageProtocol.h"
#import "NSMutableAttributedString+TY.h"

@interface TYTextContainer : NSObject

@property (nonatomic, strong)   NSString    *text;
@property (nonatomic, strong)   NSAttributedString *attributedText;

@property (nonatomic, assign)   NSInteger   numberOfLines;      //行数
@property (nonatomic, strong)   UIColor     *textColor;         // 文字颜色
@property (nonatomic, strong)   UIColor     *linkColor;         //链接颜色
@property (nonatomic, strong)   UIFont      *font;              // 文字大小

@property (nonatomic, assign)   unichar     characterSpacing;   // 字距
@property (nonatomic, assign)   CGFloat     linesSpacing;       // 行距

@property (nonatomic, assign)   CTTextAlignment textAlignment;  // 文本对齐方式
@property (nonatomic, assign)   CTLineBreakMode lineBreakMode;  // 换行模式

/**
 *  生成文本容器textContainer
 */
- (instancetype)createTextContainerWithTextWidth:(CGFloat)textWidth;

/**
 *  生成属性字符串
 */
- (NSMutableAttributedString *)createAttributedString;

/**
 *  获取文本高度
 */
- (int)getHeightWithFramesetter:(CTFramesetterRef)framesetter Width:(CGFloat)width;

@end

@interface TYTextContainer (Add)
/**
 *  添加 textStorage （自定义显示内容）
 *
 *  @param textStorage 自定义
 */
- (void)addTextStorage:(id<TYTextStorageProtocol>)textStorage;

/**
 *  添加 textRun数组 （自定义显示内容）
 *
 *  @param textRunArray textRun数组（需遵循协议TYTextStorageProtocol,否则不会添加）
 */
- (void)addTextStorageArray:(NSArray *)textStorageArray;

@end

#pragma mark - append
@interface TYTextContainer (Append)

/**
 *  追加(添加到最后) 普通文本
 *
 *  @param text 普通文本
 */
- (void)appendText:(NSString *)text;

/**
 *  追加(添加到最后) 属性文本
 *
 *  @param attributedText 属性文本
 */
- (void)appendTextAttributedString: (NSAttributedString *)attributedText;

/**
 *  追加(添加到最后) textStorage （自定义显示内容）
 *
 *  @param textStorage 自定义Storage（自定义显示内容）
 */
- (void)appendTextStorage:(id<TYAppendTextStorageProtocol>)textStorage;

/**
 *  追加(添加到最后) textStorage 数组
 *
 *  @param textStorageArray 自定义run数组（需遵循协议TYAppendTextStorageProtocol,否则不会添加）
 */
- (void)appendTextStorageArray:(NSArray *)textStorageArray;

@end

#pragma mark - Link
@interface TYTextContainer (Link)

/**
 *  添加 链接LinkTextStorage
 */
- (void)addLinkWithLinkData:(id)linkData range:(NSRange )range;

/**
 *  添加 链接LinkTextStorage
 */
- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor range:(NSRange )range;

/**
 *  添加 链接LinkTextStorage
 *
 *  @param linkData         链接携带的数据
 *  @param linkColor        链接颜色
 *  @param underLineStyle   下划线样式（无，单 双) 默认单
 *  @param range            范围
 */
- (void)addLinkWithLinkData:(id)linkData linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle range:(NSRange )range;

/**
 *  追加 链接LinkTextStorage
 */
- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkData:(id)linkData;

/**
 *  追加 链接LinkTextStorage
 */
- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor linkData:(id)linkData;

/**
 *  追加 链接LinkTextStorage
 *
 *  @param linkText         链接文本
 *  @param linkData         链接携带的数据
 *  @param underLineStyle   下划线样式（无，单 双) 默认单
 */
- (void)appendLinkWithText:(NSString *)linkText linkFont:(UIFont *)linkFont linkColor:(UIColor *)linkColor underLineStyle:(CTUnderlineStyle)underLineStyle linkData:(id)linkData;

@end

#pragma mark - 扩展支持UIImage
@interface TYTextContainer (UIImage)

#pragma mark - addImageStorage

/**
 *  添加 imageStorage image数据
 */
- (void)addImage:(UIImage *)image range:(NSRange)range;

/**
 *  添加 imageStorage image数据
 */
- (void)addImage:(UIImage *)image range:(NSRange)range size:(CGSize)size;

/**
 *  添加 imageStorage image数据
 *
 *  @param image        image
 *  @param range        所在文本位置
 *  @param size         图片大小
 *  @param alignment    图片对齐方式
 */
- (void)addImage:(UIImage *)image range:(NSRange)range
            size:(CGSize)size
       alignment: (TYDrawAlignment)alignment;

/**
 *  添加 imageStorage image数据
 */
- (void)addImageWithName:(NSString *)imageName range:(NSRange)range;

/**
 *  添加 imageStorage image数据
 */
- (void)addImageWithName:(NSString *)imageName
                   range:(NSRange)range
                    size:(CGSize)size;

/**
 *  添加 imageStorage image数据
 *
 *  @param imageName    image名
 *  @param range        所在文本位置
 *  @param size         图片大小
 *  @param alignment    图片对齐方式
 */
- (void)addImageWithName:(NSString *)imageName
                   range:(NSRange)range
                    size:(CGSize)size
               alignment:(TYDrawAlignment)alignment;

#pragma mark - appendImageStorage

/**
 *  追加 imageStorage image数据
 */
- (void)appendImage:(UIImage *)image;

/**
 *  追加 imageStorage image数据
 */
- (void)appendImage:(UIImage *)image
               size:(CGSize)size;

/**
 *  追加 imageStorage image数据
 *
 *  @param image    image
 *  @param size         图片大小
 *  @param alignment    图片对齐
 */
- (void)appendImage:(UIImage *)image
               size:(CGSize)size
          alignment:(TYDrawAlignment)alignment;

/**
 *  追加 imageStorage image数据
 */
- (void)appendImageWithName:(NSString *)imageName;

/**
 *  追加 imageStorage image数据
 */
- (void)appendImageWithName:(NSString *)imageName size:(CGSize)size;

/**
 *  追加 imageStorage image数据
 *
 *  @param imageName    imageName
 *  @param size         图片大小
 *  @param alignment    图片对齐
 */
- (void)appendImageWithName:(NSString *)imageName
                       size:(CGSize)size
                  alignment:(TYDrawAlignment)alignment;


@end

#pragma mark - 扩展支持UIView
@interface TYTextContainer (UIView)

/**
 *  添加 viewStorage (添加 UI控件 需要设置frame)
 */
- (void)addView:(UIView *)view range:(NSRange)range;

/**
 *  添加 viewStorage (添加 UI控件 需要设置frame)
 *
 *  @param view         UIView (UI控件)
 *  @param range        所在文本位置
 *  @param alignment    view对齐方式
 */
- (void)addView:(UIView *)view
          range:(NSRange)range
      alignment:(TYDrawAlignment)alignment;

/**
 *  追加 viewStorage (添加 UI控件 需要设置frame)
 */
- (void)appendView:(UIView *)view;

/**
 *  追加 viewStorage (添加 UI控件 需要设置frame)
 *
 *  @param view  UIView (UI控件)
 *  @param alignment view对齐
 */
- (void)appendView:(UIView *)view alignment:(TYDrawAlignment)alignment;

@end


