//
//  ViewController.m
//  mainMenu
//
//  Created by user on 16/12/12.
//  Copyright © 2016年 user. All rights reserved.
//

#import "ViewController.h"
// 罗盘上图标
#import "DragImageView.h"
// 旋转罗盘
#import "CircleView.h"
// 宏定义
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
// 图标大小
#define kScale [UIScreen mainScreen].bounds.size.width/375.0f
#define ImageWidth 50 * kScale
#define ImageHeight 50 * kScale
// 转盘frame
#define ScrollFrame CGRectMake(SCREEN_WIDTH - 151 * kScale, SCREEN_HEIGHT - 151 * kScale - 64 , 218 * kScale , 218 * kScale)
// 图标tag
#define BASE_IMAGEVIEW_TAG 1000
#define CENTER_IMAGEVIEW_TAG 1100
@interface ViewController (){
    // 转盘
    DragImageView *imageviewCharitiesOne;
    DragImageView *imageviewPressOne;
    DragImageView *imageviewDetailOne;
    DragImageView *imageviewCharitiesTwo;
    DragImageView *imageviewPressTwo;
    DragImageView *imageviewDetailTwo;
    UIImageView *imageviewCenterQuick;
    // 按钮
    NSMutableArray *arrImage;
    // 中心点
    CGPoint pointCenter;
    //半径
    CGFloat fRadius;
    //平均角度
    CGFloat fAvarage_Radina;
    CGPoint pointDrag;
    NSInteger iCurrentIndex;
    NSInteger iStep;
}
- (void)initDragImageView;
- (void)showImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 添加转盘
    [self addCircleView];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark 添加转盘
- (void)addCircleView {
    [self initDragImageView];
    [self showImage];
}
- (void)initDragImageView{
    // 添加转盘上图标1
    imageviewCharitiesOne = [[DragImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    imageviewCharitiesOne.image = [UIImage imageNamed:@"首页公益"];
    imageviewCharitiesOne.imgName = @"首页公益";
    imageviewCharitiesOne.selectImgName = @"首页公益点击";
    // 添加转盘上图标2
    imageviewPressOne = [[DragImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    imageviewPressOne.image = [UIImage imageNamed:@"首页发布"];
    imageviewPressOne.imgName = @"首页发布";
    imageviewPressOne.selectImgName = @"首页发布点击";
    // 添加转盘上图标3
    imageviewDetailOne = [[DragImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    imageviewDetailOne.image = [UIImage imageNamed:@"首页委托"];
    imageviewDetailOne.imgName = @"首页委托";
    imageviewDetailOne.selectImgName = @"首页委托点击";
    
    // 添加转盘上图标4
    imageviewCharitiesTwo = [[DragImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    imageviewCharitiesTwo.image = [UIImage imageNamed:@"首页公益"];
    imageviewCharitiesTwo.imgName = @"首页公益";
    imageviewCharitiesTwo.selectImgName = @"首页公益点击";
    // 添加转盘上图标5
    imageviewPressTwo = [[DragImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    imageviewPressTwo.image = [UIImage imageNamed:@"首页发布"];
    imageviewPressTwo.imgName = @"首页发布";
    imageviewPressTwo.selectImgName = @"首页发布点击";
    // 添加转盘上图标6
    imageviewDetailTwo = [[DragImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    imageviewDetailTwo.image = [UIImage imageNamed:@"首页委托"];
    imageviewDetailTwo.imgName = @"首页委托";
    imageviewDetailTwo.selectImgName = @"首页委托点击";
    // 添加转盘中心图标
    imageviewCenterQuick = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    imageviewCenterQuick.image = [UIImage imageNamed:@"转盘icon"];
    // 图标集合
    arrImage = [[NSMutableArray alloc] initWithObjects:imageviewCharitiesOne, imageviewPressOne, imageviewDetailOne, imageviewCharitiesTwo, imageviewPressTwo,imageviewDetailTwo, nil];
    for (int i = 0; i < arrImage.count; i ++) {
        DragImageView *imageview = [arrImage objectAtIndex:i];
        imageview.userInteractionEnabled = YES;
        // 添加点击手势，点击相应图标，跳转到某一界面
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [imageview addGestureRecognizer:tap];
        imageview.tag = BASE_IMAGEVIEW_TAG + i;
    }
    // 转盘中心图标点击手势
    imageviewCenterQuick.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
    [imageviewCenterQuick addGestureRecognizer:tap1];
    imageviewCenterQuick.tag = CENTER_IMAGEVIEW_TAG;
}
-(void)imageClick:(UITapGestureRecognizer *)tap {
    long itag = tap.view.tag - BASE_IMAGEVIEW_TAG;
    switch (itag) {
        case 0:
        case 3:
            imageviewCharitiesOne.image = [UIImage imageNamed:@"首页公益"];
            imageviewCharitiesTwo.image = [UIImage imageNamed:@"首页公益"];
            NSLog(@"点击公益，跳转界面");
            break;
        case 1:
        case 4:
            imageviewPressOne.image = [UIImage imageNamed:@"首页发布"];
            imageviewPressTwo.image = [UIImage imageNamed:@"首页发布"];
            NSLog(@"点击发布，跳转界面");
            break;
        case 2:
        case 5:
            imageviewDetailOne.image = [UIImage imageNamed:@"首页委托"];
            imageviewDetailTwo.image = [UIImage imageNamed:@"首页委托"];
            NSLog(@"点击委托，跳转界面");
            break;
        case 100:
            break;
        default:
            NSLog(@"呵呵");
            break;
    }
}
//显示方式是确定圆心正下方的点，然后逆时针绘制点
- (void)showImage{
    CircleView *circleView = [[CircleView alloc] initWithFrame:ScrollFrame];
    circleView.arrImages = arrImage;
    circleView.centerImgView = imageviewCenterQuick;
    [self.view addSubview:circleView];
    [circleView loadView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
