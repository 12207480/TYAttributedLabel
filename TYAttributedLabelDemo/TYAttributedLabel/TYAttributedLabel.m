//
//  TYAttributedLabel.m
//  TYAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAttributedLabel.h"
#import <CoreText/CoreText.h>

// 文本颜色
#define kTextColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]

@interface TYAttributedLabel ()
{
    CTFramesetterRef            _framesetter;
}
@property (nonatomic, strong)   NSMutableAttributedString   *attString;         // 文字属性
@property (nonatomic, strong)   NSMutableArray              *textRunArray;      // run数组
@property (nonatomic,strong)    NSDictionary                *runRectDictionary; // runRect字典
@property (nonatomic, strong)   UITapGestureRecognizer      *singleTap;         //点击手势

@property (nonatomic, assign)   BOOL                        isFitToSize;
@end

@implementation TYAttributedLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupProperty];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperty];
    }
    return self;
}

- (NSMutableArray *)textRunArray
{
    if (_textRunArray == nil) {
        _textRunArray = [NSMutableArray array];
    }
    return _textRunArray;
}

#pragma mark - 设置属性
- (void)setupProperty
{
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.userInteractionEnabled = NO;
    _font = [UIFont systemFontOfSize:16];
    _characterSpacing = 1;
    _linesSpacing = 4;
    _textAlignment = kCTLeftTextAlignment;
    _lineBreakMode = kCTLineBreakByCharWrapping;
    _textColor = kTextColor;
}

- (NSString *)text{
    return _attString.string;
}

- (NSAttributedString *)attributedText
{
    return _attString;
}

- (void)setText:(NSString *)text
{
    _attString = [self createTextAttibuteStringWithText:text];
    [self resetAllAttributed];
    _isFitToSize = YES;
    [self resetFramesetter];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _attString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    [self resetAllAttributed];
    _isFitToSize = YES;
    [self resetFramesetter];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        
        [_attString addAttributeTextColor:textColor];
        _isFitToSize = YES;
        [self resetFramesetter];
    }
}

- (void)setFont:(UIFont *)font
{
    if (font && _font != font){
        _font = font;
        
        [_attString addAttributeFont:font];
        [self resetTextRunArray];
        [self resetFramesetter];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    if (characterSpacing && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        
        [_attString addAttributeCharacterSpacing:characterSpacing];
        [self resetFramesetter];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    if (linesSpacing > 0 && _linesSpacing != linesSpacing) {
        _linesSpacing = linesSpacing;
        
        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFramesetter];
    }
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        
        [_attString addAttributeAlignmentStyle:textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFramesetter];
    }
}

#pragma mark - add textRun
- (void)addTextRun:(id<TYTextRunProtocol>)textRun
{
    if (textRun ) {
        if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
            [(id<TYDrawRunProtocol>)textRun setTextFontAscent:_font.ascender descent:_font.descender];
        }
        if ([textRun conformsToProtocol:@protocol(TYDrawViewRunProtocol)]){
            [(id<TYDrawViewRunProtocol>)textRun setSuperView:self];
        }

        [self.textRunArray addObject:textRun];
    }
}

- (void)addTextRunArray:(NSArray *)textRunArray
{
    if (textRunArray) {
        for (id textRun in textRunArray) {
            if ([textRun conformsToProtocol:@protocol(TYTextRunProtocol)]) {
                [self addTextRun:textRun];
            }
        }
        [self resetFramesetter];
    }
}

- (void)resetAllAttributed
{
    _runRectDictionary = nil;
    _textRunArray = nil;
    [self removeSingleTapGesture];
    [self setupProperty];
}

- (void)resetTextRunArray
{
    for (id<TYTextRunProtocol>textRun in self.textRunArray) {
        if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
            [(id<TYDrawRunProtocol>)textRun setTextFontAscent:_font.ascender descent:_font.descender];
        }
    }
}

#pragma mark 重置framesetter
- (void)resetFramesetter
{
    if (_framesetter)
    {
        CFRelease(_framesetter);
        _framesetter = nil;
    }
    if ([NSThread isMainThread])
    {
//        if (_sizeToFitTextChange) {
//            [self setNeedFitToSize];
//        }
        [self setNeedsDisplay];
    }
}

#pragma mark 更新framesetter，如果需要
- (void)updateFramesetterIfNeeded
{
    // 是否更新了内容
    if (_framesetter == nil) {
        
        // 添加文本run属性
        [self addTextRunsWithAtrributedString:_attString];
        
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);
        
    }
}

#pragma mark - 创建属性文本字符串
- (NSMutableAttributedString *)createTextAttibuteStringWithText:(NSString *)text
{
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc]init];
    }
    // 创建属性文本
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:text];
    
    // 添加文本颜色 字体属性
    [self addTextColorAndFontWithAtrributedString:attString];
    
    // 添加文本段落样式
    [self addTextParaphStyleWithAtrributedString:attString];
    
    return attString;
}

// 添加文本颜色 字体属性
- (void)addTextColorAndFontWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 添加文本字体
    [attString addAttributeFont:_font];
    
    // 添加文本颜色
    [attString addAttributeTextColor:_textColor];
    
}

// 添加文本段落样式
- (void)addTextParaphStyleWithAtrributedString:(NSMutableAttributedString *)attString
{
    // 字体间距
    if (_characterSpacing)
    {
        [attString addAttributeCharacterSpacing:_characterSpacing];
    }
    
    // 添加文本段落样式
    [attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
}

#pragma mark -  添加文本run属性
- (void)addTextRunsWithAtrributedString:(NSMutableAttributedString *)attString
{
    if (attString && _textRunArray.count > 0) {
        for (id<TYTextRunProtocol> textRun in _textRunArray) {
            // 验证范围
            if (NSMaxRange([textRun range]) < attString.length) {
                [textRun addTextRunWithAttributedString:attString];
            }
        }
        [_textRunArray removeAllObjects];
    }
}

#pragma mark - 绘画
- (void)drawRect:(CGRect)rect {
    
    if (_attString == nil) {
        return;
    }
    _isFitToSize = NO;
    //	跟很多底层 API 一样，Core Text 使用 Y翻转坐标系统，而且内容的呈现也是上下翻转的，所以需要通过转换内容将其翻转
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    // CTFramesetter 是使用 Core Text 绘制时最重要的类。它管理您的字体引用和文本绘制帧。这里在 framesetter 之后通过一个所选的文本范围（这里我们选择整个文本）与需要绘制到的矩形路径创建一个帧。
    [self updateFramesetterIfNeeded];
    
    CTFrameRef frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_attString length]), path, NULL);
    CTFrameDraw(frame, context);	// CTFrameDraw 将 frame 描述到设备上下文
    
    // 画其他元素
    [self drawTextRunFrame:frame context:context];
}

#pragma mark - drawTextRun
- (void)drawTextRunFrame:(CTFrameRef)frame context:(CGContextRef)context
{
    // 获取每行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    NSMutableDictionary *runRectDictionary = [NSMutableDictionary dictionary];
    // 获取每行有多少run
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 获得每行的run
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            // run的属性字典
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            id<TYTextRunProtocol> textRun = [attributes objectForKey:kTYTextRunAttributedName];
            //CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
            
            if (textRun) {
                CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
                if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
                    [(id<TYDrawRunProtocol>)textRun drawRunWithRect:runRect];
                }
                
                [runRectDictionary setObject:textRun forKey:[NSValue valueWithCGRect:runRect]];
                
            }

        }
    }
    
    
    if (runRectDictionary.count > 0) {
        // 添加响应点击rect
        [self addRunRectDictionary:[runRectDictionary copy]];
    }
}

// 添加响应点击rect
- (void)addRunRectDictionary:(NSDictionary *)runRectDictionary
{
    if (runRectDictionary.count < _runRectDictionary.count) {
        NSMutableArray *drawRunArray = [[_runRectDictionary allValues]mutableCopy];
        // 剔除已经画出来的
        [drawRunArray removeObjectsInArray:[runRectDictionary allValues]];
        
        // 遍历不会画出来的
        for (id<TYTextRunProtocol>drawRun in drawRunArray) {
            if ([drawRun conformsToProtocol:@protocol(TYDrawRunProtocol)]
                && [drawRun respondsToSelector:@selector(didNotDrawRun)]) {
                [(id<TYDrawRunProtocol>)drawRun didNotDrawRun];
            }
        }
    }
    
    _runRectDictionary = runRectDictionary;
    [self addSingleTapGesture];
}

#pragma mark 添加点击手势
- (void)addSingleTapGesture
{
    if (_singleTap == nil) {
        self.userInteractionEnabled = YES;
        //单指单击
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        //手指数
        _singleTap.numberOfTouchesRequired = 1;
        //点击次数
        _singleTap.numberOfTapsRequired = 1;
        //增加事件者响应者，
        [self addGestureRecognizer:_singleTap];
    }
}

- (void)removeSingleTapGesture
{
    if (_singleTap) {
        [self removeGestureRecognizer:_singleTap];
        _singleTap = nil;
    }
}

#pragma mark 手指点击事件
- (void)singleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    
    __typeof (self) __weak weakSelf = self;
    // 遍历run位置字典
    [_runRectDictionary enumerateKeysAndObjectsUsingBlock:^(NSValue *keyRectValue, id<TYTextRunProtocol> obj, BOOL *stop) {
        
        CGRect imgRect = [keyRectValue CGRectValue];
        CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
        
        // point 是否在rect里
        if(CGRectContainsPoint(rect, point)){
            NSLog(@"点击了 run ");
            // 调用代理
            if ([_delegate respondsToSelector:@selector(attributedLabel:textRunClicked:)]) {
                [_delegate attributedLabel:weakSelf textRunClicked:obj];
                *stop = YES;
            }

        }
    }];
}

#pragma mark - 获得label最合适的高度 (请在设置text 字体和大小 行距等等 后在调用)
- (int)getHeightWithWidth:(CGFloat)width
{
    if (_attString == nil) {
        return 0;
    }
    
    // 是否需要更新frame
    [self updateFramesetterIfNeeded];
    
    // 获得建议的size
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width,MAXFLOAT), NULL);
    
    return ceilf(suggestedSize.height)+1;
}

- (void)setNeedFitToSize
{
    if (!_isFitToSize) {
        _isFitToSize = YES;
        [self sizeToFit];
        NSLog(@"view bounds %@",NSStringFromCGRect(self.bounds));
    }
}

- (void)sizeToFit
{
    [super sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = [self getHeightWithWidth:width];
    return CGSizeMake(width, height);
}

//- (void)adjustTextChangeSize
//{
//    CGFloat height = [self getHeightWithWidth:CGRectGetWidth(self.frame)];
//    
//    if (height != CGRectGetHeight(self.frame)) {
//        CGRect frame = self.frame;
//        frame.size.height = height;
//        [self setFrame:frame];
//    }
//}

#pragma mark 调用这个获得合适的Frame
- (void)setFrameWithOrign:(CGPoint)orign Width:(CGFloat)width
{
    // 获得高度
    int height = [self getHeightWithWidth:width];
    
    // 设置frame
    [self setFrame:CGRectMake(orign.x, orign.y, width, height)];
}

- (void)dealloc
{
    if (_framesetter != nil) {
        CFRelease(_framesetter);
    }
    _attString = nil;
}

@end

#pragma mark - append text textRun

@implementation TYAttributedLabel (AppendAttributedString)

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText = [self createTextAttibuteStringWithText:text];
    [self appendTextAttributedString:attributedText];
}

- (void)appendTextAttributedString:(NSAttributedString *)attributedText
{
    if (_attString == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }
    [_attString appendAttributedString:attributedText];
    [self resetFramesetter];
}

- (void)appendTextRun:(id<TYAppendTextRunProtocol>)textRun
{
    if (textRun) {
        if ([textRun conformsToProtocol:@protocol(TYDrawRunProtocol)]) {
            [(id<TYDrawRunProtocol>)textRun setTextFontAscent:_font.ascender descent:_font.descender];
        }
        if ([textRun conformsToProtocol:@protocol(TYDrawViewRunProtocol)]){
            [(id<TYDrawViewRunProtocol>)textRun setSuperView:self];
        }
        
        [self appendTextAttributedString:[textRun appendTextRunAttributedString]];
    }
}

@end
