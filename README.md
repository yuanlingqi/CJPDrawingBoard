# CJPDrawingBoard 1.0
一个简单易用的涂鸦功能包；

提供截屏，涂鸦，画箭头，文字，矩形和椭圆功能；

集成了友盟分享；

提供分享图片到本地应用功能；

纯CAShapeLayer实现，编辑涂鸦流畅，内存占用少；

## Demo Code
ShareViewController *svc = [ShareViewController new];
<br>svc.shareImg = [self screenshot];
<br>svc.title = @"编辑";
<br>[self.navigationController pushViewController:svc animated:YES];

## CocoaPods
暂不支持

## ScreenShot
![image](https://github.com/yuanlingqi/CJPDrawingBoard/blob/master/demo.gif)

## Requirements
* Xcode 8.3.2 or higher
* Apple LLVM compiler
* iOS 8.0 or higher
* ARC

## Contact
如果你发现bug，please pull reqeust me 
如果你有更好的改进，please pull reqeust me 
