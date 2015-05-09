//
//  TYAttributedLabel.h
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//  TYAttributedLabel v1.0 verson 

#import <UIKit/UIKit.h>
#import "NSMutableAttributedString+TY.h"
#import "TYTextStorageProtocol.h"

@class TYAttributedLabel;
@protocol TYAttributedLabelDelegate <NSObject>
@optional
// textStorage点击代理
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage;
@end

/**
 *  TYAttributedLabel 属性文本 支持富文本显示，支持添加image和UIView，支持自定义排版
 */
@interface TYAttributedLabel : UIView

@property (nonatomic, assign) id<TYAttributedLabelDelegate>     delegate;

@property (nonatomic, strong)   NSString        *text;
@property (nonatomic, strong)   UIColor         *textColor;         // 文字颜色
@property (nonatomic, strong)   UIFont          *font;              // 文字大小

@property (nonatomic, assign)   unichar         characterSpacing;   // 字距
@property (nonatomic, assign)   CGFloat         linesSpacing;       // 行距

@property (nonatomic, assign)   CTTextAlignment textAlignment;      // 文本对齐方式

@property (nonatomic, assign)   CTLineBreakMode lineBreakMode;      // 换行模式

@property (nonatomic, assign, readonly)NSInteger replaceStringNum;  // 图片替换字符数

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

/**
 *  调用可以自动计算frame大小（请确定label之前设置了宽度）
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


#pragma mark - 扩展支持UIImage和UIView
@interface TYAttributedLabel (UIImageAndUIView)

#pragma mark - addStorage

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

#pragma mark - appendStorage

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
