//
//  CarouseView.m
//  CarouseView
//
//  Created by yxhe on 16/9/9.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import "CarouseView.h"

// 定时器常量(间隔：秒)，也可以放在外面设置
static const double kTimerInterval = 2.0;

@interface CarouseView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;    // 主滑动view
@property (nonatomic, strong) UIPageControl *pageControl;  // 分页控件
@property (nonatomic, strong) NSTimer *kvTimer;            // 定时器
@property (nonatomic, assign) NSInteger pageCount;         // 页数

@end

@implementation CarouseView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor grayColor];
        // 启动定时器
//        self.kvTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(changePage) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)layoutSubviews
{
    // 添加滚动控件和分页控件
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    // 添加点击控件
//    UIControl *control = [[UIControl alloc] initWithFrame:self.frame];
//    [control addTarget:self action:@selector(pageCliked) forControlEvents:UIControlEventTouchUpInside];
//    control.userInteractionEnabled = YES;
//    [self addSubview:control];
}

#pragma mark - 懒加载控件

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        // 初始化大小
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        // 设置滚动范围
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * (_pageCount + 1), CGRectGetHeight(self.frame));
        // 设置分页效果
        _scrollView.pagingEnabled = YES;
        // 水平滚动条隐藏
        _scrollView.showsHorizontalScrollIndicator = NO;
        // 添加子分页
        // 设置页数
        self.pageCount = [self.datasource countOfCellForCarouseView:self];
        for (int i = 0; i < _pageCount; i++)
        {
            UIView *pageView = [self.datasource carouselView:self cellAtIndex:i];
            // 设置tag方便索引
            pageView.tag = 1000 + i;
            // 设置偏移位置
            pageView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
            [_scrollView addSubview:pageView];
        }
        // 在最后一个页面后面加一个跟第一页一样的页面
        UIView *lastPageView = [_scrollView viewWithTag:1000];
        lastPageView.frame = CGRectMake(self.frame.size.width * _pageCount, 0, self.frame.size.width, self.frame.size.height);
        lastPageView.tag = 1000 + _pageCount;
        [_scrollView addSubview:lastPageView];
        
        // 设置代理
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        // 设置尺寸，坐标，注意纵坐标的起点
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
        // 设置页面数
        _pageControl.numberOfPages = _pageCount;
        // 设置当前页面索引
        _pageControl.currentPage = 0;
        // 设置未被选中时小圆点颜色
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        // 设置被选中时小圆点颜色
        _pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
        // 设置能手动点小圆点改变页数
        _pageControl.enabled = YES ;
        // 把导航条设置为半透明状态
        [_pageControl setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
        
  
    }
    return _pageControl;
}

#pragma mark - 滚动事件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    printf("start drag\n");
    // 开始手动滑动时暂停定时器
    [self.kvTimer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    printf("end drag\n");
    // 结束后又开启定时器
    [self.kvTimer setFireDate:[NSDate dateWithTimeInterval:kTimerInterval sinceDate:[NSDate date]]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    printf("end scroll\n");
}

- (void)changePage
{
    // 设置当前需要偏移的量
    CGFloat offsetX = _scrollView.contentOffset.x + CGRectGetWidth(self.frame);
    
    // 根据情况进行偏移
    CGFloat edgeOffset = self.frame.size.width * _pageCount;  // 最后一个页面右边缘偏移量
    // 带动画滑动
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    if (offsetX <= edgeOffset)
    {
        self.pageControl.currentPage = offsetX / self.frame.size.width;
    }
    else
    {
        self.pageControl.currentPage = 0;
        // 最后的多余那一页滑过去之后要立即设置偏移量为起点，并且不要动画，欺骗视觉
        self.scrollView.contentOffset = CGPointZero;
    }
    
}


#pragma mark - 触控事件
- (void)pageCliked
{
    // 当点击轮播图的时候
    if ([self.delegate respondsToSelector:@selector(carouseView:didSelectedAtIndex:)])
    {
        [self.delegate carouseView:self didSelectedAtIndex:_pageControl.currentPage];
    }
}

@end
