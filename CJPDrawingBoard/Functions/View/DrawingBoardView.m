//
//  DrawingBoardView.m
//  CJPDrawingBoard
//
//  Created by lucky－ios on 2017/4/24.
//  Copyright © 2017年 com.chint. All rights reserved.
//

#import "DrawingBoardView.h"

#define HEAD_LENGTH 100
#define HEAD_WIDTH 30
#define TAIL_WIDTH 8

#define LINE_WIDTH 3
#define FONT_SIZE 15

#define LAYERS @"layers"
#define REMOVED_LAYERS @"removedLayers"

@interface DrawingBoardView()

/**
 当前贝塞尔路径
 */
@property(nonatomic, strong)UIBezierPath *curBeizerPath;

/**
 当前起始触摸点
 */
@property(nonatomic, assign)CGPoint curP;

/**
 当前编辑图层
 */
@property (nonatomic, strong)CAShapeLayer * slayer;

@end

@implementation DrawingBoardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(excuteCommand:) name:NOTI_SELECTED_TAG object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [_bgImage drawAtPoint:CGPointZero];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Custom Methods

/**
 接收点击菜单按钮的通知，执行功能
 
 @param noti 通知内容
 */
- (void)excuteCommand:(NSNotification *)noti{
    
    NSDictionary *dic = noti.object;
    
    if ([dic[@"selected"] boolValue]) {
        _selectedTag = [dic[@"tag"] integerValue];
    }else{
        if (_selectedTag == [dic[@"tag"] integerValue]) {
            _selectedTag = 0;
        }else{
            //若是文字编辑完成则插入文字
            if (_selectedTag == WORD && FINISH == [dic[@"tag"] integerValue]) {
                NSString *text = dic[@"text"];
                
                CGSize textSize = [self sizeOfText:text];
                _curP.x + textSize.width > SCREEN_WIDTH ? _curP.x = SCREEN_WIDTH - textSize.width : _curP.x;
                
                CATextLayer *textLayer = [CATextLayer layer];
                textLayer.frame = CGRectMake(_curP.x, _curP.y, textSize.width, textSize.height);
                
                textLayer.fontSize = FONT_SIZE;
                textLayer.foregroundColor = [UIColor redColor].CGColor;
                
                textLayer.alignmentMode = kCAAlignmentCenter;
                textLayer.string = dic[@"text"];
                textLayer.contentsScale = 2.0f;
                textLayer.wrapped = YES;
                [self.layer addSublayer:textLayer];
                
                _slayer = (CAShapeLayer *)textLayer;
                [self.layer addSublayer:_slayer];
                [[self mutableArrayValueForKey:REMOVED_LAYERS] removeAllObjects];
                [[self mutableArrayValueForKey:LAYERS] addObject:_slayer];
                
                //接收文字编辑命令
            }else if(WORD == [dic[@"tag"] integerValue]){
                _selectedTag = WORD;
            }
        }
    }
}

/**
 计算文字显示区域
 
 @param text 文字
 @return 区域
 */
- (CGSize)sizeOfText:(NSString *)text{
    CGSize textSize = [text sizeOfMaxSize:CGSizeMake(150, MAXFLOAT) font:[UIFont systemFontOfSize:FONT_SIZE]];
    textSize.height += 50;
    return textSize;
}

/**
 清屏
 */
- (void)clearScreen
{
    if (!self.layers.count) return ;
    [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[self mutableArrayValueForKey:LAYERS] removeAllObjects];
    [[self mutableArrayValueForKey:REMOVED_LAYERS] removeAllObjects];
}

/**
 撤销
 */
- (void)undo
{
    if (!self.layers.count) return;
    [[self mutableArrayValueForKey:REMOVED_LAYERS] addObject:self.layers.lastObject];
    [self.layers.lastObject removeFromSuperlayer];
    [[self mutableArrayValueForKey:LAYERS] removeLastObject];
}

/**
 恢复
 */
- (void)redo
{
    if (!self.removedLayers.count) return;
    [[self mutableArrayValueForKey:LAYERS] addObject:self.removedLayers.lastObject];
    [[self mutableArrayValueForKey:REMOVED_LAYERS] removeLastObject];
    [self.layer addSublayer:self.layers.lastObject];
}

/**
 计算两点间距离

 @param startPoint 起点
 @param endPoint 终点
 @return 距离
 */
- (double)distanceFromPoints:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    double dx = (endPoint.x -startPoint.x);
    double dy = (endPoint.y - startPoint.y);
    return sqrt(dx*dx + dy*dy);
}

#pragma mark 根据touches集合获取触摸点

- (CGPoint)pointWithTouches:(NSSet *)touches
{
    // 获取touch对象
    UITouch *touch = [touches anyObject];
    // 获取当前触摸点
    return  [touch locationInView:self];
}

#pragma mark 开始点击画板:记录起点

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //掩藏工具栏
    _selectedTag == 0 ? nil : [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_HIDE_TOOLVIEW object:@{@"hide" : @YES}];
    
    // 获取当前触摸点
    _curP = [self pointWithTouches:touches];
    
    if (_selectedTag == LINE) {
        
        // 创建路径
        // 自定义路径的目的:让每条路径保存颜色,系统贝瑟尔路径不好用,不能保存颜色
        UIBezierPath *path = [UIBezierPath pathWitchColor:_color lineWidth:LINE_WIDTH];
        [path moveToPoint:_curP];
        _curBeizerPath = path;
        
    }else if(_selectedTag == ARROW){
        _curBeizerPath = [UIBezierPath arrow:_curP toEnd:_curP tailWidth:0 headWidth:0 headLength:0];
    }else if(_selectedTag == RECTANGLE){
        _curBeizerPath = [UIBezierPath bezierPathWithRect:CGRectMake(_curP.x, _curP.y, 0, 0)];
    }else if(_selectedTag == OVAL){
        _curBeizerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_curP.x, _curP.y, 0, 0)];
    }
    
    if (_selectedTag > 0 && _selectedTag != WORD) {
        
        CAShapeLayer * slayer = [CAShapeLayer layer];
        _curBeizerPath.lineWidth = LINE_WIDTH;
        slayer.path = _curBeizerPath.CGPath;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        if (_selectedTag == LINE || _selectedTag == RECTANGLE || _selectedTag == OVAL) {
            slayer.strokeColor = [UIColor redColor].CGColor;
            slayer.fillColor = [UIColor clearColor].CGColor;
        }else if(_selectedTag == ARROW){
            slayer.fillColor = [UIColor redColor].CGColor;
        }
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.lineWidth = _curBeizerPath.lineWidth;
        [self.layer addSublayer:slayer];
        _slayer = slayer;
        [[self mutableArrayValueForKey:REMOVED_LAYERS] removeAllObjects];
        [[self mutableArrayValueForKey:LAYERS] addObject:_slayer];
    }
}

#pragma mark touchesMoved

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 获取当前触摸点
    CGPoint curP = [self pointWithTouches:touches];
    if (CGPointEqualToPoint(_curP, curP)) {
        return;
    }
    //计算缩放倍率
    double distance = [self distanceFromPoints:_curP endPoint:curP];
    double rate = distance / [UIScreen mainScreen].bounds.size.width;
    
    if (_selectedTag == LINE) {
        [_curBeizerPath addLineToPoint:curP];
    }else if(_selectedTag == ARROW){
        [self.layers removeObject:_curBeizerPath];
        _curBeizerPath = [UIBezierPath arrow:_curP toEnd:curP tailWidth:TAIL_WIDTH *rate headWidth:HEAD_WIDTH * rate headLength:HEAD_LENGTH * rate];
    }else if(_selectedTag == RECTANGLE){
        [self.layers removeObject:_curBeizerPath];
        _curBeizerPath = [UIBezierPath bezierPathWithRect:CGRectMake(_curP.x, _curP.y, curP.x - _curP.x, curP.y - _curP.y)];
    }else if(_selectedTag == OVAL){
        [self.layers removeObject:_curBeizerPath];
        _curBeizerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_curP.x, _curP.y, curP.x - _curP.x, curP.y - _curP.y)];
    }
    
    if (_selectedTag > 0 && _selectedTag != WORD) {
        
        _slayer.path = _curBeizerPath.CGPath;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_selectedTag == WORD) {
        //喊出编辑键盘
        _curP = [self pointWithTouches:touches];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_HIDE_TOOLVIEW object:@{@"editing" : @YES, @"hide" : @YES}];
    }else if(_selectedTag > 0){
        //显现工具栏
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_HIDE_TOOLVIEW object:@{@"hide" : @NO}];
    }
}

#pragma mark - Getter

- (NSMutableArray *)layers
{
    if (_layers == nil) {
        _layers = [NSMutableArray array];
    }
    
    return _layers;
}

- (NSMutableArray *)removedLayers{
    if (_removedLayers == nil) {
        _removedLayers = [NSMutableArray array];
    }
    return _removedLayers;
}

#pragma mark - Setter

- (void)setBgImage:(UIImage *)bgImage{
    _bgImage = bgImage;
    _color = [UIColor redColor];
    [self setNeedsDisplay];
}

@end
