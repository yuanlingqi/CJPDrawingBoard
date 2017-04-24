//
//  ShareViewController.m
//  CJPDrawingBoard
//
//  Created by lucky－ios on 2017/4/24.
//  Copyright © 2017年 com.chint. All rights reserved.
//

#import "ShareViewController.h"
#import "Masonry.h"
#import "DrawingBoardView.h"
#import "UShareHelper.h"
#import <QuickLook/QuickLook.h>
//#import "MyToolbar.h"

#define MARGIN 10
#define FONTSIZE 13

#define BUTTON_WIDTH 50
#define BUTTON_HEIGHT 30

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface ShareViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource,UITextViewDelegate>

/**
 编辑图片
 */
@property(nonatomic, strong)UIImageView *imgView;

/**
 画板
 */
@property(nonatomic, strong)DrawingBoardView *bgView;

@property(nonatomic, strong)UIImage *editImg;

/**
 底部工具栏
 */
@property(nonatomic, strong)UIView *bottomView;

/**
 文字工具栏
 */
@property(nonatomic, strong)MyToolbar *toolBar;

/**
 文字
 */
@property(nonatomic, strong)UITextView *textField;

/**
 文字编辑视图
 */
//@property(nonatomic, strong)UIView *textView;

/**
 可选按钮数组
 */
@property(nonatomic, strong)NSMutableArray *btnArray;

/**
 编辑框y坐标
 */
@property(nonatomic, assign)CGFloat oldHeight;

@end

@implementation ShareViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rightButtonForNav];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideToolView:) name:NOTI_HIDE_TOOLVIEW object:nil];
    //订阅键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.bgView];
    
    [self.view addSubview:self.textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(BUTTON_HEIGHT);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    [self.view addSubview:self.bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(MARGIN * 3 + BUTTON_HEIGHT * 3);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    UIButton *rectangleBtn = [self buttonWithTitle:@"矩形" tag:RECTANGLE selected:NO];
    [_bottomView addSubview:rectangleBtn];
    [rectangleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_bottomView.mas_top).offset(MARGIN);
        make.left.mas_equalTo(_bottomView.mas_left).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    UIButton *ovalBtn = [self buttonWithTitle:@"椭圆" tag:OVAL selected:NO];
    [_bottomView addSubview:ovalBtn];
    [ovalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(rectangleBtn.mas_top);
        make.left.mas_equalTo(rectangleBtn.mas_right).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    UIButton *arrowBtn = [self buttonWithTitle:@"箭头" tag:ARROW selected:NO];
    [_bottomView addSubview:arrowBtn];
    [arrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ovalBtn.mas_top);
        make.left.mas_equalTo(ovalBtn.mas_right).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    UIButton *penBtn = [self buttonWithTitle:@"画笔" tag:LINE selected:YES];
    [_bottomView addSubview:penBtn];
    [penBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(arrowBtn.mas_top);
        make.left.mas_equalTo(arrowBtn.mas_right).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    UIButton *wordBtn = [self buttonWithTitle:@"文字" tag:WORD selected:NO];
    [_bottomView addSubview:wordBtn];
    [wordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(penBtn.mas_top);
        make.left.mas_equalTo(penBtn.mas_right).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    UIButton *clearBtn = [self buttonWithTitle:@"清除" tag:CLEAR selected:NO];
    [_bottomView addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(arrowBtn.mas_bottom).offset(MARGIN);
        make.left.mas_equalTo(_bottomView.mas_left).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    UIButton *unDoBtn = [self buttonWithTitle:@"回撤" tag:UNDO selected:NO];
    [_bottomView addSubview:unDoBtn];
    [unDoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(clearBtn.mas_top);
        make.left.mas_equalTo(clearBtn.mas_right).offset(MARGIN);
        make.width.mas_equalTo(BUTTON_WIDTH);
        make.height.mas_equalTo(BUTTON_HEIGHT);
    }];
    
    [self.btnArray addObjectsFromArray:@[rectangleBtn, ovalBtn, arrowBtn, penBtn, wordBtn]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Custom Methods

- (void)keyboardWillChangeFrame:(NSNotification *)noti{
    NSLog(@"%@",noti.userInfo);
    //取得动画的持续时间
    CGFloat duration = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect endFrame = [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat ty = endFrame.origin.y - [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        _textField.transform = CGAffineTransformMakeTranslation(0, ty);
    }];
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag selected:(BOOL)selected{
    UIButton *btn = [UIButton new];
    btn.tag = tag;
    btn.layer.cornerRadius = 15;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.titleLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    btn.selected = selected;
    return btn;
}

- (void)rightButtonForNav{
    //设置分享按钮
    UIButton *backBtn = [UIButton new];
    [backBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setTitle:@"完成" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [backBtn addTarget:self action:@selector(shareTo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)shareTo{
    NSLog(@"%s, %@", __FUNCTION__, @"shareTo");
    
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    
    // 获取当前上下文->位图上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //渲染
    [_bgView.layer renderInContext:ctx];
    
    //获取图片
    _editImg = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    //友盟分享
    [UShareHelper shareWithUI:_editImg controller:self];
    
    //文档本地共享
//    [self saveImageToSandBox];
//    QLPreviewController *previewController = [[QLPreviewController alloc] init];
//    previewController.dataSource = self;
//    previewController.delegate = self;
//
//    // start previewing the document at the current section index
//    previewController.currentPreviewItemIndex = 0;
//    [[self navigationController] pushViewController:previewController animated:YES];
}

-(void)saveImageToSandBox{
    
    //拼接文件绝对路径
    NSString *path = [self documentPath:@"editImg.png"];
    NSLog(@"%@",path);
    NSData *imageData = UIImagePNGRepresentation(_editImg);
    //保存
    [imageData writeToFile:path atomically:YES];
}

- (NSString *)documentsPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/**
 获取文件路径
 
 @param filename 文件名
 @return 全路径
 */
- (NSString *) documentPath:(NSString *)filename {
    NSString *documentsPath = [self documentsPath];
    return [documentsPath stringByAppendingPathComponent:filename];
}

- (void)btnClick:(UIButton*)sender{
    if (sender.tag == CLEAR) {
        [_bgView clearScreen];
    }else if(sender.tag == UNDO){
        [_bgView undo];
    }else {
        [sender setSelected:!sender.isSelected];
        
        //发送通知
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_SELECTED_TAG object:@{@"tag":@(sender.tag), @"selected":@(sender.isSelected)}];
        
        //切换状态
        sender.isSelected ?[self disableBtnsExceptTag:sender.tag] : nil;
    }
}

/**
 设置按钮状态
 
 @param tag <#tag description#>
 */
- (void)disableBtnsExceptTag:(NSInteger)tag{
    for (UIButton *btn in _btnArray) {
        btn.tag != tag ? [btn setSelected:NO] : nil;
    }
}

/**
 掩藏工具栏
 
 @param noti <#noti description#>
 */
- (void)hideToolView:(NSNotification *)noti{
    NSDictionary *dic = noti.object;
    _bottomView.hidden = [dic[@"hide"] boolValue];
    if (dic[@"editing"]) {
        //显示文字编辑视图
        _textField.hidden = NO;
        [_textField becomeFirstResponder];
    }
}

/**
 点击取消或确定
 
 @param sender <#sender description#>
 */
- (void)doneClick:(UIBarButtonItem *)sender{
    if (sender.tag == FINISH){
        //发送通知
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_SELECTED_TAG object:@{@"tag":@(sender.tag), @"text": _textField.text}];
        
        _textField.text = @"";
        [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(BUTTON_HEIGHT);
        }];
    }
    [_textField resignFirstResponder];
    _bottomView.hidden = NO;
    _textField.hidden = YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    CGFloat oldHeight = textView.frame.size.height;
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    CGSize size =  CGSizeMake(textView.frame.size.width - textView.textContainerInset.right - textView.textContainerInset.left - 10, CGFLOAT_MAX);
    CGRect newSize = [newText boundingRectWithSize:size
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:textView.font}
                                           context:nil];
    
    
    CGFloat heightChange = newSize.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom + 2.719 - oldHeight;
    
    [textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textView.frame.size.height + heightChange);
    }];
    
    return YES;
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSString *path = [self documentPath:@"editImg.png"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSLog(@"%@",fileURL);
    return fileURL;
}

#pragma mark - Getter

- (DrawingBoardView *)bgView{
    if (_bgView == nil) {
        _bgView = [[DrawingBoardView alloc]initWithFrame:self.view.bounds];
        _bgView.bgImage = self.shareImg;
        _bgView.selectedTag = LINE;
    }
    return _bgView;
}

- (UIImageView *)imgView{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [_imgView setImage:self.shareImg];
    }
    return _imgView;
}

- (UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [UIColor blackColor];
        _bottomView.alpha = .5;
    }
    return _bottomView;
}

- (NSMutableArray *)btnArray{
    if (_btnArray == nil) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (MyToolbar *)toolBar{
    if (_toolBar == nil) {
        _toolBar = [[MyToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        
        _toolBar.backgroundColor = RGBCOLOR(22, 50, 72);
        
        UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick:)];
        btn.tag = CANCEL;
        [btn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [btn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick:)];
        btn2.tag = FINISH;
        [btn2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        
        _toolBar.items = @[btn, [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           btn2];
        [_toolBar sizeToFit];
    }
    return _toolBar;
}

- (UITextView *)textField{
    if (_textField == nil) {
        _textField = [UITextView new];
        _textField.font = [UIFont systemFontOfSize:13];
        _textField.textColor = [UIColor whiteColor];
        
        _textField.inputAccessoryView = self.toolBar;
        _textField.backgroundColor = [UIColor blackColor];
        _textField.alpha = .5;
        _textField.hidden = YES;
        _textField.editable = YES;
        _textField.delegate = self;
    }
    return _textField;
}

@end

@implementation MyToolbar
- (void)drawRect:(CGRect)rect {
}
@end
