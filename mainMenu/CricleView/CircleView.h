//
//  CircleView.h
//  CircleProject
//
//  Created by zbq on 13-10-31.
//  Copyright (c) 2013年 zbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragImageView.h"
@interface CircleView : UIView
<
UIGestureRecognizerDelegate
>{
    @private
    //圆的半径
    CGFloat radius;
    //圆心（在CircleView上的位置）
    CGPoint center;
    //平均角度
    CGFloat average_radina;
    //拖动的点
    CGPoint pointDrag;
    //拖动结束后间隔的个数
    NSInteger step;
}

@property(nonatomic, retain) NSMutableArray *arrImages;
// 中心view
@property (nonatomic, strong)UIImageView *centerImgView;
- (void)loadView;

@end
