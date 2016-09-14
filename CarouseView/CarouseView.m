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
{
    //手动退拽时保存前的偏移量，便于判断方向
    CGFloat preOffsetX;
}


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
        self.kvTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(changePageLeft) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    

    // 添加滚动控件和分页控件
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    // 设置初始页面
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    self.pageControl.currentPage = 0;
}

#pragma mark - 懒加载控件

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        // 初始化尺寸
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        // 设置分页效果
        _scrollView.pagingEnabled = YES;
        // 水平滚动条隐藏
        _scrollView.showsHorizontalScrollIndicator = NO;
        // 设置到边的弹性隐藏
        _scrollView.bounces = NO;
        // 设置分页数
        self.pageCount = [self.datasource countOfCellForCarouseView:self];
        // 设置滚动范围
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * (_pageCount + 2), CGRectGetHeight(self.frame));
        // 设置代理
        _scrollView.delegate = self;
        
        // 添加分页，左右增加一页
        for (int i = 0; i < _pageCount + 2; i++)
        {
            // 添加control,设置偏移位置
            UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];
            
            UIView *pageView = nil;
            if (i == 0)
            {
                // 第一页多余页跟最后一页一样并重新定义
                pageView = [self.datasource carouselView:self cellAtIndex:_pageCount - 1];
            }
            else if (i == _pageCount + 1)
            {
                // 最后多余的一页跟第一页一样并重新定义
                pageView = [self.datasource carouselView:self cellAtIndex:0];
            }
            else
            {
                pageView = [self.datasource carouselView:self cellAtIndex:i - 1];
            }
            // 添加pageview
            pageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            // 将pageview挂在control上
            [control addSubview:pageView];
            
            // 为每个页面添加响应层
            [control addTarget:self action:@selector(pageCliked) forControlEvents:UIControlEventTouchUpInside];
            
            [_scrollView addSubview:control];
            
        }
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
        // 设置能手动点小圆点条改变页数
        _pageControl.enabled = YES ;
        // 把导航条设置为半透明状态
        [_pageControl setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
        // 设置分页控制器的事件
        [_pageControl addTarget:self action:@selector(pageControlTouched) forControlEvents:UIControlEventValueChanged];
    }

    return _pageControl;
}

#pragma mark - pagecontrol事件
// 这个是点击小圆点条进行切换，到边不能循环
- (void)pageControlTouched
{
    // 点击的时候停止计时
    [self.kvTimer setFireDate:[NSDate distantFuture]];
    
    // 滑到指定页面
    NSInteger curPageIdx = _pageControl.currentPage;
    CGFloat offsetX = self.frame.size.width * (curPageIdx + 1);
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];

    // 重新开启定时器
    [self.kvTimer setFireDate:[NSDate dateWithTimeInterval:kTimerInterval sinceDate:[NSDate date]]];
}

#pragma mark - 滚动事件
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    printf("start drag\n");
    // 记录偏移量
    preOffsetX = scrollView.contentOffset.x;
    // 开始手动滑动时暂停定时器
    [self.kvTimer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    printf("end drag\n");
    // 左右边界
    CGFloat leftEdgeOffsetX = 0;
    CGFloat rightEdgeOffsetX = self.frame.size.width * (_pageCount + 1);
    
    if (scrollView.contentOffset.x < preOffsetX)
    {
        // 左滑
        if (scrollView.contentOffset.x > leftEdgeOffsetX)
        {
            self.pageControl.currentPage = scrollView.contentOffset.x / self.frame.size.width - 1;
        }
        else if (scrollView.contentOffset.x == leftEdgeOffsetX)
        {
            self.pageControl.currentPage = _pageCount - 1;
        }
        
        if (scrollView.contentOffset.x == leftEdgeOffsetX)
        {
            self.scrollView.contentOffset = CGPointMake(self.frame.size.width * _pageCount, 0);
        }
    }
    else
    {
        // 右滑
        
        // 设置小点
        if (scrollView.contentOffset.x < rightEdgeOffsetX)
        {
            self.pageControl.currentPage = scrollView.contentOffset.x / self.frame.size.width - 1;
        }
        else if (scrollView.contentOffset.x == rightEdgeOffsetX)
        {
            self.pageControl.currentPage = 0;
        }
        
        // 滑动完了之后从最后多余页赶紧切换到第一页
        if (scrollView.contentOffset.x == rightEdgeOffsetX)
        {
            self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        }

    }
    // 结束后又开启定时器
    [self.kvTimer setFireDate:[NSDate dateWithTimeInterval:kTimerInterval sinceDate:[NSDate date]]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
//    printf("end scroll\n");
}

#pragma mark - 定时器控制的滑动
// 往右边滑
- (void)changePageRight
{
    // 设置当前需要偏移的量，每次递增一个page宽度
    CGFloat offsetX = _scrollView.contentOffset.x + CGRectGetWidth(self.frame);
    
    // 根据情况进行偏移
    CGFloat edgeOffsetX = self.frame.size.width * (_pageCount + 1);  // 最后一个多余页面右边缘偏移量
    
    // 从多余页往右边滑，赶紧先设置为第一页的位置
    if (offsetX > edgeOffsetX)
    {
        // 偏移量，不带动画，欺骗视觉
        self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        // 这里提前改变下一个要滑动到的位置为第二页
        offsetX = self.frame.size.width * 2;
    }
    
    // 带动画滑动到下一页面
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    if (offsetX < edgeOffsetX)
    {
        self.pageControl.currentPage = offsetX / self.frame.size.width - 1;
    }
    else if (offsetX == edgeOffsetX)
    {
        // 最后的多余那一页滑过去之后设置小点为第一个
        self.pageControl.currentPage = 0;
    }
}

// 往左边滑
- (void)changePageLeft
{
    // 设置当前需要偏移的量，每次递减一个page宽度
    CGFloat offsetX = _scrollView.contentOffset.x - CGRectGetWidth(self.frame);
    
    // 根据情况进行偏移
    CGFloat edgeOffsetX = 0;  // 最后一个多余页面左边缘偏移量
    
    // 从多余页往左边滑动，先设置为最后一页
    if (offsetX < edgeOffsetX)
    {
        self.scrollView.contentOffset = CGPointMake(self.frame.size.width * _pageCount, 0);
        offsetX = self.frame.size.width * (_pageCount - 1);
    }
    
    // 带动画滑动到前一页面
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    if (offsetX > edgeOffsetX)
    {
        self.pageControl.currentPage = offsetX / self.frame.size.width - 1;
    }
    else if (offsetX == edgeOffsetX)
    {
        // 最后的多余那一页滑过去之后设置小点为最后一个
        self.pageControl.currentPage = _pageCount - 1;
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
