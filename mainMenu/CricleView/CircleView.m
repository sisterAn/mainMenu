//
//  CircleView.m
//  CircleProject
//
//  Created by zbq on 13-10-31.
//  Copyright (c) 2013年 zbq. All rights reserved.
//

#import "CircleView.h"
#import "Masonry.h"
#define CenterImageWidth 80 * kScale
#define CenterImageHeight 80 * kScale
#define kScale [UIScreen mainScreen].bounds.size.width/375.0f
@interface CircleView ()
// 背景图片
@property (nonatomic,strong)UIImageView *bgImageView;
@property (nonatomic,assign)CGFloat bgRotate;
@property (nonatomic,assign)CGFloat backRotate;
@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong)DragImageView *ImgView;
- (void)showImage;
- (CGFloat)getRadinaByRadian:(CGFloat)radian;
- (void)addGesture;
- (void)handleSinglePan:(id)sender;
- (void)dragPoint:(CGPoint)dragPoint movePoint:(CGPoint)movePoint centerPoint:(CGPoint)centerPoint;
- (void)reviseCirclePoint;
- (void)animateWithDuration:(CGFloat)time animateDelay:(CGFloat)delay changeIndex:(NSInteger)change_index toIndex:(NSInteger)to_index circleArray:(NSMutableArray *)array clockwise:(BOOL)is_clockwise;
@end

@implementation CircleView

@synthesize arrImages;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
    }
    return self;
}

- (void)loadView{
    if (arrImages.count > 0) {
        [self addGesture];
        [self showImage];
    }else{
        return;
    }
}

/*
显示圆环
显示方式是确定圆心正下方的点，然后逆时针绘制点
 */
- (void)showImage{
//    self.backgroundColor = [UIColor grayColor];
    _bgImageView = [[UIImageView alloc ]initWithFrame:self.bounds];
    _bgImageView.image = [UIImage imageNamed:@"转盘"];
    [self addSubview:_bgImageView];
     __weak typeof (self) weakSelf = self;
    [self addSubview:_centerImgView];
    [_centerImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf);
        make.width.mas_equalTo(CenterImageWidth);
        make.height.mas_equalTo(CenterImageHeight);
    }];
    CGFloat fRadina;//与y轴的夹角
    average_radina = 2*M_PI/arrImages.count;
    DragImageView *dragImageView = [arrImages objectAtIndex:0];
    CGFloat width = dragImageView.frame.size.width;
    CGFloat heigh = dragImageView.frame.size.height;
    //计算半径
    radius = MIN(self.frame.size.width-width, self.frame.size.height-heigh)/2.0 - 10 * kScale;
    for (int i=0; i<arrImages.count; i++) {
        fRadina = [self getRadinaByRadian:i*average_radina]-0.3;
        CGPoint point = [self getPointByRadian:fRadina centreOfCircle:center radiusOfCircle:radius];
        DragImageView *imageview = [arrImages objectAtIndex:i];
        imageview.center = point;
        imageview.current_radian = fRadina;
        imageview.radian = fRadina;
        imageview.view_point = point;
        imageview.current_animation_radian = [self getAnimationRadianByRadian:fRadina];
        imageview.animation_radian = [self getAnimationRadianByRadian:fRadina];
        [self addSubview:imageview];
        
    }
    
}

//计算线与y轴的夹角,确保在0～2*M_PI之间
- (CGFloat)getRadinaByRadian:(CGFloat)radian
{
    if(radian > 2 * M_PI)//floorf表示不大于该数的最大整数
        return (radian - floorf(radian / (2.0f * M_PI)) * 2.0f * M_PI);
    
    if(radian < 0.0f)//ceilf表示不小于于该数的最小整数
        return (2.0f * M_PI + radian - ceilf(radian / (2.0f * M_PI)) * 2.0f * M_PI);
    
    return radian;
}

//根据夹角（与y轴），中心点，半径就出点坐标
- (CGPoint)getPointByRadian:(CGFloat)radian centreOfCircle:(CGPoint)circle_point radiusOfCircle:(CGFloat)circle_radius
{
    CGFloat c_x = sinf(radian) * circle_radius + circle_point.x;
    CGFloat c_y = cosf(radian) * circle_radius + circle_point.y;
    
    return CGPointMake(c_x, c_y);
}

//根据和y轴的夹角换算成与x轴的夹角用于拖动后旋转
- (CGFloat)getAnimationRadianByRadian:(CGFloat)radian
{
    
    CGFloat an_r = 2.0f * M_PI -  radian + M_PI_2;
    
    if(an_r < 0.0f)
        an_r =  - an_r;
    
    return an_r;
}

/*
 添加手势
 */
- (void)addGesture{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePan:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
}

//手势操作
- (void)handleSinglePan:(id)sender{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)sender;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            pointDrag = [panGesture locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint pointMove = [panGesture locationInView:self];
            [self dragPoint:pointDrag movePoint:pointMove centerPoint:center];
            pointDrag = pointMove;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint pointMove = [panGesture locationInView:self];
//            [self dragPoint:pointDrag movePoint:pointMove centerPoint:center];
//            [self reviseCirclePoint];
            [self changeBack:pointMove];
        }
            break;
        case UIGestureRecognizerStateFailed:
        {
            CGPoint pointMove = [panGesture locationInView:self];
            [self dragPoint:pointDrag movePoint:pointMove centerPoint:center];
            [self reviseCirclePoint];
        }
            break;
            
        default:
            break;
    }
}

-(void)changeBack:(CGPoint)point {
    _ImgView.image = [UIImage imageNamed:_ImgView.imgName];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *fitView = [super hitTest:point withEvent:event];
    NSLog(@"%@",fitView);
    if ([fitView isKindOfClass:[DragImageView class]]) {
        _ImgView = (DragImageView *)fitView;
        _ImgView.image = [UIImage imageNamed:_ImgView.selectImgName];
    }
    return fitView;
}
//随着拖动改变子view位置，子view与y轴的夹角，子view与x轴的夹角
- (void)dragPoint:(CGPoint)dragPoint movePoint:(CGPoint)movePoint centerPoint:(CGPoint)centerPoint{
    CGFloat drag_radian   = [self schAtan2f:dragPoint.x - centerPoint.x theB:dragPoint.y - centerPoint.y];
    
    CGFloat move_radian   = [self schAtan2f:movePoint.x - centerPoint.x theB:movePoint.y - centerPoint.y];
    
    CGFloat change_radian = (move_radian - drag_radian);
    for (int i=0; i<arrImages.count; i++) {
        DragImageView *imageview = [arrImages objectAtIndex:i];
        imageview.center = [self getPointByRadian:(imageview.current_radian+change_radian) centreOfCircle:center radiusOfCircle:radius];
        imageview.current_radian = [self getRadinaByRadian:imageview.current_radian + change_radian];;
        imageview.current_animation_radian = [self getAnimationRadianByRadian:imageview.current_radian];
    }
    //对UIImageView的旋转
    //按Z轴旋转
    CABasicAnimation *FlipAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    FlipAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //旋转按弧度M_PI
    FlipAnimation.fromValue = [NSNumber numberWithFloat:-_bgRotate];
    FlipAnimation.toValue= [NSNumber numberWithFloat:-(_bgRotate + change_radian)];
    FlipAnimation.duration=0;
    //旋转后保持状态
    FlipAnimation.fillMode=kCAFillModeForwards;
    FlipAnimation.removedOnCompletion = NO;
    [_bgImageView.layer addAnimation:FlipAnimation forKey:@"flip"];
    _bgRotate += change_radian;
//    NSLog(@"%lf",move_radian);
}

//计算schAtan值
- (CGFloat)schAtan2f:(CGFloat)a theB:(CGFloat)b
{
    CGFloat rd = atan2f(a,b);
    
    if(rd < 0.0f)
        rd = M_PI * 2 + rd;
    
    return rd;
}

//旋转结束后滑动到指定位置
- (void)reviseCirclePoint{
    BOOL isClockwise;
    DragImageView *imageviewFirst = [arrImages objectAtIndex:0];
    CGFloat temp_value = [self getRadinaByRadian:imageviewFirst.current_radian]/average_radina;
    NSInteger iCurrent = (NSInteger)(floorf(temp_value));
    temp_value = temp_value - floorf(temp_value);
    
    step = iCurrent;
    if (temp_value > 0.5f) {//超过半个弧度
        isClockwise = NO;
        step ++;
    }else{
        isClockwise = YES;
    }
    
    for (int i=0; i<arrImages.count; i++) {
        NSInteger iDest = i+step;
        if (iDest >= arrImages.count) {
            iDest = iDest%arrImages.count;
        }
        [self animateWithDuration:0.25f * (temp_value/average_radina)  animateDelay:0.0f changeIndex:i toIndex:iDest circleArray:arrImages clockwise:isClockwise];
    }
    NSLog(@"%ld %lf, ",(long)step,temp_value);
    //按Z轴旋转
    CABasicAnimation *FlipAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    FlipAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //旋转按弧度M_PI
    FlipAnimation.fromValue = [NSNumber numberWithFloat:-_bgRotate ];
    FlipAnimation.toValue= [NSNumber numberWithFloat:-_backRotate - _bgRotate];
    FlipAnimation.duration=0;
    //旋转后保持状态
    FlipAnimation.fillMode=kCAFillModeForwards;
    FlipAnimation.removedOnCompletion = NO;
    [_bgImageView.layer addAnimation:FlipAnimation forKey:@"flip"];
    _bgRotate = _backRotate + _bgRotate;
}

//平衡动画
- (void)animateWithDuration:(CGFloat)time animateDelay:(CGFloat)delay changeIndex:(NSInteger)change_index toIndex:(NSInteger)to_index circleArray:(NSMutableArray *)array clockwise:(BOOL)is_clockwise{
    DragImageView *change_cell = [array objectAtIndex:change_index];
    DragImageView *to_cell     = [array objectAtIndex:to_index];
    
    /*圆*/
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:[NSString stringWithFormat:@"position"]];
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,change_cell.layer.position.x,change_cell.layer.position.y);
    
    int clockwise = is_clockwise?0:1;
    
	CGPathAddArc(path,nil,
                 center.x, center.y, /*圆心*/
                 radius,                          /*半径*/
                 change_cell.current_animation_radian, to_cell.animation_radian, /*弧度改变*/
                 clockwise
                 );
    NSLog(@",,%lf,,%lf",change_cell.current_animation_radian,to_cell.animation_radian);
    _backRotate = (change_cell.current_animation_radian - to_cell.animation_radian > 5 || to_cell.animation_radian - change_cell.current_animation_radian > 5) ? _backRotate : change_cell.current_animation_radian - to_cell.animation_radian;
	animation.path = path;
	CGPathRelease(path);
    animation.fillMode            = kCAFillModeForwards;
	animation.repeatCount         = 1;
    animation.removedOnCompletion = NO;
 	animation.calculationMode     = @"paced";
    
    /*动画组合*/
    CAAnimationGroup *anim_group  = [CAAnimationGroup animation];
    anim_group.animations          = [NSArray arrayWithObjects:animation, nil];
    anim_group.duration            = time + delay;
    anim_group.delegate            = self;
    anim_group.fillMode            = kCAFillModeForwards;
    anim_group.removedOnCompletion = NO;
    
    [change_cell.layer addAnimation:anim_group forKey:[NSString stringWithFormat:@"anim_group_%d",change_index]];
    
    /*改变属性*/
    change_cell.current_animation_radian = to_cell.animation_radian;
    change_cell.current_radian           = to_cell.radian;
}

#pragma mark -
#pragma mark - animation delegate

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    for (int i = 0; i < arrImages.count; ++i)
    {
        NSInteger iDest = i+step;
        if (iDest >= arrImages.count) {
            iDest = iDest%arrImages.count;
        }
        DragImageView *change_cell = [arrImages objectAtIndex:i];
        
        DragImageView *to_cell     = [arrImages objectAtIndex:iDest];
        
        [change_cell.layer removeAllAnimations];
        
        change_cell.center    = to_cell.view_point;
    }
}



@end
