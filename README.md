# TYAttributedLabel
TYAttributedLabel 简单易用的属性文本的控件(无需了解CoreText)，支持富文本，图文混排显示，支持添加链接，image和UIView控件，支持自定义排版显示，

## ScreenShot

![image](https://raw.githubusercontent.com/12207480/TYAttributedLabel/master/screenshot/TYAtrributedLabelDemo.gif)

weibo demo 使用TYAttributedLabel 截图

![image](https://raw.githubusercontent.com/12207480/TYAttributedLabel/master/screenshot/weibo.gif)
## Requirements
* Xcode 5 or higher
* Apple LLVM compiler
* iOS 6.0 or higher
* ARC

## Features
* 支持富文本，图文混排显示，支持行间距 字间距，设置行数，自适应高度
* 支持添加高度自定义文本属性 
* 支持添加属性文本，自定义链接，新增高亮效果显示（文字和背景）
* 支持添加UIImage和UIView控件

## Update
   
v1.1  添加链接高亮效果，链接便利方法，长按手势代理，优化代码<br>
v1.2  添加设置行数，修复bug，增强稳定性

## Demo
运行demo可以查看效果，而且在demo中有详细的例子，针对各种文本和图文的实现，这里简单的介绍下用法
 
## Usage
### API Quickstart

* **Category And Protocol**

|Class | Function|
|--------|---------|
|NSMutableAttributedString (TY) |category提供便利color,font CharacterSpacing,UnderlineStyle,ParagraphStyle的属性添加，无需了解复杂的CoreText|
|TYTextStorageProtocol|自定义文本属性 遵守最基本的协议 即可 addTextStorage 添加进去|
|TYAppendTextStorageProtocol|自定义文本属性协议 遵守即可appendTextStorage 添加进去|
|TYDrawStorageProtocol|自定义显示内容协议 如 UIImage UIView|

下层协议继承上层的协议，如果觉得复杂，其实我已经实现了常用的自定义属性，拿来就可以用，或者继承，添加你想要的

* **Label And Storage**

|Class |Function |
|--------|---------|
|TYAttributedLabel|简单易用的属性文本,富文本的显示控件,<br>addTextStorage在已经设置文本的基础上添加属性，image或者view,<br>appendTextStorage(无需事先设置文本)直接添加属性，image或者view到最后|
|TYTextStorage|自定义文本属性,支持textColor,font,underLineStyle|
|TYLinkTextStorage|自定义链接属性，继承TYTextStorage，支持点击代理|
|TYDrawStorage|自定义显示内容属性，如UIImage，UIView，支持点击代理|
|TYImageStorage|自定义图片显示，继承TYDrawStorage|
|TYViewStorage|自定义UIView控件，继承TYDrawStorage|

如果需要更加详细的内容，请看各个头文件，有详细的注释

### Delegate

``` objective-c

// 点击代理
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point;

// 长按代理 有多个状态 begin, changes, end 都会调用,所以需要判断状态
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageLongPressed:(id<TYTextStorageProtocol>)textStorage onState:(UIGestureRecognizerState)state atPoint:(CGPoint)point;

```

### Examples

* **appendStorage demo**
 
``` objective-c

TYAttributedLabel *label = [[TYAttributedLabel alloc]init];
[self.view addSubview:label];

// 文字间隙
label.characterSpacing = 2;
// 文本行间隙
label.linesSpacing = 6;

NSString *text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n";
[label appendText:text];

NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
[attributedString addAttributeTextColor:[UIColor blueColor]];
[attributedString addAttributeFont:[UIFont systemFontOfSize:15]];
[label appendTextAttributedString:attributedString];

[label appendImageWithName:@"CYLoLi" size:CGSizeMake(CGRectGetWidth(label.frame), 180)];

UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CYLoLi"]];
imageView.frame = CGRectMake(0, 0, CGRectGetWidth(label.frame), 180);
[label appendView:imageView];

[label setFrameWithOrign:CGPointMake(0,0） Width:CGRectGetWidth(self.view.frame)];

```
* **addStorage demo**

``` objective-c

TYAttributedLabel *label = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
[self.view addSubview:label];

NSString *text = @"\t总有一天你将破蛹而出，成长得比人们期待的还要美丽。\n";
[label setText:text];

// 文字间隙
label.characterSpacing = 2;
// 文本行间隙
label.linesSpacing = 6;

textStorage = [[TYTextStorage alloc]init];
textStorage.range = [text rangeOfString:@"总有一天你将破蛹而出"]; 
textStorage.textColor = RGB(0, 155, 0, 1);
textStorage.font = [UIFont systemFontOfSize:18];
[label addTextStorage:textStorage];

[label addLinkWithLinkData:@"www.baidu.com" range:NSMakeRange(5, 8)];

[label addImageWithName:@"haha" range:NSMakeRange(2, 1)];

UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CYLoLi"]];
imageView.frame = CGRectMake(0, 0, CGRectGetWidth(label.frame), 180);
[label addView:imageView range:NSMakeRange(16, 1)];

[label sizeToFit];

```

### Contact
如果你发现bug，please pull reqeust me <br>
如果你有更好的想法或者建议可以联系我，Email:122074809@qq.com















 
 
 
 
 
 
 
 
