//
//  ViewController.m
//  CJPDrawingBoard
//
//  Created by lucky－ios on 2017/4/24.
//  Copyright © 2017年 com.chint. All rights reserved.
//

#import "ShareViewController.h"

@interface ViewController : UIViewController

@property(nonatomic, strong)UIImageView *imgView;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imgView];
    [self buttonForRight];
}

#pragma mark - Custom Methods

- (void)buttonForRight{
    //设置分享按钮
    UIButton *backBtn = [UIButton new];
    [backBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setTitle:@"截屏" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [backBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)share{
    ShareViewController *svc = [ShareViewController new];
    svc.shareImg = [self screenshot];
    svc.title = @"编辑";
    [self.navigationController pushViewController:svc animated:YES];
}

- (UIImage *)screenshot
{
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    
    // 获取当前上下文->位图上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 拼接路径(view上面的内容添加上下文)
    // view的图层 渲染到上下文
    // 图层只能渲染,不能绘制
    [self.view.layer renderInContext:ctx];
    
    // 获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Getter

- (UIImageView *)imgView{
    if (_imgView == nil) {
        
        _imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [_imgView setImage:[UIImage imageNamed:@"bgImage"]];
    }
    return _imgView;
}

@end
