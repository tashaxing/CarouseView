//
//  CarouseView.h
//  CarouseView
//
//  Created by yxhe on 16/9/9.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

// ---- 一个无限循环的轮播图封装类 ---- //

#import <UIKit/UIKit.h>

@class CarouseView;

#pragma mark - 循环轮播类的datasource 协议
@protocol CarouseViewDataSource<NSObject>

@required

@optional
// 轮播图的个数
- (NSInteger)countOfCellForCarouseView:(CarouseView *)carouseView;
// 轮播图填充
- (UIView *)carouselView:(CarouseView *)carouselView cellAtIndex:(NSInteger)index;

@end

#pragma mark - 循环轮播图的delegate协议
@protocol CarouseViewDelegate<NSObject>

@required

@optional

// 选中轮播图项
- (void)carouseView:(CarouseView *)carouseView didSelectedAtIndex:(NSInteger)index;

@end

#pragma mark - 循环轮播类
@interface CarouseView : UIView

@property (nonatomic, weak) id<CarouseViewDelegate> delegate;
@property (nonatomic, weak) id<CarouseViewDataSource> datasource;

@end
